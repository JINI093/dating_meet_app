import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/like_model.dart';

class LikeCard extends StatelessWidget {
  final LikeModel like;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const LikeCard({
    super.key,
    required this.like,
    this.onTap,
    this.onAccept,
    this.onReject,
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
            color: like.isRead ? AppColors.cardBorder : AppColors.primary,
            width: like.isRead ? AppDimensions.borderNormal : 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: AppDimensions.cardElevation,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Main Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.cardRadius),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: _buildProfileImage(),
                    ),
                  ),
                  
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppDimensions.cardRadius),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Top Badges
                  Positioned(
                    top: AppDimensions.spacing8,
                    left: AppDimensions.spacing8,
                    right: AppDimensions.spacing8,
                    child: Row(
                      children: [
                        // New Badge
                        if (!like.isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacing6,
                              vertical: AppDimensions.spacing2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            ),
                            child: Text(
                              'NEW',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textWhite,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        
                        const Spacer(),
                        
                        // Super Chat Badge
                        if (like.isSuperChat)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacing6,
                              vertical: AppDimensions.spacing2,
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
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Profile Info Overlay
                  Positioned(
                    bottom: AppDimensions.spacing8,
                    left: AppDimensions.spacing8,
                    right: AppDimensions.spacing8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name and Age
                        Text(
                          '${like.profile?.name ?? 'Unknown'}, ${like.profile?.age ?? 0}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Location
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.location_solid,
                              color: AppColors.textWhite,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                like.profile?.location ?? 'Unknown',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textWhite,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message or Like Text
                    Expanded(
                      child: Text(
                        like.displayMessage,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: like.isSuperChat 
                              ? AppColors.textPrimary 
                              : AppColors.textSecondary,
                          fontWeight: like.isSuperChat 
                              ? FontWeight.w500 
                              : FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.spacing4),
                    
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
                            // Reject Button
                            GestureDetector(
                              onTap: onReject,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  CupertinoIcons.xmark,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: AppDimensions.spacing4),
                            
                            // Accept Button
                            GestureDetector(
                              onTap: onAccept ?? () {},
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.heart_fill,
                                  size: 14,
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ),
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
          size: 40,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}