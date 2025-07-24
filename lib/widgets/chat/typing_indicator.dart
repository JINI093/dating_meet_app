import 'dart:math' show sin, pi;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

class TypingIndicator extends StatefulWidget {
  final String profileImage;

  const TypingIndicator({
    super.key,
    required this.profileImage,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Avatar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.avatarXS / 2),
          child: SizedBox(
            width: AppDimensions.avatarXS,
            height: AppDimensions.avatarXS,
            child: _buildAvatarImage(),
          ),
        ),
        
        const SizedBox(width: AppDimensions.spacing8),
        
        // Typing bubble
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16,
            vertical: AppDimensions.spacing12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusL),
              topRight: Radius.circular(AppDimensions.radiusL),
              bottomRight: Radius.circular(AppDimensions.radiusL),
              bottomLeft: Radius.circular(AppDimensions.radiusXS),
            ),
            border: Border.all(
              color: AppColors.cardBorder,
              width: AppDimensions.borderNormal,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '입력 중',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing8),
              _buildTypingDots(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarImage() {
    if (widget.profileImage.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: widget.profileImage,
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
        widget.profileImage.isNotEmpty 
            ? widget.profileImage 
            : 'assets/icons/profile.png',
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

  Widget _buildTypingDots() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final progress = (_animation.value - delay).clamp(0.0, 1.0);
            final opacity = (sin(progress * pi) * 0.6 + 0.4).clamp(0.0, 1.0);
            
            return Container(
              margin: EdgeInsets.only(
                right: index < 2 ? AppDimensions.spacing4 : 0,
              ),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.textHint,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

