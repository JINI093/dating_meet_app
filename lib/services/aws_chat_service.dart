import 'dart:async';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/message_model.dart';
import '../models/match_model.dart';
import '../utils/logger.dart';

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

  /// 특정 매칭의 메시지 목록 조회
  Future<List<MessageModel>> getMessages({
    required String matchId,
    required String currentUserId,
    int limit = 50,
    String? nextToken,
  }) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          query GetMessages(\$matchId: String!, \$limit: Int, \$nextToken: String) {
            messagesByMatchId(
              matchId: \$matchId,
              limit: \$limit,
              nextToken: \$nextToken,
              sortDirection: DESC
            ) {
              items {
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
              nextToken
            }
          }
        ''',
        variables: {
          'matchId': matchId,
          'limit': limit,
          'nextToken': nextToken,
        },
      );

      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception('메시지 조회 실패: ${response.errors.first.message}');
      }

      final messages = <MessageModel>[];
      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final items = data['messagesByMatchId']?['items'] as List?;
        
        if (items != null) {
          for (final item in items) {
            final messageData = item as Map<String, dynamic>;
            final message = MessageModel.fromJson(messageData).copyWith(
              isFromCurrentUser: messageData['senderId'] == currentUserId,
            );
            messages.add(message);
          }
        }
      }

      // 최신순으로 정렬 (UI에서 표시하기 위해 역순으로)
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      // 캐시에 저장
      _messageCache[matchId] = messages;
      
      Logger.log('메시지 ${messages.length}개 조회: $matchId', name: 'AWSChatService');
      return messages;
    } catch (e) {
      Logger.error('메시지 조회 오류', error: e, name: 'AWSChatService');
      return _messageCache[matchId] ?? [];
    }
  }

  /// 메시지 전송
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

      // 서버로 전송
      final messageData = {
        'matchId': matchId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'messageType': type.name.toUpperCase(),
        'status': 'SENT',
        'createdAt': DateTime.now().toIso8601String(),
        'metadata': metadata,
      };

      // 타입별 추가 데이터
      if (type == MessageType.image) {
        messageData['imageUrl'] = imageUrl;
        messageData['thumbnailUrl'] = thumbnailUrl;
      } else if (type == MessageType.superchat) {
        messageData['superchatPoints'] = superchatPoints;
      }

      final request = GraphQLRequest<String>(
        document: '''
          mutation CreateMessage(\$input: CreateMessageInput!) {
            createMessage(input: \$input) {
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
        variables: {'input': messageData},
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        // 전송 실패 처리
        final failedMessage = tempMessage.copyWith(status: MessageStatus.failed);
        _updateMessageInCache(matchId, localId, failedMessage);
        _notifyMessageUpdate(matchId, failedMessage);
        _pendingMessages.remove(localId);
        
        throw Exception('메시지 전송 실패: ${response.errors.first.message}');
      }

      // 전송 성공 처리
      if (response.data != null) {
        final data = _parseGraphQLResponse(response.data!);
        final createdMessage = data['createMessage'];
        
        if (createdMessage != null) {
          final serverMessage = MessageModel.fromJson(createdMessage).copyWith(
            isFromCurrentUser: true,
            localId: localId,
          );
          
          // 로컬 메시지를 서버 메시지로 교체
          _updateMessageInCache(matchId, localId, serverMessage);
          _notifyMessageUpdate(matchId, serverMessage);
          _pendingMessages.remove(localId);

          // 매칭의 마지막 메시지 정보 업데이트
          await _updateMatchLastMessage(matchId, serverMessage);

          Logger.log('메시지 전송 성공: ${serverMessage.messageId}', name: 'AWSChatService');
          return serverMessage;
        }
      }

      return null;
    } catch (e) {
      Logger.error('메시지 전송 오류', error: e, name: 'AWSChatService');
      
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

  /// 실시간 메시지 구독 시작
  Stream<MessageModel> subscribeToMessages(String matchId, String currentUserId) {
    // 기존 구독이 있으면 해제
    unsubscribeFromMessages(matchId);

    // 새 스트림 컨트롤러 생성
    final controller = StreamController<MessageModel>.broadcast();
    _messageControllers[matchId] = controller;

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
  }

  /// 실시간 메시지 구독 해제
  void unsubscribeFromMessages(String matchId) {
    _subscriptions[matchId]?.cancel();
    _subscriptions.remove(matchId);
    
    _messageControllers[matchId]?.close();
    _messageControllers.remove(matchId);
    
    Logger.log('실시간 메시지 구독 해제: $matchId', name: 'AWSChatService');
  }

  /// 메시지 읽음 처리
  Future<bool> markMessageAsRead(String messageId, String userId) async {
    return await _markMessageAsRead(messageId, userId);
  }

  /// 메시지 읽음 처리 (내부)
  Future<bool> _markMessageAsRead(String messageId, String userId) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation MarkMessageAsRead(\$input: UpdateMessageInput!) {
            updateMessage(input: \$input) {
              messageId
              status
              readAt
            }
          }
        ''',
        variables: {
          'input': {
            'messageId': messageId,
            'status': 'READ',
            'readAt': DateTime.now().toIso8601String(),
          }
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        Logger.error('메시지 읽음 처리 실패: ${response.errors.first.message}', name: 'AWSChatService');
        return false;
      }

      Logger.log('메시지 읽음 처리: $messageId', name: 'AWSChatService');
      return true;
    } catch (e) {
      Logger.error('메시지 읽음 처리 오류', error: e, name: 'AWSChatService');
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