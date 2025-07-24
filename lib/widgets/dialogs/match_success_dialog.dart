import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/profile_model.dart';
import '../../providers/notification_provider.dart';
import '../common/custom_button.dart';

class MatchSuccessDialog extends ConsumerStatefulWidget {
  final ProfileModel matchedProfile;
  final VoidCallback? onChatTap;
  final VoidCallback? onContinueTap;

  const MatchSuccessDialog({
    super.key,
    required this.matchedProfile,
    this.onChatTap,
    this.onContinueTap,
  });

  @override
  ConsumerState<MatchSuccessDialog> createState() => _MatchSuccessDialogState();
}

class _MatchSuccessDialogState extends ConsumerState<MatchSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
    
    // Add notification after short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      ref.read(notificationProvider.notifier).addMatchNotification(
        matchId: 'match_${DateTime.now().millisecondsSinceEpoch}',
        profileId: widget.matchedProfile.id,
        profileName: widget.matchedProfile.name,
        profileImageUrl: widget.matchedProfile.profileImages.first,
      );
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppDimensions.paddingL),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with celebration icon
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingXL),
                      child: Column(
                        children: [
                          // Celebration heart icon with gradient
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.primaryGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              CupertinoIcons.heart_fill,
                              color: AppColors.textWhite,
                              size: 40,
                            ),
                          ),
                          
                          const SizedBox(height: AppDimensions.spacing20),
                          
                          // Match success text
                          Text(
                            '매칭 성공! 🎉',
                            style: AppTextStyles.h3.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          
                          const SizedBox(height: AppDimensions.spacing8),
                          
                          Text(
                            '${widget.matchedProfile.name}님과 매칭되었습니다!',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    // Profile section
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      child: Row(
                        children: [
                          // Profile image
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                              image: DecorationImage(
                                image: NetworkImage(widget.matchedProfile.profileImages.first),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: AppDimensions.spacing12),
                          
                          // Profile info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.matchedProfile.name,
                                  style: AppTextStyles.h6.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.spacing4),
                                Text(
                                  '${widget.matchedProfile.age}세 • ${widget.matchedProfile.location}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Online status
                          if (widget.matchedProfile.isOnline)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacing8,
                                vertical: AppDimensions.spacing4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                              ),
                              child: Text(
                                '온라인',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Action buttons
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingXL),
                      child: Row(
                        children: [
                          // Continue browsing button
                          Expanded(
                            child: CustomButton(
                              text: '계속 둘러보기',
                              style: CustomButtonStyle.outline,
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onContinueTap?.call();
                              },
                            ),
                          ),
                          
                          const SizedBox(width: AppDimensions.spacing12),
                          
                          // Chat button
                          Expanded(
                            child: CustomButton(
                              text: '채팅하기',
                              style: CustomButtonStyle.gradient,
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onChatTap?.call();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}