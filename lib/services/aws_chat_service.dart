import 'dart:async';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../models/message_model.dart';
import '../models/match_model.dart';
import '../utils/logger.dart';
import '../config/api_config.dart' as AppApiConfig;

/// AWS AppSync 기반 실시간 채팅 서비스
/// GraphQL Subscriptions를 통한 실시간 메시지 송수신
class AWSChatService {
  static final AWSChatService _instance = AWSChatService._internal();
  factory AWSChatService() => _instance;
  AWSChatService._internal();

  // 실시간 구독 관리
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, StreamController<MessageModel>> _messageControllers = {};
  final Map<String, List<MessageModel>> _messageCache = {};

  // 메시지 상태 관리
  final Map<String, MessageModel> _pendingMessages = {};
  Timer? _retryTimer;
  
  // 폴링 기반 실시간 메시지 확인
  final Map<String, Timer> _pollingTimers = {};
  final Map<String, DateTime> _lastMessageCheck = {};
  final Map<String, String> _activeChats = {}; // matchId -> currentUserId

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      if (!Amplify.isConfigured) {
        throw Exception('Amplify가 초기화되지 않았습니다.');
      }
      
      // 재시도 타이머 설정
      _setupRetryTimer();
      
      Logger.log('✅ AWSChatService 초기화 완료', name: 'AWSChatService');
    } catch (e) {
      Logger.error('❌ AWSChatService 초기화 실패', error: e, name: 'AWSChatService');
      rethrow;
    }
  }

  /// 특정 매칭의 메시지 목록 조회 (REST API 사용)
  Future<List<MessageModel>> getMessages({
    required String matchId,
    required String currentUserId,
    int limit = 50,
    String? nextToken,
  }) async {
    try {
      // JWT 토큰 가져오기
      final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      final token = session.userPoolTokensResult.value.accessToken.raw;

      // REST API로 메시지 조회
      final dio = Dio();
      
      // Query parameters
      final queryParams = {
        'limit': limit,
        if (nextToken != null) 'nextToken': nextToken,
      };

      Logger.log('📥 메시지 조회 중: ${AppApiConfig.ApiConfig.baseUrl}/messages/match/$matchId', name: 'AWSChatService');

      final response = await dio.get(
        '${AppApiConfig.ApiConfig.baseUrl}/messages/match/$matchId',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      Logger.log('📥 메시지 조회 응답: ${response.statusCode}', name: 'AWSChatService');

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final messages = <MessageModel>[];
        
        if (responseData['messages'] != null) {
          final items = responseData['messages'] as List;
          
          for (final item in items) {
            final message = MessageModel(
              messageId: item['id'] ?? item['messageId'] ?? '',
              matchId: item['chatRoomId'] ?? item['matchId'] ?? matchId,
              senderId: item['senderId'] ?? '',
              receiverId: item['receiverId'] ?? '',
              content: item['content'] ?? '',
              messageType: _parseMessageType(item['messageType']),
              status: _parseMessageStatus(item['status']),
              createdAt: DateTime.parse(item['createdAt'] ?? DateTime.now().toIso8601String()),
              readAt: item['readAt'] != null ? DateTime.parse(item['readAt']) : null,
              imageUrl: item['imageUrl'],
              thumbnailUrl: item['thumbnailUrl'],
              superchatPoints: item['superchatPoints'],
              isFromCurrentUser: item['senderId'] == currentUserId,
            );
            messages.add(message);
          }
        }

        // 최신순으로 정렬 (UI에서 표시하기 위해 역순으로)
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        // 캐시에 저장
        _messageCache[matchId] = messages;
        
        Logger.log('✅ 메시지 ${messages.length}개 조회 성공: $matchId', name: 'AWSChatService');
        return messages;
      } else {
        throw Exception('메시지 조회 실패: ${response.data['message'] ?? response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ 메시지 조회 오류', error: e, name: 'AWSChatService');
      return _messageCache[matchId] ?? [];
    }
  }

  /// 메시지 전송 (REST API 사용)
  Future<MessageModel?> sendMessage({
    required String matchId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
    String? thumbnailUrl,
    int? superchatPoints,
    Map<String, dynamic>? metadata,
  }) async {
    // 로컬 임시 메시지 생성
    final localId = DateTime.now().millisecondsSinceEpoch.toString();
    final tempMessage = MessageModel(
        messageId: localId,
        matchId: matchId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        messageType: type,
        status: MessageStatus.sending,
        createdAt: DateTime.now(),
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
        superchatPoints: superchatPoints,
        metadata: metadata,
        isFromCurrentUser: true,
        localId: localId,
      );

    try {
      // 즉시 UI에 표시하기 위해 로컬 메시지 추가
      _addMessageToCache(matchId, tempMessage);
      _notifyMessageUpdate(matchId, tempMessage);

      // 전송 대기 목록에 추가
      _pendingMessages[localId] = tempMessage;

      // JWT 토큰 가져오기
      final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      final token = session.userPoolTokensResult.value.accessToken.raw;

      // REST API로 메시지 전송
      final dio = Dio();
      final messageData = {
        'matchId': matchId,
        'receiverId': receiverId,
        'content': content,
        'messageType': type.name.toLowerCase(),
      };

      // 타입별 추가 데이터
      if (type == MessageType.image) {
        if (imageUrl != null) messageData['imageUrl'] = imageUrl;
        if (thumbnailUrl != null) messageData['thumbnailUrl'] = thumbnailUrl;
      } else if (type == MessageType.superchat) {
        if (superchatPoints != null) messageData['superchatPoints'] = superchatPoints.toString();
      }

      Logger.log('📤 메시지 전송 중: ${AppApiConfig.ApiConfig.messagesUrl}', name: 'AWSChatService');
      Logger.log('📤 메시지 데이터: $messageData', name: 'AWSChatService');

      final response = await dio.post(
        '${AppApiConfig.ApiConfig.baseUrl}/messages',
        data: messageData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      Logger.log('📥 메시지 전송 응답: ${response.statusCode}', name: 'AWSChatService');
      Logger.log('📥 응답 데이터: ${response.data}', name: 'AWSChatService');

      if (response.statusCode == 201) {
        final responseData = response.data['data'];
        
        final serverMessage = MessageModel(
          messageId: responseData['id'] ?? responseData['messageId'] ?? '',
          matchId: responseData['chatRoomId'] ?? responseData['matchId'] ?? matchId,
          senderId: responseData['senderId'] ?? '',
          receiverId: responseData['receiverId'] ?? '',
          content: responseData['content'] ?? '',
          messageType: _parseMessageType(responseData['messageType']),
          status: _parseMessageStatus(responseData['status']),
          createdAt: DateTime.parse(responseData['createdAt'] ?? DateTime.now().toIso8601String()),
          imageUrl: responseData['imageUrl'],
          thumbnailUrl: responseData['thumbnailUrl'],
          superchatPoints: responseData['superchatPoints'],
          isFromCurrentUser: true,
          localId: localId,
        );
        
        // 로컬 메시지를 서버 메시지로 교체
        _updateMessageInCache(matchId, localId, serverMessage);
        _notifyMessageUpdate(matchId, serverMessage);
        _pendingMessages.remove(localId);

        Logger.log('✅ 메시지 전송 성공: ${serverMessage.messageId}', name: 'AWSChatService');
        return serverMessage;
      } else {
        throw Exception('메시지 전송 실패: ${response.data['message'] ?? response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ 메시지 전송 오류', error: e, name: 'AWSChatService');
      
      // 전송 실패한 메시지 상태 업데이트
      final localId = tempMessage.localId;
      if (localId != null) {
        final failedMessage = tempMessage.copyWith(status: MessageStatus.failed);
        _updateMessageInCache(matchId, localId, failedMessage);
        _notifyMessageUpdate(matchId, failedMessage);
        _pendingMessages.remove(localId);
      }
      
      return null;
    }
  }

  MessageType _parseMessageType(String? type) {
    if (type == null) return MessageType.text;
    switch (type.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'superchat':
        return MessageType.superchat;
      case 'system':
        return MessageType.system;
      case 'sticker':
        return MessageType.sticker;
      default:
        return MessageType.text;
    }
  }

  MessageStatus _parseMessageStatus(String? status) {
    if (status == null) return MessageStatus.sent;
    switch (status.toLowerCase()) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }

  /// 실시간 메시지 구독 시작 (폴링 방식)
  Stream<MessageModel> subscribeToMessages(String matchId, String currentUserId) {
    // 기존 구독이 있으면 해제
    unsubscribeFromMessages(matchId);

    // 새 스트림 컨트롤러 생성
    final controller = StreamController<MessageModel>.broadcast();
    _messageControllers[matchId] = controller;
    
    // 활성 채팅으로 등록
    _activeChats[matchId] = currentUserId;
    _lastMessageCheck[matchId] = DateTime.now();

    // 폴링 시작 (3초마다 새 메시지 확인)
    _pollingTimers[matchId] = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkForNewMessages(matchId, currentUserId, controller);
    });
    
    Logger.log('✅ 실시간 메시지 구독 시작 (폴링 방식): $matchId', name: 'AWSChatService');
    
    return controller.stream;
    
    /* WebSocket 구독 코드 (설정 완료 후 활성화)
    try {
      final subscription = Amplify.API.subscribe(
        GraphQLRequest<String>(
          document: '''
            subscription OnMessageCreated(\$matchId: String!) {
              onMessageCreated(matchId: \$matchId) {
                messageId
                matchId
                senderId
                receiverId
                content
                messageType
                status
                createdAt
                readAt
                deliveredAt
                metadata
                imageUrl
                thumbnailUrl
                superchatPoints
                stickerPackId
                stickerId
              }
            }
          ''',
          variables: {'matchId': matchId},
        ),
      ).listen(
        (event) {
          try {
            if (event.data != null) {
              final data = _parseGraphQLResponse(event.data!);
              final messageData = data['onMessageCreated'];
              
              if (messageData != null) {
                final message = MessageModel.fromJson(messageData).copyWith(
                  isFromCurrentUser: messageData['senderId'] == currentUserId,
                );

                // 자신이 보낸 메시지가 아닌 경우에만 처리 (중복 방지)
                if (message.senderId != currentUserId) {
                  _addMessageToCache(matchId, message);
                  controller.add(message);

                  // 자동 읽음 처리 (채팅방이 활성화되어 있는 경우)
                  _markMessageAsRead(message.messageId, currentUserId);
                }
              }
            }
          } catch (e) {
            Logger.error('실시간 메시지 처리 오류', error: e, name: 'AWSChatService');
          }
        },
        onError: (error) {
          Logger.error('실시간 메시지 구독 오류', error: error, name: 'AWSChatService');
          controller.addError(error);
        },
      );

      _subscriptions[matchId] = subscription;
      Logger.log('실시간 메시지 구독 시작: $matchId', name: 'AWSChatService');
    } catch (e) {
      Logger.error('실시간 메시지 구독 시작 오류', error: e, name: 'AWSChatService');
      controller.addError(e);
    }

    return controller.stream;
    */
  }

  /// 실시간 메시지 구독 해제
  void unsubscribeFromMessages(String matchId) {
    _subscriptions[matchId]?.cancel();
    _subscriptions.remove(matchId);
    
    _pollingTimers[matchId]?.cancel();
    _pollingTimers.remove(matchId);
    
    _messageControllers[matchId]?.close();
    _messageControllers.remove(matchId);
    
    _activeChats.remove(matchId);
    _lastMessageCheck.remove(matchId);
    
    Logger.log('실시간 메시지 구독 해제: $matchId', name: 'AWSChatService');
  }

  /// 새 메시지 확인 (폴링용)
  Future<void> _checkForNewMessages(String matchId, String currentUserId, StreamController<MessageModel> controller) async {
    try {
      final lastCheck = _lastMessageCheck[matchId];
      if (lastCheck == null) return;

      // 캐시된 메시지 확인
      final cachedMessages = _messageCache[matchId] ?? [];
      final cachedMessageIds = cachedMessages.map((m) => m.messageId).toSet();

      // 최신 메시지 조회
      final messages = await getMessages(
        matchId: matchId,
        currentUserId: currentUserId,
        limit: 50,
      );

      // 실제로 새로운 메시지만 필터링 (ID 기반)
      final newMessages = messages.where((message) {
        // 이미 캐시에 있는 메시지는 제외
        if (cachedMessageIds.contains(message.messageId)) {
          return false;
        }
        
        // 마지막 체크 시간 이후에 생성된 메시지만 포함
        return message.createdAt.isAfter(lastCheck);
      }).toList();
      
      if (newMessages.isNotEmpty) {
        for (final message in newMessages) {
          // 자신이 보낸 메시지가 아닌 경우에만 스트림에 추가
          if (message.senderId != currentUserId) {
            controller.add(message);
            Logger.log('📥 새 메시지 수신: ${message.content}', name: 'AWSChatService');
            
            // 자동 읽음 처리
            await _markMessageAsRead(message.messageId, currentUserId);
          } else {
            Logger.log('📤 내가 보낸 메시지 감지됨 - 스트림 추가 생략: ${message.content}', name: 'AWSChatService');
          }
        }
      }

      // 캐시 업데이트
      _messageCache[matchId] = messages;
      _lastMessageCheck[matchId] = DateTime.now();
    } catch (e) {
      Logger.error('새 메시지 확인 오류', error: e, name: 'AWSChatService');
    }
  }

  /// 메시지 읽음 처리
  Future<bool> markMessageAsRead(String messageId, String userId) async {
    return await _markMessageAsRead(messageId, userId);
  }

  /// 메시지 읽음 처리 (내부 - REST API 사용)
  Future<bool> _markMessageAsRead(String messageId, String userId) async {
    try {
      // JWT 토큰 가져오기
      final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      final token = session.userPoolTokensResult.value.accessToken.raw;

      // REST API로 메시지 읽음 처리
      final dio = Dio();
      
      Logger.log('📝 메시지 읽음 처리 중: ${AppApiConfig.ApiConfig.baseUrl}/messages/read/$messageId', name: 'AWSChatService');

      final response = await dio.put(
        '${AppApiConfig.ApiConfig.baseUrl}/messages/read/$messageId',
        data: {
          'status': 'read',
          'readAt': DateTime.now().toIso8601String(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      Logger.log('📥 메시지 읽음 처리 응답: ${response.statusCode}', name: 'AWSChatService');

      if (response.statusCode == 200) {
        Logger.log('✅ 메시지 읽음 처리 성공: $messageId', name: 'AWSChatService');
        return true;
      } else {
        Logger.error('❌ 메시지 읽음 처리 실패: ${response.data['message'] ?? response.statusCode}', name: 'AWSChatService');
        return false;
      }
    } catch (e) {
      Logger.error('❌ 메시지 읽음 처리 오류', error: e, name: 'AWSChatService');
      return false;
    }
  }

  /// 매칭의 모든 읽지 않은 메시지를 읽음 처리
  Future<bool> markAllMessagesAsRead(String matchId, String userId) async {
    try {
      final messages = _messageCache[matchId] ?? [];
      final unreadMessages = messages
          .where((msg) => !msg.isFromCurrentUser && !msg.isRead)
          .toList();

      for (final message in unreadMessages) {
        await _markMessageAsRead(message.messageId, userId);
      }

      // 캐시 업데이트
      for (int i = 0; i < messages.length; i++) {
        final message = messages[i];
        if (!message.isFromCurrentUser && !message.isRead) {
          messages[i] = message.copyWith(
            status: MessageStatus.read,
            readAt: DateTime.now(),
          );
        }
      }

      Logger.log('모든 메시지 읽음 처리: $matchId (${unreadMessages.length}개)', name: 'AWSChatService');
      return true;
    } catch (e) {
      Logger.error('모든 메시지 읽음 처리 오류', error: e, name: 'AWSChatService');
      return false;
    }
  }

  /// 매칭의 마지막 메시지 정보 업데이트
  Future<void> _updateMatchLastMessage(String matchId, MessageModel message) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation UpdateMatchLastMessage(\$input: UpdateMatchInput!) {
            updateMatch(input: \$input) {
              id
              lastMessage
              lastMessageAt
              lastMessageSenderId
            }
          }
        ''',
        variables: {
          'input': {
            'id': matchId,
            'lastMessage': message.content,
            'lastMessageAt': message.createdAt.toIso8601String(),
            'lastMessageSenderId': message.senderId,
            'updatedAt': DateTime.now().toIso8601String(),
          }
        },
      );

      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      Logger.error('매칭 마지막 메시지 업데이트 오류', error: e, name: 'AWSChatService');
    }
  }

  /// 메시지 재전송
  Future<bool> resendMessage(String matchId, String localId) async {
    final pendingMessage = _pendingMessages[localId];
    if (pendingMessage == null) return false;

    try {
      // 상태를 전송 중으로 변경
      final retryMessage = pendingMessage.copyWith(status: MessageStatus.sending);
      _updateMessageInCache(matchId, localId, retryMessage);
      _notifyMessageUpdate(matchId, retryMessage);

      // 다시 전송 시도
      final result = await sendMessage(
        matchId: pendingMessage.matchId,
        senderId: pendingMessage.senderId,
        receiverId: pendingMessage.receiverId,
        content: pendingMessage.content,
        type: pendingMessage.messageType,
        imageUrl: pendingMessage.imageUrl,
        thumbnailUrl: pendingMessage.thumbnailUrl,
        superchatPoints: pendingMessage.superchatPoints,
        metadata: pendingMessage.metadata,
      );

      return result != null;
    } catch (e) {
      Logger.error('메시지 재전송 오류', error: e, name: 'AWSChatService');
      return false;
    }
  }

  /// 메시지 캐시에 추가
  void _addMessageToCache(String matchId, MessageModel message) {
    if (!_messageCache.containsKey(matchId)) {
      _messageCache[matchId] = [];
    }
    
    final messages = _messageCache[matchId]!;
    
    // 중복 확인 (messageId 또는 localId로)
    final existingIndex = messages.indexWhere((msg) => 
        msg.messageId == message.messageId || 
        (msg.localId != null && msg.localId == message.localId));
    
    if (existingIndex != -1) {
      messages[existingIndex] = message;
    } else {
      messages.add(message);
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
  }

  /// 캐시의 메시지 업데이트
  void _updateMessageInCache(String matchId, String localId, MessageModel updatedMessage) {
    final messages = _messageCache[matchId];
    if (messages == null) return;

    final index = messages.indexWhere((msg) => 
        msg.localId == localId || msg.messageId == localId);
    
    if (index != -1) {
      messages[index] = updatedMessage;
    }
  }

  /// 메시지 업데이트 알림
  void _notifyMessageUpdate(String matchId, MessageModel message) {
    final controller = _messageControllers[matchId];
    if (controller != null && !controller.isClosed) {
      controller.add(message);
    }
  }

  /// 재시도 타이머 설정
  void _setupRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _retryFailedMessages();
    });
  }

  /// 실패한 메시지 재시도
  void _retryFailedMessages() {
    final failedMessages = Map<String, MessageModel>.from(_pendingMessages);
    
    for (final entry in failedMessages.entries) {
      final localId = entry.key;
      final message = entry.value;
      
      if (message.status == MessageStatus.failed) {
        resendMessage(message.matchId, localId);
      }
    }
  }

  /// 서비스 정리
  void dispose() {
    // 모든 구독 해제
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // 모든 스트림 컨트롤러 닫기
    for (final controller in _messageControllers.values) {
      controller.close();
    }
    _messageControllers.clear();

    // 캐시 정리
    _messageCache.clear();
    _pendingMessages.clear();

    // 타이머 정리
    _retryTimer?.cancel();
    _retryTimer = null;

    Logger.log('AWSChatService 정리 완료', name: 'AWSChatService');
  }

  /// GraphQL 응답 파싱
  Map<String, dynamic> _parseGraphQLResponse(String response) {
    try {
      if (response.startsWith('{') || response.startsWith('[')) {
        return Map<String, dynamic>.from(response as Map);
      }
      return {};
    } catch (e) {
      Logger.error('GraphQL 응답 파싱 오류', error: e, name: 'AWSChatService');
      return {};
    }
  }

  /// 현재 캐시된 메시지 목록 반환
  List<MessageModel> getCachedMessages(String matchId) {
    return _messageCache[matchId] ?? [];
  }

  /// 읽지 않은 메시지 수 반환
  int getUnreadCount(String matchId, String currentUserId) {
    final messages = _messageCache[matchId] ?? [];
    return messages
        .where((msg) => !msg.isFromCurrentUser && !msg.isRead)
        .length;
  }

  /// 메시지 동기화 (오프라인에서 온라인 전환 시)
  Future<void> syncMessages(String matchId, String currentUserId) async {
    try {
      Logger.log('메시지 동기화 시작: $matchId', name: 'AWSChatService');
      
      // 로컬 캐시된 메시지 중 전송 실패한 것들 재시도
      final cachedMessages = _messageCache[matchId] ?? [];
      final failedMessages = cachedMessages
          .where((msg) => msg.status == MessageStatus.failed && msg.localId != null)
          .toList();
      
      for (final message in failedMessages) {
        await resendMessage(matchId, message.localId!);
      }
      
      // 서버에서 최신 메시지 가져와서 동기화
      final serverMessages = await getMessages(
        matchId: matchId,
        currentUserId: currentUserId,
      );
      
      // 캐시 업데이트
      _messageCache[matchId] = serverMessages;
      
      // 실시간 구독자에게 동기화된 메시지 알림
      final controller = _messageControllers[matchId];
      if (controller != null && !controller.isClosed) {
        for (final message in serverMessages.take(5)) { // 최근 5개만
          controller.add(message);
        }
      }
      
      Logger.log('메시지 동기화 완료: $matchId (${serverMessages.length}개)', name: 'AWSChatService');
    } catch (e) {
      Logger.error('메시지 동기화 오류', error: e, name: 'AWSChatService');
    }
  }
  
  /// 오프라인 메시지 저장
  Future<void> saveOfflineMessage(MessageModel message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'offline_messages_${message.matchId}';
      
      // 기존 오프라인 메시지 목록 가져오기
      final existingMessagesJson = prefs.getStringList(key) ?? [];
      final existingMessages = existingMessagesJson
          .map((json) => MessageModel.fromJson(Map<String, dynamic>.from(jsonDecode(json))))
          .toList();
      
      // 중복 확인
      final isDuplicate = existingMessages.any((msg) => 
          msg.messageId == message.messageId || 
          (msg.localId != null && msg.localId == message.localId));
      
      if (!isDuplicate) {
        existingMessages.add(message);
        
        // 최대 100개까지만 저장 (오래된 것부터 삭제)
        if (existingMessages.length > 100) {
          existingMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          existingMessages.removeRange(0, existingMessages.length - 100);
        }
        
        // JSON으로 변환해서 저장
        final messagesJson = existingMessages
            .map((msg) => jsonEncode(msg.toJson()))
            .toList();
        
        await prefs.setStringList(key, messagesJson);
        Logger.log('오프라인 메시지 저장: ${message.messageId}', name: 'AWSChatService');
      }
    } catch (e) {
      Logger.error('오프라인 메시지 저장 오류', error: e, name: 'AWSChatService');
    }
  }
  
  /// 오프라인 메시지 로드
  Future<List<MessageModel>> loadOfflineMessages(String matchId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'offline_messages_$matchId';
      
      final messagesJson = prefs.getStringList(key) ?? [];
      final messages = messagesJson
          .map((json) => MessageModel.fromJson(Map<String, dynamic>.from(jsonDecode(json))))
          .toList();
      
      Logger.log('오프라인 메시지 로드: $matchId (${messages.length}개)', name: 'AWSChatService');
      return messages;
    } catch (e) {
      Logger.error('오프라인 메시지 로드 오류', error: e, name: 'AWSChatService');
      return [];
    }
  }
  
  /// 오프라인 메시지 삭제
  Future<void> clearOfflineMessages(String matchId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'offline_messages_$matchId';
      await prefs.remove(key);
      Logger.log('오프라인 메시지 삭제: $matchId', name: 'AWSChatService');
    } catch (e) {
      Logger.error('오프라인 메시지 삭제 오류', error: e, name: 'AWSChatService');
    }
  }
  
  /// 메시지 배치 동기화 (대량 처리용)
  Future<void> batchSyncMessages(List<String> matchIds, String currentUserId) async {
    try {
      Logger.log('배치 메시지 동기화 시작: ${matchIds.length}개 채팅방', name: 'AWSChatService');
      
      for (final matchId in matchIds) {
        await syncMessages(matchId, currentUserId);
        // 과부하 방지를 위한 딜레이
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      Logger.log('배치 메시지 동기화 완료', name: 'AWSChatService');
    } catch (e) {
      Logger.error('배치 메시지 동기화 오류', error: e, name: 'AWSChatService');
    }
  }
  
  /// 온라인 상태 관리 (향후 확장용)
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation UpdateUserOnlineStatus(\$input: UpdateUserInput!) {
            updateUser(input: \$input) {
              id
              isOnline
              lastSeenAt
            }
          }
        ''',
        variables: {
          'input': {
            'id': userId,
            'isOnline': isOnline,
            'lastSeenAt': DateTime.now().toIso8601String(),
          }
        },
      );

      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      Logger.error('온라인 상태 업데이트 오류', error: e, name: 'AWSChatService');
    }
  }

}