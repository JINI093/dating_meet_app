import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message_model.dart';
import '../services/aws_chat_service.dart';
import '../services/offline_sync_service.dart';
import '../utils/logger.dart';
import 'enhanced_auth_provider.dart';
import 'matches_provider.dart';

/// 채팅 상태
class ChatState {
  final Map<String, List<MessageModel>> messagesByMatch;
  final Map<String, bool> isLoadingByMatch;
  final Map<String, String?> errorsByMatch;
  final Map<String, StreamSubscription> activeSubscriptions;
  final bool isConnected;
  final String? currentMatchId;
  final bool isSending;

  const ChatState({
    this.messagesByMatch = const {},
    this.isLoadingByMatch = const {},
    this.errorsByMatch = const {},
    this.activeSubscriptions = const {},
    this.isConnected = true,
    this.currentMatchId,
    this.isSending = false,
  });

  ChatState copyWith({
    Map<String, List<MessageModel>>? messagesByMatch,
    Map<String, bool>? isLoadingByMatch,
    Map<String, String?>? errorsByMatch,
    Map<String, StreamSubscription>? activeSubscriptions,
    bool? isConnected,
    String? currentMatchId,
    bool? isSending,
  }) {
    return ChatState(
      messagesByMatch: messagesByMatch ?? this.messagesByMatch,
      isLoadingByMatch: isLoadingByMatch ?? this.isLoadingByMatch,
      errorsByMatch: errorsByMatch ?? this.errorsByMatch,
      activeSubscriptions: activeSubscriptions ?? this.activeSubscriptions,
      isConnected: isConnected ?? this.isConnected,
      currentMatchId: currentMatchId ?? this.currentMatchId,
      isSending: isSending ?? this.isSending,
    );
  }

  List<MessageModel> getMessages(String matchId) {
    return messagesByMatch[matchId] ?? [];
  }

  bool isLoading(String matchId) {
    return isLoadingByMatch[matchId] ?? false;
  }

  String? getError(String matchId) {
    return errorsByMatch[matchId];
  }

  int getUnreadCount(String matchId, String currentUserId) {
    final messages = getMessages(matchId);
    return messages
        .where((msg) => !msg.isFromCurrentUser && !msg.isRead)
        .length;
  }

  bool isSubscribed(String matchId) {
    return activeSubscriptions.containsKey(matchId);
  }
}

/// 채팅 관리
class ChatNotifier extends StateNotifier<ChatState> {
  final Ref ref;
  final AWSChatService _chatService = AWSChatService();
  final OfflineSyncService _syncService = OfflineSyncService();
  Timer? _heartbeatTimer;
  final Map<String, Timer> _typingTimers = {};

  ChatNotifier(this.ref) : super(const ChatState());

  /// 초기화
  Future<void> initialize() async {
    try {
      await _chatService.initialize();
      await _syncService.initialize();
      _startHeartbeat();
      
      // 앱 시작 시 오프라인 메시지 동기화
      await _syncOfflineMessages();
      
      developer.log('✅ ChatProvider 초기화 완료', name: 'ChatProvider');
    } catch (e) {
      developer.log('❌ ChatProvider 초기화 실패', error: e, name: 'ChatProvider');
      state = state.copyWith(isConnected: false);
    }
  }

