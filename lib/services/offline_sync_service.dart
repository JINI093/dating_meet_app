import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/message_model.dart';
import '../models/match_model.dart';
import '../utils/logger.dart';
import 'aws_chat_service.dart';
import 'aws_match_service.dart';

/// 오프라인 메시지 동기화 서비스
/// 네트워크 상태를 모니터링하고 온라인 전환 시 자동 동기화 수행
class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final AWSChatService _chatService = AWSChatService();
  final AWSMatchService _matchService = AWSMatchService();
  final Connectivity _connectivity = Connectivity();
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = false;
  Timer? _syncTimer;
  
  static const String _pendingSyncKey = 'pending_sync_operations';
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _offlineQueueKey = 'offline_message_queue';

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      // 초기 연결 상태 확인
      final connectivityResults = await _connectivity.checkConnectivity();
      _isOnline = !connectivityResults.contains(ConnectivityResult.none);
      
      // 연결 상태 변화 모니터링
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
      );
      
      // 주기적 동기화 타이머 설정
      _setupPeriodicSync();
      
      // 앱 시작 시 한 번 동기화 수행
      if (_isOnline) {
        await _performFullSync();
      }
      
      Logger.log('✅ OfflineSyncService 초기화 완료 (온라인: $_isOnline)', name: 'OfflineSyncService');
    } catch (e) {
      Logger.error('❌ OfflineSyncService 초기화 실패', error: e, name: 'OfflineSyncService');
      rethrow;
    }
  }

  /// 연결 상태 변화 처리
  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    final wasOnline = _isOnline;
    _isOnline = !results.contains(ConnectivityResult.none);
    
    Logger.log('연결 상태 변화: $wasOnline -> $_isOnline', name: 'OfflineSyncService');
    
    // 오프라인에서 온라인으로 전환된 경우
    if (!wasOnline && _isOnline) {
      await _performFullSync();
    }
  }

  /// 전체 동기화 수행
  Future<void> _performFullSync() async {
    try {
      Logger.log('전체 동기화 시작', name: 'OfflineSyncService');
      
      // 1. 오프라인 큐의 메시지들 처리
      await _processPendingMessages();
      
      // 2. 실패한 메시지들 재시도
      await _retryFailedMessages();
      
      // 3. 서버와 메시지 동기화
      await _syncWithServer();
      
      // 4. 동기화 시간 업데이트
      await _updateLastSyncTime();
      
      Logger.log('전체 동기화 완료', name: 'OfflineSyncService');
    } catch (e) {
      Logger.error('전체 동기화 오류', error: e, name: 'OfflineSyncService');
    }
  }

  /// 메시지를 오프라인 큐에 추가
  Future<void> addToOfflineQueue({
    required String matchId,
    required String senderId,
    required String receiverId,
    required String content,
    required MessageType type,
    String? imageUrl,
    String? thumbnailUrl,
    int? superchatPoints,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueKey = '$_offlineQueueKey';
      
      // 기존 큐 가져오기
      final existingQueueJson = prefs.getStringList(queueKey) ?? [];
      final existingQueue = existingQueueJson
          .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
          .toList();
      
      // 새 메시지 추가
      final messageData = {
        'matchId': matchId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'type': type.name,
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
        'superchatPoints': superchatPoints,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
        'localId': DateTime.now().millisecondsSinceEpoch.toString(),
      };
      
      existingQueue.add(messageData);
      
      // 최대 500개까지만 유지
      if (existingQueue.length > 500) {
        existingQueue.removeRange(0, existingQueue.length - 500);
      }
      
      // 저장
      final updatedQueueJson = existingQueue
          .map((data) => jsonEncode(data))
          .toList();
      
      await prefs.setStringList(queueKey, updatedQueueJson);
      
      Logger.log('오프라인 큐에 메시지 추가: ${messageData['localId']}', name: 'OfflineSyncService');
    } catch (e) {
      Logger.error('오프라인 큐 추가 오류', error: e, name: 'OfflineSyncService');
    }
  }

  /// 오프라인 큐의 대기 중인 메시지들 처리
  Future<void> _processPendingMessages() async {
    try {
      if (!_isOnline) return;
      
      final prefs = await SharedPreferences.getInstance();
      final queueKey = '$_offlineQueueKey';
      
      final queueJson = prefs.getStringList(queueKey) ?? [];
      if (queueJson.isEmpty) return;
      
      Logger.log('대기 중인 메시지 ${queueJson.length}개 처리 시작', name: 'OfflineSyncService');
      
      final processedMessages = <String>[];
      
      for (final messageJson in queueJson) {
        try {
          final messageData = Map<String, dynamic>.from(jsonDecode(messageJson));
          
          // 메시지 전송 시도
          final success = await _sendPendingMessage(messageData);
          
          if (success) {
            processedMessages.add(messageJson);
          }
          
          // 과부하 방지를 위한 딜레이
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (e) {
          Logger.error('개별 메시지 처리 오류', error: e, name: 'OfflineSyncService');
        }
      }
      
      // 성공적으로 처리된 메시지들을 큐에서 제거
      if (processedMessages.isNotEmpty) {
        final remainingQueue = queueJson
            .where((json) => !processedMessages.contains(json))
            .toList();
        
        await prefs.setStringList(queueKey, remainingQueue);
        
        Logger.log('대기 메시지 처리 완료: ${processedMessages.length}개 성공, ${remainingQueue.length}개 남음', 
                   name: 'OfflineSyncService');
      }
    } catch (e) {
      Logger.error('대기 메시지 처리 오류', error: e, name: 'OfflineSyncService');
    }
  }

  /// 개별 대기 메시지 전송
  Future<bool> _sendPendingMessage(Map<String, dynamic> messageData) async {
    try {
      final type = MessageType.values.firstWhere(
        (t) => t.name == messageData['type'],
        orElse: () => MessageType.text,
      );
      
      final message = await _chatService.sendMessage(
        matchId: messageData['matchId'],
        senderId: messageData['senderId'],
        receiverId: messageData['receiverId'],
        content: messageData['content'],
        type: type,
        imageUrl: messageData['imageUrl'],
        thumbnailUrl: messageData['thumbnailUrl'],
        superchatPoints: messageData['superchatPoints'],
        metadata: messageData['metadata'],
      );
      
      return message != null;
    } catch (e) {
      Logger.error('대기 메시지 전송 오류', error: e, name: 'OfflineSyncService');
      return false;
    }
  }

  /// 실패한 메시지들 재시도
  Future<void> _retryFailedMessages() async {
    try {
      if (!_isOnline) return;
      
      // 모든 활성 매칭의 실패한 메시지들을 찾아서 재시도
      final activeMatches = await _getActiveMatchIds();
      
      for (final matchId in activeMatches) {
        final cachedMessages = _chatService.getCachedMessages(matchId);
        final failedMessages = cachedMessages
            .where((msg) => msg.status == MessageStatus.failed && msg.localId != null)
            .toList();
        
        for (final message in failedMessages) {
          try {
            await _chatService.resendMessage(matchId, message.localId!);
            await Future.delayed(const Duration(milliseconds: 100));
          } catch (e) {
            Logger.error('실패 메시지 재시도 오류: ${message.messageId}', error: e, name: 'OfflineSyncService');
          }
        }
      }
    } catch (e) {
      Logger.error('실패 메시지 재시도 전체 오류', error: e, name: 'OfflineSyncService');
    }
  }

  /// 서버와 메시지 동기화
  Future<void> _syncWithServer() async {
    try {
      if (!_isOnline) return;
      
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) return;
      
      final activeMatches = await _getActiveMatchIds();
      
      for (final matchId in activeMatches) {
        try {
          await _chatService.syncMessages(matchId, currentUserId);
          await Future.delayed(const Duration(milliseconds: 50));
        } catch (e) {
          Logger.error('매칭 동기화 오류: $matchId', error: e, name: 'OfflineSyncService');
        }
      }
    } catch (e) {
      Logger.error('서버 동기화 오류', error: e, name: 'OfflineSyncService');
    }
  }

  /// 주기적 동기화 설정
  void _setupPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_isOnline) {
        _performIncrementalSync();
      }
    });
  }

  /// 증분 동기화 (가벼운 동기화)
  Future<void> _performIncrementalSync() async {
    try {
      // 오프라인 큐가 있으면 처리
      await _processPendingMessages();
      
      // 실패한 메시지 재시도
      await _retryFailedMessages();
      
      Logger.log('증분 동기화 완료', name: 'OfflineSyncService');
    } catch (e) {
      Logger.error('증분 동기화 오류', error: e, name: 'OfflineSyncService');
    }
  }

  /// 마지막 동기화 시간 업데이트
  Future<void> _updateLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      Logger.error('동기화 시간 업데이트 오류', error: e, name: 'OfflineSyncService');
    }
  }

  /// 마지막 동기화 시간 조회
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_lastSyncTimeKey);
      return timeString != null ? DateTime.parse(timeString) : null;
    } catch (e) {
      Logger.error('동기화 시간 조회 오류', error: e, name: 'OfflineSyncService');
      return null;
    }
  }

  /// 활성 매칭 ID 목록 조회
  Future<List<String>> _getActiveMatchIds() async {
    try {
      final currentUserId = await _getCurrentUserId();
      if (currentUserId == null) return [];
      
      final matches = await _matchService.getUserMatches(userId: currentUserId);
      return matches
          .where((match) => match.status == MatchStatus.active)
          .map((match) => match.id)
          .toList();
    } catch (e) {
      Logger.error('활성 매칭 조회 오류', error: e, name: 'OfflineSyncService');
      return [];
    }
  }

  /// 현재 사용자 ID 조회
  Future<String?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('current_user_id');
    } catch (e) {
      Logger.error('현재 사용자 ID 조회 오류', error: e, name: 'OfflineSyncService');
      return null;
    }
  }

  /// 오프라인 큐 크기 조회
  Future<int> getOfflineQueueSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getStringList('$_offlineQueueKey') ?? [];
      return queueJson.length;
    } catch (e) {
      Logger.error('오프라인 큐 크기 조회 오류', error: e, name: 'OfflineSyncService');
      return 0;
    }
  }

  /// 오프라인 큐 클리어
  Future<void> clearOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_offlineQueueKey');
      Logger.log('오프라인 큐 클리어 완료', name: 'OfflineSyncService');
    } catch (e) {
      Logger.error('오프라인 큐 클리어 오류', error: e, name: 'OfflineSyncService');
    }
  }

  /// 수동 동기화 트리거
  Future<void> manualSync() async {
    if (!_isOnline) {
      Logger.log('오프라인 상태에서는 동기화할 수 없습니다', name: 'OfflineSyncService');
      return;
    }
    
    await _performFullSync();
  }

  /// 연결 상태 확인
  bool get isOnline => _isOnline;

  /// 서비스 정리
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    Logger.log('OfflineSyncService 정리 완료', name: 'OfflineSyncService');
  }
}