import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/chat_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMyMessage;
  final bool showAvatar;
  final String profileImage;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
    this.showAvatar = false,
    this.profileImage = '',
    this.onDelete,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: isMyMessage 
              ? MainAxisAlignment.end 
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMyMessage) ...[
              // Other user's avatar
              if (showAvatar)
                _buildAvatar()
              else
                const SizedBox(width: 32),
              
              const SizedBox(width: 8),
            ],
            
            // Message bubble with time
            Flexible(
              child: Row(
                mainAxisAlignment: isMyMessage 
                    ? MainAxisAlignment.end 
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isMyMessage) ...[
                    // Read status and time for my messages (left side)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (message.status == ChatMessageStatus.read)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '읽음',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            message.timeDisplay,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // Message bubble
                  Flexible(child: _buildMessageBubble()),
                  
                  if (!isMyMessage) ...[
                    // Time for received messages (right side)
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.timeDisplay,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 32,
        height: 32,
        child: _buildAvatarImage(),
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (profileImage.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: profileImage,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surface,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholderAvatar(),
      );
    } else {
      return Image.asset(
        profileImage.isNotEmpty ? profileImage : 'assets/icons/profile.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderAvatar(),
      );
    }
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          CupertinoIcons.person_circle,
          size: 16,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildMessageBubble() {
    switch (message.type) {
      case ChatMessageType.text:
        return _buildTextBubble();
      case ChatMessageType.image:
        return _buildImageBubble();
      case ChatMessageType.system:
        return _buildSystemBubble();
      default:
        return _buildTextBubble();
    }
  }

  Widget _buildTextBubble() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isMyMessage ? const Color(0xFFFF357B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMyMessage ? null : Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Text(
        message.content,
        style: TextStyle(
          fontSize: 16,
          color: isMyMessage ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildImageBubble() {
    final caption = message.metadata?['caption'] as String?;
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      decoration: BoxDecoration(
        color: isMyMessage ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppDimensions.radiusL),
          topRight: const Radius.circular(AppDimensions.radiusL),
          bottomLeft: isMyMessage 
              ? const Radius.circular(AppDimensions.radiusL) 
              : const Radius.circular(AppDimensions.radiusXS),
          bottomRight: isMyMessage 
              ? const Radius.circular(AppDimensions.radiusXS) 
              : const Radius.circular(AppDimensions.radiusL),
        ),
        border: isMyMessage ? null : Border.all(
          color: AppColors.cardBorder,
          width: AppDimensions.borderNormal,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusL),
              topRight: Radius.circular(AppDimensions.radiusL),
            ),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: _buildMessageImage(),
            ),
          ),
          
          // Caption
          if (caption != null)
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing12),
              child: Text(
                caption,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isMyMessage ? AppColors.textWhite : AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageImage() {
    if (message.content.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: message.content,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.background,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildImagePlaceholder(),
      );
    } else {
      return Image.asset(
        message.content,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Icon(
          CupertinoIcons.photo,
          size: 40,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildSystemBubble() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing12,
          vertical: AppDimensions.spacing6,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: AppColors.cardBorder,
            width: AppDimensions.borderNormal,
          ),
        ),
        child: Text(
          message.content,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textHint,
          ),
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    if (!isMyMessage && onReply == null && onDelete == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.bottomSheetRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: AppDimensions.spacing12),
              width: AppDimensions.bottomSheetHandleWidth,
              height: AppDimensions.bottomSheetHandleHeight,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(
                  AppDimensions.bottomSheetHandleHeight / 2,
                ),
              ),
            ),
            
            if (onReply != null)
              ListTile(
                leading: const Icon(CupertinoIcons.reply),
                title: const Text('답장'),
                onTap: () {
                  Navigator.pop(context);
                  onReply?.call();
                },
              ),
            
            if (isMyMessage && onDelete != null)
              ListTile(
                leading: const Icon(
                  CupertinoIcons.delete,
                  color: AppColors.error,
                ),
                title: const Text(
                  '삭제',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
              ),
            
            const SizedBox(height: AppDimensions.spacing20),
          ],
        ),
      ),
    );
  }
}