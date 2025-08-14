import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:screenshot/screenshot.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../models/match_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/enhanced_auth_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input_field.dart';
import '../../widgets/chat/typing_indicator.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final MatchModel match;
  final String? chatId;

  const ChatRoomScreen({
    super.key,
    required this.match,
    this.chatId,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isComposing = false;
  late String _chatId;

  @override
  void initState() {
    super.initState();
    _chatId = widget.chatId ?? widget.match.id;
    _messageController.addListener(_onTextChanged);
    
    // Load chat room when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(chatProvider.notifier).enterChatRoom(widget.match.id);
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged); // 리스너 해제
    // Clear current chat before disposing controllers
    try {
      ref.read(chatProvider.notifier).clearCurrentChat();
    } catch (e) {
      // Ignore error if ref is already disposed
    }
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!mounted) return; // <- 이 줄 추가!
    final isComposing = _messageController.text.isNotEmpty;
    if (_isComposing != isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
      
      // Update typing status
      if (!mounted) return; // ref 사용 전에도 체크
      final authState = ref.read(enhancedAuthProvider);
      if (authState.isSignedIn && authState.currentUser?.user?.userId != null) {
        ref.read(chatProvider.notifier).updateTypingStatus(
          chatId: _chatId,
          userId: authState.currentUser!.user!.userId,
          isTyping: isComposing,
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || !mounted) return;
    
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });
    
    // Update typing status
    if (mounted) {
      final authState = ref.read(enhancedAuthProvider);
      if (authState.isSignedIn && authState.currentUser?.user?.userId != null) {
        ref.read(chatProvider.notifier).updateTypingStatus(
          chatId: _chatId,
          userId: authState.currentUser!.user!.userId,
          isTyping: false,
        );
      }
    }
    
    // Send message
    if (mounted) {
      final success = await ref.read(chatProvider.notifier).sendMessage(
        chatId: _chatId,
        content: text,
        receiverId: widget.match.profile.id,
      );
      
      if (success && mounted) {
        // Scroll to bottom after sending
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToBottom();
          }
        });
      }
    }
  }

  Future<void> _sendImageMessage() async {
    if (!mounted) return;
    
    // TODO: Implement image picker
    // For now, simulate sending an image
    final success = await ref.read(chatProvider.notifier).sendImageMessage(
      matchId: _chatId,
      receiverId: widget.match.matchedUserProfile?.id ?? '',
      imageUrl: 'assets/images/placeholder.jpg',
      content: '사진 보내기',
    );
    
    if (success && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToBottom();
        }
      });
    }
  }

  Future<void> _sendSuperChatMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || !mounted) return;
    
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });
    
    if (mounted) {
      final success = await ref.read(chatProvider.notifier).sendSuperChatMessage(
        chatId: _chatId,
        content: text,
        receiverId: widget.match.profile.id,
      );
      
      if (success && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToBottom();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(currentChatMessagesProvider);
    final isOtherUserTyping = ref.watch(isOtherUserTypingProvider(_chatId));

    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // Messages List
            Expanded(
              child: _buildMessagesList(messages, isOtherUserTyping),
            ),
            
            // Input Field
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 1,
      shadowColor: AppColors.cardShadow,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(AppDimensions.spacing8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            border: Border.all(
              color: AppColors.cardBorder,
              width: AppDimensions.borderNormal,
            ),
          ),
          child: const Icon(
            CupertinoIcons.back,
            color: AppColors.textPrimary,
            size: AppDimensions.iconM,
          ),
        ),
      ),
      title: GestureDetector(
        onTap: () => _showProfileDetails(),
        child: Row(
          children: [
            // Profile Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 40,
                height: 40,
                child: _buildProfileImage(),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Name and Age
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.match.profile.name}, ${widget.match.profile.age}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Report Button
        GestureDetector(
          onTap: _showReportDialog,
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/icons/siren.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  color: Colors.black,
                  size: 24,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    final imageUrl = widget.match.profile.profileImages.isNotEmpty 
        ? widget.match.profile.profileImages.first 
        : '';

    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surface,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholderImage(),
      );
    } else {
      return Image.asset(
        imageUrl.isNotEmpty ? imageUrl : 'assets/images/default_profile.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          CupertinoIcons.person_circle,
          size: 20,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildMessagesList(List<MessageModel> messages, bool isOtherUserTyping) {
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: messages.length + (isOtherUserTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isOtherUserTyping) {
          return Padding(
            padding: const EdgeInsets.only(top: AppDimensions.spacing8),
            child: TypingIndicator(
              profileImage: widget.match.profile.profileImages.isNotEmpty
                  ? widget.match.profile.profileImages.first
                  : '',
            ),
          );
        }
        
        final message = messages[index];
        final authState = ref.watch(enhancedAuthProvider);
        final currentUserId = authState.currentUser?.user?.userId;
        final isMyMessage = currentUserId != null && message.senderId == currentUserId;
        final showDateHeader = _shouldShowDateHeader(index, messages);
        
        return Column(
          children: [
            if (showDateHeader) _buildDateHeader(message.createdAt),
            MessageBubble(
              message: _convertToUiMessage(message),
              isMyMessage: isMyMessage,
              showAvatar: !isMyMessage,
              profileImage: !isMyMessage && widget.match.profile.profileImages.isNotEmpty
                  ? widget.match.profile.profileImages.first
                  : '',
              onDelete: isMyMessage ? () => _deleteMessage(_convertToUiMessage(message)) : null,
              onReply: () => _replyToMessage(_convertToUiMessage(message)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.cardBorder,
                width: 2,
              ),
            ),
            child: const Icon(
              CupertinoIcons.chat_bubble_2,
              size: 50,
              color: AppColors.textHint,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          Text(
            '대화를 시작해보세요!',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing8),
          
          Text(
            '${widget.match.profile.name}, ${widget.match.profile.age}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (messageDate == today) {
      dateText = '오늘';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateText = '어제';
    } else {
      dateText = '${date.month}월 ${date.day}일 ${_getWeekday(date.weekday)}';
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return weekdays[weekday - 1];
  }

  Widget _buildInputArea() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderNormal,
          ),
        ),
      ),
      child: SafeArea(
        child: ChatInputField(
          controller: _messageController,
          onSend: _sendMessage,
          onSendImage: _sendImageMessage,
          onSendSuperChat: _isComposing ? _sendSuperChatMessage : null,
          isComposing: _isComposing,
        ),
      ),
    );
  }

  bool _shouldShowDateHeader(int index, List<MessageModel> messages) {
    if (index == 0) return true;
    
    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];
    
    final currentDate = DateTime(
      currentMessage.createdAt.year,
      currentMessage.createdAt.month,
      currentMessage.createdAt.day,
    );
    
    final previousDate = DateTime(
      previousMessage.createdAt.year,
      previousMessage.createdAt.month,
      previousMessage.createdAt.day,
    );
    
    return currentDate != previousDate;
  }

  void _deleteMessage(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('T�� �'),
        content: const Text('t T��| �Xܠ��L?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('�'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (mounted) {
                ref.read(chatProvider.notifier).deleteMessage(message.id);
              }
            },
            child: const Text('�'),
          ),
        ],
      ),
    );
  }

  void _replyToMessage(ChatMessage message) {
    // TODO: Implement reply functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('�� 0�@ � �   ���')),
    );
  }

  void _showProfileDetails() {
    // TODO: Navigate to profile detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.match.profile.name}X \D �0')),
    );
  }

  void _startVideoCall() {
    // TODO: Implement video call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('��T 0�@ � �   ���')),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '불쾌함을 느끼셨다면\n신고해주세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '사칭하는 업체나 채전한 환경을 만들기 위해\n위원님들을 관리하고 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              
              // 신고 옵션들
              _buildReportOption('성희롱, 모욕적인 단어를 사용해요', () {
                Navigator.pop(context);
                _showReportConfirmDialog('성희롱, 모욕적인 단어를 사용해요');
              }),
              const SizedBox(height: 12),
              _buildReportOption('충분 및 광고 목적이에요', () {
                Navigator.pop(context);
                _showReportConfirmDialog('충분 및 광고 목적이에요');
              }),
              const SizedBox(height: 12),
              _buildReportOption('불쾌한 사진을 보냈어요', () {
                Navigator.pop(context);
                _showReportConfirmDialog('불쾌한 사진을 보냈어요');
              }),
              const SizedBox(height: 12),
              _buildReportOption('다른 메신저로 유도해요', () {
                Navigator.pop(context);
                _showReportConfirmDialog('다른 메신저로 유도해요');
              }),
              
              const SizedBox(height: 24),
              
              // 취소 버튼
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '취소',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportOption(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4081),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showReportConfirmDialog(String reason) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // X 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                '불쾌함을 느끼셨다면\n신고해주세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 접수하기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _captureAndShowResult(reason);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4081),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text(
                    '캡처하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _captureAndShowResult(String reason) async {
    try {
      // 스크린샷 캡처
      final capturedImage = await _screenshotController.capture();
      
      if (capturedImage != null && mounted) {
        // 신고 정보와 텍스트 필드를 포함한 결과 다이얼로그 표시
        _showReportResultDialog(reason);
        
        // 실제 신고 처리
        _submitReport(reason);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('캡처 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReportResultDialog(String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '불쾌함을 느끼셨다면\n신고해주세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 12),
              
              const Text(
                '사칭하는 업체나 쾌적한 환경을 만들기 위해\n위원님들을 관리하고 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 신고 사유 표시
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '신고사유 : ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 텍스트 입력 필드
              Container(
                height: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFFF4081),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '',
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 취소 버튼
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '취소',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    // 3초 후 자동으로 다이얼로그 닫기
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  void _submitReport(String reason) {
    // TODO: Implement actual report functionality with reason
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('신고가 접수되었습니다: $reason'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  /// Convert MessageModel to ChatMessage for UI components
  ChatMessage _convertToUiMessage(MessageModel messageModel) {
    return ChatMessage(
      id: messageModel.messageId,
      chatId: messageModel.matchId,
      senderId: messageModel.senderId,
      receiverId: messageModel.receiverId,
      content: messageModel.content,
      type: _convertMessageType(messageModel.messageType),
      timestamp: messageModel.createdAt,
      status: _convertMessageStatus(messageModel.status),
    );
  }

  ChatMessageType _convertMessageType(MessageType messageType) {
    switch (messageType) {
      case MessageType.text:
        return ChatMessageType.text;
      case MessageType.image:
        return ChatMessageType.image;
      case MessageType.superchat:
        return ChatMessageType.text; // Treat as special text
      case MessageType.system:
        return ChatMessageType.system;
      case MessageType.sticker:
        return ChatMessageType.text; // Fallback to text
    }
  }

  ChatMessageStatus _convertMessageStatus(MessageStatus messageStatus) {
    switch (messageStatus) {
      case MessageStatus.sending:
        return ChatMessageStatus.sending;
      case MessageStatus.sent:
        return ChatMessageStatus.sent;
      case MessageStatus.delivered:
        return ChatMessageStatus.delivered;
      case MessageStatus.read:
        return ChatMessageStatus.read;
      case MessageStatus.failed:
        return ChatMessageStatus.failed;
    }
  }
}