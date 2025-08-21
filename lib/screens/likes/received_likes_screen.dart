import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/like_model.dart';
import '../../widgets/cards/like_card.dart';
import '../../providers/likes_provider.dart';
import '../../widgets/sheets/sent_action_bottom_sheet.dart';
import '../profile/other_profile_screen.dart';

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
            '받은 좋아요 $totalCount개',
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
                '새로운 $unreadCount개',
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
    
    // Show profile unlock bottom sheet
    _showProfileUnlockBottomSheet(context, ref, like);
  }

  void _handleAcceptLike(WidgetRef ref, LikeModel like) {
    ref.read(likesProvider.notifier).acceptLike(like.id);
    
    // Show match success
    _showMatchSuccess(like);
  }

  void _handleRejectLike(WidgetRef ref, LikeModel like) {
    ref.read(likesProvider.notifier).rejectLike(like.id);
  }

  void _showProfileUnlockBottomSheet(BuildContext context, WidgetRef ref, LikeModel like) {
    // 프로필이 이미 해제되었는지 확인
    final isUnlocked = ref.read(likesProvider.notifier).isProfileUnlocked(like.fromUserId);
    
    if (isUnlocked && like.profile != null) {
      // 이미 해제된 프로필은 바로 상세 프로필 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtherProfileScreen(
            profile: like.profile!,
            isLocked: false,
          ),
        ),
      );
    } else {
      // 해제되지 않은 프로필은 바텀시트 표시
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SentActionBottomSheet(like: like),
      );
    }
  }

  void _showMatchSuccess(LikeModel like) {
    // TODO: Show match success dialog
  }
}