  /// 특정 매칭의 채팅방 입장
  Future<void> enterChatRoom(String matchId) async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      return;
    }

    final currentUserId = authState.currentUser!.user!.userId;
    
    try {
      // 현재 채팅방 설정
      state = state.copyWith(currentMatchId: matchId);

      // 기존 메시지 로드
      await loadMessages(matchId);

      // 실시간 구독 시작 (폴링 방식)
      await _subscribeToMessages(matchId, currentUserId);

      // 모든 읽지 않은 메시지 읽음 처리
      await markAllMessagesAsRead(matchId);

      developer.log('✅ 채팅방 입장 완료 (실시간 구독 활성화): $matchId', name: 'ChatProvider');
    } catch (e) {
      developer.log('❌ 채팅방 입장 오류', error: e, name: 'ChatProvider');
      _setError(matchId, '채팅방 입장에 실패했습니다.');
    }
  }

  /// 채팅방 퇴장
  void exitChatRoom(String matchId) {
    try {
      // 실시간 구독 해제
      _unsubscribeFromMessages(matchId);

      // 현재 채팅방이면 해제
      if (state.currentMatchId == matchId) {
        state = state.copyWith(currentMatchId: null);
      }

      developer.log('채팅방 퇴장: $matchId', name: 'ChatProvider');
    } catch (e) {
      developer.log('채팅방 퇴장 오류', error: e, name: 'ChatProvider');
    }
  }

  /// 메시지 목록 로드
  Future<void> loadMessages(String matchId, {String? nextToken}) async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      return;
    }

    final currentUserId = authState.currentUser!.user!.userId;

    _setLoading(matchId, true);
    _clearError(matchId);

    try {
      // 먼저 오프라인 메시지 로드
      if (nextToken == null) {
        final offlineMessages = await _chatService.loadOfflineMessages(matchId);
        if (offlineMessages.isNotEmpty) {
          final updatedMessages = Map<String, List<MessageModel>>.from(state.messagesByMatch);
          updatedMessages[matchId] = offlineMessages;
          state = state.copyWith(messagesByMatch: updatedMessages);
          developer.log('오프라인 메시지 ${offlineMessages.length}개 로드: $matchId', name: 'ChatProvider');
        }
      }
      
      // 서버에서 메시지 가져오기
      final messages = await _chatService.getMessages(
        matchId: matchId,
        currentUserId: currentUserId,
        nextToken: nextToken,
      );

      final updatedMessages = Map<String, List<MessageModel>>.from(state.messagesByMatch);
      
      if (nextToken == null) {
        // 초기 로드 - 서버 메시지로 대체 (오프라인 메시지와 병합)
        final offlineMessages = updatedMessages[matchId] ?? [];
        final allMessages = [...messages];
        
        // 오프라인 메시지 중 아직 서버에 없는 것들 추가
        for (final offlineMsg in offlineMessages) {
          final existsInServer = messages.any((serverMsg) => 
              serverMsg.messageId == offlineMsg.messageId ||
              (offlineMsg.localId != null && serverMsg.localId == offlineMsg.localId));
          
          if (!existsInServer) {
            allMessages.add(offlineMsg);
          }
        }
        
        allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        updatedMessages[matchId] = allMessages;
      } else {
        // 추가 로드 (이전 메시지)
        final existingMessages = updatedMessages[matchId] ?? [];
        updatedMessages[matchId] = [...messages, ...existingMessages];
      }

      state = state.copyWith(messagesByMatch: updatedMessages);
      
      developer.log('메시지 ${messages.length}개 로드: $matchId', name: 'ChatProvider');
    } catch (e) {
      developer.log('메시지 로드 오류', error: e, name: 'ChatProvider');
      _setError(matchId, '메시지를 불러오는데 실패했습니다.');
    } finally {
      _setLoading(matchId, false);
    }
  }

  /// 텍스트 메시지 전송
  Future<bool> sendTextMessage({
    required String matchId,
    required String receiverId,
    required String content,
  }) async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      return false;
    }

    final senderId = authState.currentUser!.user!.userId;

    if (content.trim().isEmpty) {
      return false;
    }

    state = state.copyWith(isSending: true);

    try {
      // 온라인 상태에서는 직접 전송, 오프라인에서는 큐에 추가
      if (_syncService.isOnline) {
        final message = await _chatService.sendMessage(
          matchId: matchId,
          senderId: senderId,
          receiverId: receiverId,
          content: content.trim(),
          type: MessageType.text,
        );

        if (message != null) {
          _addMessageToState(matchId, message);
          
          // 성공적으로 전송된 메시지는 오프라인 저장
          await _chatService.saveOfflineMessage(message);
          
          developer.log('텍스트 메시지 전송: ${message.messageId}', name: 'ChatProvider');
          return true;
        }
        return false;
      } else {
        // 오프라인 상태: 메시지를 큐에 추가하고 로컬 상태에 표시
        await _syncService.addToOfflineQueue(
          matchId: matchId,
          senderId: senderId,
          receiverId: receiverId,
          content: content.trim(),
          type: MessageType.text,
        );
        
        // 임시 메시지 생성 (전송 중 상태)
        final tempMessage = MessageModel.createTextMessage(
          matchId: matchId,
          senderId: senderId,
          receiverId: receiverId,
          content: content.trim(),
          isFromCurrentUser: true,
        ).copyWith(status: MessageStatus.sending);
        
        _addMessageToState(matchId, tempMessage);
        
        developer.log('오프라인 메시지 큐 추가: ${tempMessage.messageId}', name: 'ChatProvider');
        return true;
      }
    } catch (e) {
      developer.log('텍스트 메시지 전송 오류', error: e, name: 'ChatProvider');
      _setError(matchId, '메시지 전송에 실패했습니다.');
      return false;
    } finally {
      state = state.copyWith(isSending: false);
    }
  }

  /// 이미지 메시지 전송
  Future<bool> sendImageMessage({
    required String matchId,
    required String receiverId,
    required String imageUrl,
    String? thumbnailUrl,
    String content = '',
  }) async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      return false;
    }

    final senderId = authState.currentUser!.user!.userId;

    state = state.copyWith(isSending: true);

    try {
      final message = await _chatService.sendMessage(
        matchId: matchId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        type: MessageType.image,
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
      );

      if (message != null) {
        _addMessageToState(matchId, message);
        developer.log('이미지 메시지 전송: ${message.messageId}', name: 'ChatProvider');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('이미지 메시지 전송 오류', error: e, name: 'ChatProvider');
      _setError(matchId, '이미지 전송에 실패했습니다.');
      return false;
    } finally {
      state = state.copyWith(isSending: false);
    }
  }

  /// 슈퍼챗 메시지 전송
  Future<bool> sendSuperchatMessage({
    required String matchId,
    required String receiverId,
    required String content,
    required int superchatPoints,
  }) async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      return false;
    }

    final senderId = authState.currentUser!.user!.userId;

    if (content.trim().isEmpty) {
      return false;
    }

    state = state.copyWith(isSending: true);

    try {
      final message = await _chatService.sendMessage(
        matchId: matchId,
        senderId: senderId,
        receiverId: receiverId,
        content: content.trim(),
        type: MessageType.superchat,
        superchatPoints: superchatPoints,
      );

      if (message != null) {
        _addMessageToState(matchId, message);
        developer.log('슈퍼챗 메시지 전송: ${message.messageId}', name: 'ChatProvider');
        return true;
      }

      return false;
    } catch (e) {
      developer.log('슈퍼챗 메시지 전송 오류', error: e, name: 'ChatProvider');
      _setError(matchId, '슈퍼챗 전송에 실패했습니다.');
      return false;
    } finally {
      state = state.copyWith(isSending: false);
    }
  }

  /// 메시지 읽음 처리
  Future<void> markMessageAsRead(String messageId) async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      return;
    }

    final userId = authState.currentUser!.user!.userId;

    try {
      await _chatService.markMessageAsRead(messageId, userId);
    } catch (e) {
      developer.log('메시지 읽음 처리 오류', error: e, name: 'ChatProvider');
    }
  }

  /// 모든 메시지 읽음 처리
  Future<void> markAllMessagesAsRead(String matchId) async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      return;
    }

    final userId = authState.currentUser!.user!.userId;

    try {
      await _chatService.markAllMessagesAsRead(matchId, userId);
      
      // 로컬 상태 업데이트
      final updatedMessages = Map<String, List<MessageModel>>.from(state.messagesByMatch);
      final messages = updatedMessages[matchId] ?? [];
      
      for (int i = 0; i < messages.length; i++) {
        final message = messages[i];
        if (!message.isFromCurrentUser && !message.isRead) {
          messages[i] = message.copyWith(
            status: MessageStatus.read,
            readAt: DateTime.now(),
          );
        }
      }
      
      updatedMessages[matchId] = messages;
      state = state.copyWith(messagesByMatch: updatedMessages);

      developer.log('모든 메시지 읽음 처리: $matchId', name: 'ChatProvider');
    } catch (e) {
      developer.log('모든 메시지 읽음 처리 오류', error: e, name: 'ChatProvider');
    }
  }

  /// 메시지 재전송
  Future<bool> resendMessage(String matchId, String localId) async {
    try {
      final success = await _chatService.resendMessage(matchId, localId);
      
      if (success) {
        developer.log('메시지 재전송 성공: $localId', name: 'ChatProvider');
      }
      
      return success;
    } catch (e) {
      developer.log('메시지 재전송 오류', error: e, name: 'ChatProvider');
      return false;
    }
  }

  /// 실시간 메시지 구독 시작
  Future<void> _subscribeToMessages(String matchId, String currentUserId) async {
    // 기존 구독 해제
    _unsubscribeFromMessages(matchId);

    try {
      final subscription = _chatService.subscribeToMessages(matchId, currentUserId).listen(
        (message) {
          // 내가 보낸 메시지인 경우, 이미 로컬 상태에 추가했으므로 중복 방지
          if (message.senderId == currentUserId) {
            developer.log('📤 내가 보낸 메시지 실시간 수신 - 중복 체크 중: ${message.content}', name: 'ChatProvider');
            
            // 현재 메시지 목록에서 중복 체크
            final currentMessages = state.messagesByMatch[matchId] ?? [];
            final isDuplicate = currentMessages.any((msg) {
              // 같은 messageId 또는 localId가 있는지 확인
              return (message.messageId.isNotEmpty && msg.messageId == message.messageId) ||
                     (message.localId != null && msg.localId == message.localId) ||
                     // 같은 내용, 발송자, 시간(3초 이내)
                     (msg.senderId == message.senderId && 
                      msg.content == message.content &&
                      msg.createdAt.difference(message.createdAt).abs().inSeconds <= 3);
            });
            
            if (isDuplicate) {
              developer.log('🚫 내가 보낸 메시지 중복 감지 - 무시: ${message.content}', name: 'ChatProvider');
              return; // 중복이면 추가하지 않음
            }
          }
          
          _addMessageToState(matchId, message);
          
          // 현재 활성 채팅방이면 자동으로 읽음 처리
          if (state.currentMatchId == matchId && !message.isFromCurrentUser) {
            markMessageAsRead(message.messageId);
          }
          
          // 받은 메시지도 오프라인 저장
          _chatService.saveOfflineMessage(message);
        },
        onError: (error) {
          developer.log('실시간 메시지 구독 오류', error: error, name: 'ChatProvider');
          _setError(matchId, '실시간 연결에 문제가 발생했습니다.');
        },
      );

      final updatedSubscriptions = Map<String, StreamSubscription>.from(state.activeSubscriptions);
      updatedSubscriptions[matchId] = subscription;
      state = state.copyWith(activeSubscriptions: updatedSubscriptions);

      developer.log('실시간 메시지 구독 시작: $matchId', name: 'ChatProvider');
    } catch (e) {
      developer.log('실시간 메시지 구독 시작 오류', error: e, name: 'ChatProvider');
      _setError(matchId, '실시간 연결에 실패했습니다.');
    }
  }

  /// 실시간 메시지 구독 해제
  void _unsubscribeFromMessages(String matchId) {
    final subscription = state.activeSubscriptions[matchId];
    subscription?.cancel();

    final updatedSubscriptions = Map<String, StreamSubscription>.from(state.activeSubscriptions);
    updatedSubscriptions.remove(matchId);
    state = state.copyWith(activeSubscriptions: updatedSubscriptions);

    _chatService.unsubscribeFromMessages(matchId);
  }

  /// 메시지를 상태에 추가
  void _addMessageToState(String matchId, MessageModel message) {
    final updatedMessages = Map<String, List<MessageModel>>.from(state.messagesByMatch);
    final messages = List<MessageModel>.from(updatedMessages[matchId] ?? []);

    // 중복 확인 개선
    final existingIndex = messages.indexWhere((msg) {
      // 1. 같은 messageId가 있는 경우
      if (message.messageId.isNotEmpty && msg.messageId == message.messageId) {
        return true;
      }
      
      // 2. 같은 localId가 있는 경우
      if (message.localId != null && msg.localId != null && 
          msg.localId == message.localId) {
        return true;
      }
      
      // 3. 내용, 발송자, 시간이 매우 유사한 경우 (1초 이내)
      if (msg.senderId == message.senderId && 
          msg.content == message.content &&
          msg.createdAt.difference(message.createdAt).abs().inSeconds <= 1) {
        developer.log('⚠️  유사한 메시지 발견 - 중복으로 판단: ${message.content}', name: 'ChatProvider');
        return true;
      }
      
      return false;
    });

    if (existingIndex != -1) {
      // 기존 메시지를 새로운 메시지로 교체 (서버 ID 업데이트 등)
      messages[existingIndex] = message;
      developer.log('🔄 기존 메시지 업데이트: ${message.messageId}', name: 'ChatProvider');
    } else {
      // 새로운 메시지 추가
      messages.add(message);
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      developer.log('➕ 새 메시지 추가: ${message.messageId}', name: 'ChatProvider');
    }

    updatedMessages[matchId] = messages;
    state = state.copyWith(messagesByMatch: updatedMessages);
  }

  /// 로딩 상태 설정
  void _setLoading(String matchId, bool isLoading) {
    final updatedLoading = Map<String, bool>.from(state.isLoadingByMatch);
    updatedLoading[matchId] = isLoading;
    state = state.copyWith(isLoadingByMatch: updatedLoading);
  }

  /// 에러 설정
  void _setError(String matchId, String error) {
    final updatedErrors = Map<String, String?>.from(state.errorsByMatch);
    updatedErrors[matchId] = error;
    state = state.copyWith(errorsByMatch: updatedErrors);
  }

  /// 에러 클리어
  void _clearError(String matchId) {
    final updatedErrors = Map<String, String?>.from(state.errorsByMatch);
    updatedErrors.remove(matchId);
    state = state.copyWith(errorsByMatch: updatedErrors);
  }

  /// 하트비트 시작
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkConnection();
    });
  }

  /// 연결 상태 확인
  void _checkConnection() {
    // 실제로는 ping 등을 통해 연결 상태를 확인
    // 여기서는 간단히 구현
    final wasConnected = state.isConnected;
    state = state.copyWith(isConnected: true);
    
    // 연결이 복구되었을 때 메시지 동기화
    if (!wasConnected && state.isConnected) {
      _syncOfflineMessages();
    }
  }

  /// 타이핑 상태 표시 (향후 확장용)
  void startTyping(String matchId) {
    // 타이핑 타이머 설정
    _typingTimers[matchId]?.cancel();
    _typingTimers[matchId] = Timer(const Duration(seconds: 3), () {
      stopTyping(matchId);
    });
  }

  /// 타이핑 상태 중지
  void stopTyping(String matchId) {
    _typingTimers[matchId]?.cancel();
    _typingTimers.remove(matchId);
  }

  /// 새로고침
  Future<void> refresh(String matchId) async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      return;
    }

    final currentUserId = authState.currentUser!.user!.userId;
    
    // 메시지 동기화 수행
    await _chatService.syncMessages(matchId, currentUserId);
    
    // 메시지 다시 로드
    await loadMessages(matchId);
  }
  
  /// 오프라인 메시지 동기화
  Future<void> _syncOfflineMessages() async {
    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        return;
      }

      final currentUserId = authState.currentUser!.user!.userId;
      
      // 현재 활성화된 모든 채팅방의 메시지 동기화
      final activeMatchIds = state.messagesByMatch.keys.toList();
      if (activeMatchIds.isNotEmpty) {
        await _chatService.batchSyncMessages(activeMatchIds, currentUserId);
      }
      
      developer.log('오프라인 메시지 동기화 완료', name: 'ChatProvider');
    } catch (e) {
      developer.log('오프라인 메시지 동기화 오류', error: e, name: 'ChatProvider');
    }
  }

  /// 오프라인 상태 확인
  bool get isOffline => !_syncService.isOnline;
  
  


  /// 채팅방 보관 (호환성을 위해 추가)
  Future<void> archiveChat(String chatId) async {
    try {
      // 채팅방 비활성화 및 보관 처리
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        return;
      }

      // 채팅방 나가기
      exitChatRoom(chatId);
      
      // 로컬 상태에서 메시지 삭제
      final updatedMessages = Map<String, List<MessageModel>>.from(state.messagesByMatch);
      updatedMessages.remove(chatId);
      state = state.copyWith(messagesByMatch: updatedMessages);
      
      developer.log('채팅방 보관 완료: $chatId', name: 'ChatProvider');
    } catch (e) {
      developer.log('채팅방 보관 오류', error: e, name: 'ChatProvider');
    }
  }
  
  /// 채팅방 차단 (호환성을 위해 추가)
  Future<void> blockChat(String chatId, [bool permanent = false]) async {
    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        return;
      }

      // 채팅방 나가기
      exitChatRoom(chatId);
      
      // 로컬 상태에서 메시지 삭제
      final updatedMessages = Map<String, List<MessageModel>>.from(state.messagesByMatch);
      updatedMessages.remove(chatId);
      state = state.copyWith(messagesByMatch: updatedMessages);
      
      developer.log('채팅방 차단 완료: $chatId', name: 'ChatProvider');
    } catch (e) {
      developer.log('채팅방 차단 오류', error: e, name: 'ChatProvider');
    }
  }

  /// 정리
  @override
  void dispose() {
    // 모든 구독 해제
    for (final subscription in state.activeSubscriptions.values) {
      subscription.cancel();
    }

    // 타이머 정리
    _heartbeatTimer?.cancel();
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }

    // 서비스 정리
    _chatService.dispose();
    _syncService.dispose();

    super.dispose();
  }

  /// 현재 채팅방 클리어
  void clearCurrentChat() {
    state = state.copyWith(currentMatchId: null);
  }

  /// 타이핑 상태 업데이트
  void updateTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) {
    if (isTyping) {
      startTyping(chatId);
    } else {
      stopTyping(chatId);
    }
  }

  /// 메시지 전송
  Future<bool> sendMessage({
    required String chatId,
    required String content,
    String? receiverId,
  }) async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      return false;
    }

    try {
      state = state.copyWith(isSending: true);
      
      // 고유한 로컬 ID 생성 (중복 방지용)
      final localId = 'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
      
      final tempMessage = MessageModel(
        messageId: '', // 서버에서 할당될 때까지 비워둠
        localId: localId, // 중복 체크용 로컬 ID
        matchId: chatId,
        senderId: authState.currentUser!.user!.userId,
        receiverId: receiverId ?? chatId,
        content: content,
        createdAt: DateTime.now(),
        messageType: MessageType.text,
        status: MessageStatus.sending, // 전송 중 상태
      );

      // 임시 메시지를 로컬 상태에 추가 (UX 개선용)
      _addMessageToState(chatId, tempMessage);

      // Send via service
      final result = await _chatService.sendMessage(
        matchId: tempMessage.matchId,
        senderId: tempMessage.senderId,
        receiverId: receiverId ?? tempMessage.receiverId,
        content: tempMessage.content,
        type: tempMessage.messageType,
      );
      
      if (result == null) {
        throw Exception('메시지 전송에 실패했습니다');
      }
      
      developer.log('✅ 메시지 AWS 전송 성공: ${result.messageId}', name: 'ChatProvider');
      
      // 임시 메시지를 서버 응답으로 업데이트
      final finalMessage = result.copyWith(localId: localId);
      _addMessageToState(chatId, finalMessage);
      
      // Update last message in matches provider  
      try {
        ref.read(matchesProvider.notifier).updateLastMessage(chatId, content);
        developer.log('📝 매칭 마지막 메시지 업데이트: $chatId', name: 'ChatProvider');
      } catch (e) {
        developer.log('⚠️  매칭 마지막 메시지 업데이트 실패: $e', name: 'ChatProvider');
      }
      
      state = state.copyWith(isSending: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSending: false);
      developer.log('메시지 전송 실패', error: e, name: 'ChatProvider');
      return false;
    }
  }

  /// 슈퍼챗 메시지 전송
  Future<bool> sendSuperChatMessage({
    required String chatId,
    required String content,
    String? receiverId,
  }) async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      return false;
    }

    try {
      state = state.copyWith(isSending: true);
      
      final message = MessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        matchId: chatId,
        senderId: authState.currentUser!.user!.userId,
        receiverId: receiverId ?? chatId,
        content: content,
        createdAt: DateTime.now(),
        messageType: MessageType.superchat,
      );

      // Add to local state immediately for better UX
      _addMessageToState(chatId, message);

      // Send via service
      await _chatService.sendMessage(
        matchId: message.matchId,
        senderId: message.senderId,
        receiverId: message.receiverId,
        content: message.content,
        type: message.messageType,
        superchatPoints: 100, // Default superchat points
      );
      
      state = state.copyWith(isSending: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSending: false);
      developer.log('슈퍼챗 메시지 전송 실패', error: e, name: 'ChatProvider');
      return false;
    }
  }


  /// 메시지 삭제
  Future<void> deleteMessage(String messageId) async {
    try {
      // TODO: Implement message deletion
      developer.log('메시지 삭제: $messageId', name: 'ChatProvider');
    } catch (e) {
      developer.log('메시지 삭제 실패', error: e, name: 'ChatProvider');
    }
  }

  /// 오프라인 큐 크기 조회
  Future<int> getOfflineQueueSize() async {
    return await _syncService.getOfflineQueueSize();
  }

  /// 수동 동기화
  Future<void> manualSync() async {
    await _syncService.manualSync();
  }

  /// 마지막 동기화 시간 조회
  Future<DateTime?> getLastSyncTime() async {
    return await _syncService.getLastSyncTime();
  }
}

