import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/like_model.dart';

class SentLikeCard extends StatelessWidget {
  final LikeModel like;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onSuperChat;

  const SentLikeCard({
    super.key,
    required this.like,
    this.onTap,
    this.onCancel,
    this.onSuperChat,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: AppColors.cardBorder,
            width: AppDimensions.borderNormal,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: AppDimensions.cardElevation,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppDimensions.cardRadius),
              ),
              child: SizedBox(
                width: 80,
                height: 100,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildProfileImage(),
                    ),
                    
                    // Status Badge
                    Positioned(
                      top: AppDimensions.spacing4,
                      left: AppDimensions.spacing4,
                      child: _buildStatusBadge(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Age
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${like.profile?.name ?? 'Unknown'}, ${like.profile?.age ?? 0}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // VIP Badge
                        if (like.profile?.isVip == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacing4,
                              vertical: AppDimensions.spacing2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                            ),
                            child: Text(
                              'VIP',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textWhite,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: AppDimensions.spacing4),
                    
                    // Location
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.location_solid,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppDimensions.spacing2),
                        Expanded(
                          child: Text(
                            like.profile?.location ?? 'Unknown',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppDimensions.spacing8),
                    
                    // Message or Status
                    Text(
                      like.isSuperChat 
                          ? '슈퍼챗: ${like.message}'
                          : '좋아요를 보냈어요',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: like.isSuperChat 
                            ? AppColors.secondary 
                            : AppColors.textSecondary,
                        fontWeight: like.isSuperChat 
                            ? FontWeight.w500 
                            : FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: AppDimensions.spacing8),
                    
                    // Time and Actions
                    Row(
                      children: [
                        Text(
                          like.timeAgo,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Action Buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Cancel Button
                            GestureDetector(
                              onTap: onCancel,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.spacing8,
                                  vertical: AppDimensions.spacing4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '취소',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Super Chat Button (only if not already sent)
                            if (!like.isSuperChat) ...[
                              const SizedBox(width: AppDimensions.spacing6),
                              GestureDetector(
                                onTap: onSuperChat,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.spacing8,
                                    vertical: AppDimensions.spacing4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: AppColors.secondaryGradient,
                                    ),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        CupertinoIcons.paperplane_fill,
                                        color: AppColors.textWhite,
                                        size: 10,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '슈퍼챗',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.textWhite,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final images = like.profile?.profileImages;
    final imageUrl = (images?.isNotEmpty == true) 
        ? images!.first 
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
        imageUrl.isNotEmpty ? imageUrl : 'assets/icons/profile.png',
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
          size: 30,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String badgeText;
    
    if (like.isSuperChat) {
      badgeColor = AppColors.secondary;
      badgeText = '슈퍼챗';
    } else {
      badgeColor = AppColors.warning;
      badgeText = '대기';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing4,
        vertical: AppDimensions.spacing2,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
      ),
      child: Text(
        badgeText,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textWhite,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}