import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onSendImage;
  final VoidCallback? onSendSuperChat;
  final bool isComposing;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.onSendImage,
    this.onSendSuperChat,
    this.isComposing = false,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _showMoreOptions = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: widget.controller,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: '메시지를 입력해주세요',
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                onSubmitted: (_) => widget.onSend(),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Send button
          GestureDetector(
            onTap: widget.isComposing ? widget.onSend : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isComposing ? const Color(0xFFFF357B) : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '전송',
                style: TextStyle(
                  color: widget.isComposing ? Colors.white : const Color(0xFF999999),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreOptions() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      child: Row(
        children: [
          // Camera button
          _buildOptionButton(
            icon: CupertinoIcons.camera,
            label: '카메라',
            onTap: _openCamera,
          ),
          
          const SizedBox(width: AppDimensions.spacing16),
          
          // Gallery button
          _buildOptionButton(
            icon: CupertinoIcons.photo,
            label: '갤러리',
            onTap: widget.onSendImage,
          ),
          
          const SizedBox(width: AppDimensions.spacing16),
          
          // Location button
          _buildOptionButton(
            icon: CupertinoIcons.location,
            label: '위치',
            onTap: _shareLocation,
          ),
          
          const SizedBox(width: AppDimensions.spacing16),
          
          // File button
          _buildOptionButton(
            icon: CupertinoIcons.doc,
            label: '파일',
            onTap: _shareFile,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: AppDimensions.borderNormal,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: AppDimensions.iconM,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMoreOptions() {
    setState(() {
      _showMoreOptions = !_showMoreOptions;
    });
  }

  void _openCamera() {
    // TODO: Implement camera functionality
    _showComingSoonSnackBar('카메라');
    _toggleMoreOptions();
  }

  void _shareLocation() {
    // TODO: Implement location sharing
    _showComingSoonSnackBar('위치 공유');
    _toggleMoreOptions();
  }

  void _shareFile() {
    // TODO: Implement file sharing
    _showComingSoonSnackBar('파일 공유');
    _toggleMoreOptions();
  }

  void _startVoiceMessage() {
    // TODO: Implement voice message recording
    _showComingSoonSnackBar('음성 메시지');
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 기능은 곧 추가될 예정입니다'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}