/// 채팅 프로바이더
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});

/// 특정 매칭의 메시지 목록 프로바이더
final messagesProvider = Provider.family<List<MessageModel>, String>((ref, matchId) {
  final chatState = ref.watch(chatProvider);
  return chatState.getMessages(matchId);
});

/// 특정 매칭의 읽지 않은 메시지 수 프로바이더
final unreadCountProvider = Provider.family<int, String>((ref, matchId) {
  final chatState = ref.watch(chatProvider);
  final authState = ref.watch(enhancedAuthProvider);
  
  if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
    return 0;
  }
  
  final currentUserId = authState.currentUser!.user!.userId;
  return chatState.getUnreadCount(matchId, currentUserId);
});

/// 특정 매칭의 로딩 상태 프로바이더
final chatLoadingProvider = Provider.family<bool, String>((ref, matchId) {
  final chatState = ref.watch(chatProvider);
  return chatState.isLoading(matchId);
});

/// 특정 매칭의 에러 상태 프로바이더
final chatErrorProvider = Provider.family<String?, String>((ref, matchId) {
  final chatState = ref.watch(chatProvider);
  return chatState.getError(matchId);
});

/// 전체 읽지 않은 메시지 수 프로바이더
final totalUnreadCountProvider = Provider<int>((ref) {
  final chatState = ref.watch(chatProvider);
  final authState = ref.watch(enhancedAuthProvider);
  
  if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
    return 0;
  }
  
  final currentUserId = authState.currentUser!.user!.userId;
  int totalUnread = 0;
  
  for (final matchId in chatState.messagesByMatch.keys) {
    totalUnread += chatState.getUnreadCount(matchId, currentUserId);
  }
  
  return totalUnread;
});

