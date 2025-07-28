import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/like_model.dart';
import '../../widgets/cards/like_card.dart';
import '../../providers/likes_provider.dart';

class ReceivedLikesScreen extends ConsumerWidget {
  const ReceivedLikesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likesState = ref.watch(likesProvider);
    final receivedLikes = likesState.receivedLikes;
    final unreadCount = likesState.totalUnreadLikes;
    
    if (likesState.isLoadingReceived) {
      return _buildLoadingState();
    }
    
    if (receivedLikes.isEmpty) {
      return _buildEmptyState();
    }
    
    return RefreshIndicator(
      onRefresh: () => ref.read(likesProvider.notifier).loadAllLikes(),
      child: Column(
        children: [
          // Header with count
          _buildHeader(context, receivedLikes.length, unreadCount),
          
          // Likes List
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: AppDimensions.gridCrossAxisSpacing,
                mainAxisSpacing: AppDimensions.gridMainAxisSpacing,
              ),
              itemCount: receivedLikes.length,
              itemBuilder: (context, index) {
                final like = receivedLikes[index];
                return LikeCard(
                  like: like,
                  onTap: () => _handleLikeCardTap(context, ref, like),
                  onAccept: () => _handleAcceptLike(ref, like),
                  onReject: () => _handleRejectLike(ref, like),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalCount, int unreadCount) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.spacing12,
      ),
      child: Row(
        children: [
          Text(
            '받은 좋아요 ${totalCount}개',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          if (unreadCount > 0) ...[
            const SizedBox(width: AppDimensions.spacing8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing8,
                vertical: AppDimensions.spacing4,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Text(
                '새로운 ${unreadCount}개',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          
          const Spacer(),
          
          // Filter Button
          GestureDetector(
            onTap: () {
              // TODO: 필터 옵션 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('필터 기능은 개발 중입니다')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing12,
                vertical: AppDimensions.spacing8,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: AppDimensions.borderNormal,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.slider_horizontal_3,
                    size: AppDimensions.iconS,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacing4),
                  Text(
                    'D0',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: AppDimensions.emptyStateImageSize,
            height: AppDimensions.emptyStateImageSize,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.cardBorder,
                width: 2,
              ),
            ),
            child: const Icon(
              CupertinoIcons.heart,
              size: 60,
              color: AppColors.textHint,
            ),
          ),
          
          const SizedBox(height: AppDimensions.emptyStateSpacing),
          
          Text(
            '받은 좋아요가 없습니다',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing8),
          
          Text(
            '아직 받은 좋아요가 없습니다!\n프로필을 완성해보세요.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppDimensions.spacing24),
          
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to profile edit
            },
            child: const Text('프로필 완성하러 가기'),
          ),
        ],
      ),
    );
  }

  void _handleLikeCardTap(BuildContext context, WidgetRef ref, LikeModel like) {
    // Mark as read
    ref.read(likesProvider.notifier).markAsRead(like.id);
    
    // TODO: Navigate to profile detail
    _showProfileDetail(context, ref, like);
  }

  void _handleAcceptLike(WidgetRef ref, LikeModel like) {
    ref.read(likesProvider.notifier).acceptLike(like.id);
    
    // Show match success
    _showMatchSuccess(like);
  }

  void _handleRejectLike(WidgetRef ref, LikeModel like) {
    ref.read(likesProvider.notifier).rejectLike(like.id);
  }

  void _showProfileDetail(BuildContext context, WidgetRef ref, LikeModel like) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _buildProfileDetailSheet(ctx, ref, like),
    );
  }

  Widget _buildProfileDetailSheet(BuildContext context, WidgetRef ref, LikeModel like) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      child: Column(
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
          
          // Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.bottomSheetPadding),
            child: Row(
              children: [
                Text(
                  '${like.profile?.name ?? 'Unknown'}님의 프로필',
                  style: AppTextStyles.h5,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: AppColors.textSecondary,
                    size: AppDimensions.iconM,
                  ),
                ),
              ],
            ),
          ),
          
          // Profile Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    child: AspectRatio(
                      aspectRatio: 0.8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          image: like.profile?.profileImages?.isNotEmpty == true
                              ? DecorationImage(
                                  image: NetworkImage(like.profile!.profileImages!.first),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: like.profile?.profileImages?.isEmpty != false
                            ? const Center(
                                child: Icon(
                                  CupertinoIcons.person_circle,
                                  size: 80,
                                  color: AppColors.textHint,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.spacing20),
                  
                  // Basic Info
                  Text(
                    '${like.profile?.name ?? 'Unknown'}, ${like.profile?.age ?? 0}세',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.spacing8),
                  
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.location_solid,
                        size: AppDimensions.iconS,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.spacing4),
                      Text(
                        like.profile?.location ?? 'Unknown',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (like.profile?.distance != null) ...[
                        const SizedBox(width: AppDimensions.spacing8),
                        Text(
                          '${like.profile!.distance!.toStringAsFixed(1)}km',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: AppDimensions.spacing16),
                  
                  // Bio
                  if (like.profile?.bio?.isNotEmpty == true) ...[
                    Text(
                      '자기소개',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(
                      like.profile!.bio!,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppDimensions.spacing20),
                  ],
                  
                  // Badges
                  if (like.profile?.badges?.isNotEmpty == true) ...[
                    Text(
                      '뱃지',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Wrap(
                      spacing: AppDimensions.spacing8,
                      runSpacing: AppDimensions.spacing8,
                      children: like.profile!.badges!.map((badge) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing12,
                            vertical: AppDimensions.spacing6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            border: Border.all(
                              color: AppColors.primary,
                              width: AppDimensions.borderNormal,
                            ),
                          ),
                          child: Text(
                            badge,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Handle reject like
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacing16,
                      ),
                    ),
                    child: const Text('거절'),
                  ),
                ),
                
                const SizedBox(width: AppDimensions.spacing12),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Handle accept like
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacing16,
                      ),
                    ),
                    child: const Text('수락'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMatchSuccess(LikeModel like) {
    // TODO: Show match success dialog
  }

  void _showFilterOptions(BuildContext context) {
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
            
            // Header
            Container(
              padding: const EdgeInsets.all(AppDimensions.bottomSheetPadding),
              child: Row(
                children: [
                  Text(
                    '필터',
                    style: AppTextStyles.h5,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: AppColors.textSecondary,
                      size: AppDimensions.iconM,
                    ),
                  ),
                ],
              ),
            ),
            
            // Filter Options
            ListTile(
              leading: const Icon(CupertinoIcons.eye_slash),
              title: const Text('숨김'),
              trailing: Switch(
                value: false, // TODO: Get from provider
                onChanged: (value) {
                  // TODO: Apply filter
                },
              ),
            ),
            
            ListTile(
              leading: const Icon(CupertinoIcons.location),
              title: const Text('거리순'),
              trailing: Switch(
                value: true, // TODO: Get from provider
                onChanged: (value) {
                  // TODO: Apply sorting
                },
              ),
            ),
            
            ListTile(
              leading: const Icon(CupertinoIcons.star),
              title: const Text('VIP만'),
              trailing: Switch(
                value: false, // TODO: Get from provider
                onChanged: (value) {
                  // TODO: Apply VIP filter
                },
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacing20),
          ],
        ),
      ),
    );
  }
}