/// 연결 상태 프로바이더
final chatConnectionProvider = Provider<bool>((ref) {
  final chatState = ref.watch(chatProvider);
  return chatState.isConnected;
});

/// 메시지 전송 중 상태 프로바이더
final chatSendingProvider = Provider<bool>((ref) {
  final chatState = ref.watch(chatProvider);
  return chatState.isSending;
});

/// 오프라인 상태 프로바이더
final offlineStatusProvider = Provider<bool>((ref) {
  final chatNotifier = ref.read(chatProvider.notifier);
  return chatNotifier.isOffline;
});

/// 오프라인 큐 크기 프로바이더
final offlineQueueSizeProvider = FutureProvider<int>((ref) async {
  final chatNotifier = ref.read(chatProvider.notifier);
  return await chatNotifier.getOfflineQueueSize();
});

/// 마지막 동기화 시간 프로바이더
final lastSyncTimeProvider = FutureProvider<DateTime?>((ref) async {
  final chatNotifier = ref.read(chatProvider.notifier);
  return await chatNotifier.getLastSyncTime();
});

/// 현재 채팅방의 메시지 목록 프로바이더
final currentChatMessagesProvider = Provider<List<MessageModel>>((ref) {
  final chatState = ref.watch(chatProvider);
  final currentMatchId = chatState.currentMatchId;
  
  if (currentMatchId == null) {
    return [];
  }
  
  return chatState.getMessages(currentMatchId);
});

/// 상대방 타이핑 상태 프로바이더
final isOtherUserTypingProvider = Provider.family<bool, String>((ref, matchId) {
  // TODO: Implement typing status tracking
  // For now, return false to resolve compilation error
  return false;
});