import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/like_model.dart';
import '../../widgets/sheets/super_chat_bottom_sheet.dart';

class SentLikesScreen extends ConsumerStatefulWidget {
  const SentLikesScreen({super.key});

  @override
  ConsumerState<SentLikesScreen> createState() => _SentLikesScreenState();
}

class _SentLikesScreenState extends ConsumerState<SentLikesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<LikeModel> _sentSuperChats;
  late List<LikeModel> _sentLikes;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSentLikes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSentLikes() {
    // TODO: 실제 API 호출로 대체
    final allSentLikes = LikeModel.getMockSentLikes();
    _sentSuperChats = allSentLikes.where((like) => like.isSuperChat).toList();
    _sentLikes = allSentLikes.where((like) => !like.isSuperChat).toList();
  }

  void _cancelLike(LikeModel like) {
    // TODO: 좋아요 취소 로직
    setState(() {
      if (like.isSuperChat) {
        _sentSuperChats.remove(like);
      } else {
        _sentLikes.remove(like);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.back, color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      '보낸 좋아요',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),

            // Tab Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
              child: _buildTabBar(),
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSuperChatTab(),
                  _buildLikesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.textWhite,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        tabs: [
          Tab(text: '슈퍼챗 ${_sentSuperChats.length}개'),
          Tab(text: '좋아요 ${_sentLikes.length}개'),
        ],
      ),
    );
  }

  Widget _buildSuperChatTab() {
    if (_sentSuperChats.isEmpty) {
      return _buildEmptyState(
        icon: CupertinoIcons.paperplane,
        title: '보낸 슈퍼챗이 없어요',
        subtitle: '특별한 메시지로 매력을 어필해보세요!',
        actionText: '슈퍼챗 보내기',
        onActionTap: () {
          // TODO: 팁 기능 구현
          _showEmptyActionSheet(context, '슈퍼챗 기능은 메인 화면에서 사용할 수 있어요!');
        },
      );
    }

    return _buildLikesList(_sentSuperChats, true);
  }

  Widget _buildLikesTab() {
    if (_sentLikes.isEmpty) {
      return _buildEmptyState(
        icon: CupertinoIcons.heart,
        title: '보낸 좋아요가 없어요',
        subtitle: '마음에 드는 프로필에 좋아요를 보내보세요!',
        actionText: '홈으로 이동',
        onActionTap: () {
          // TODO: Navigate to home
          Navigator.of(context).pop();
        },
      );
    }

    return _buildLikesList(_sentLikes, false);
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onActionTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing24),
          
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppDimensions.spacing8),
          
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppDimensions.spacing32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onActionTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
              ),
              child: Text(
                actionText,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikesList(List<LikeModel> likes, bool isSuperChat) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      children: [
        if (isSuperChat) ...[
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            margin: const EdgeInsets.only(bottom: AppDimensions.spacing16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.secondaryGradient,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.sparkles,
                  color: AppColors.textWhite,
                  size: AppDimensions.iconM,
                ),
                const SizedBox(width: AppDimensions.spacing8),
                Expanded(
                  child: Text(
                    '슈퍼챗으로 특별한 관심을 표현했어요!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // TODO: Navigate to profile detail
        ...likes.map((like) => _buildLikeCard(like, isSuperChat)),
      ],
    );
  }

  Widget _buildLikeCard(LikeModel like, bool isSuperChat) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: isSuperChat ? AppColors.secondary : AppColors.cardBorder,
          width: isSuperChat ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppDimensions.cardElevation,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (isSuperChat) {
            _showSuperChatDetails(like);
          } else {
            // TODO: Show super chat bottom sheet
          }
        },
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing12),
          child: Row(
            children: [
              // Profile Image
              SizedBox(
                width: 60,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _buildProfileImageWidget(like),
                      ),
                      if (isSuperChat)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.secondaryGradient,
                              ),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                            ),
                            child: const Icon(
                              CupertinoIcons.paperplane_fill,
                              color: AppColors.textWhite,
                              size: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: AppDimensions.spacing12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            like.profile?.name ?? 'Unknown',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing6,
                            vertical: AppDimensions.spacing2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                          ),
                          child: Text(
                            '대기중',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppDimensions.spacing4),
                    
                    // Message or Type
                    Text(
                      isSuperChat ? like.message ?? '슈퍼챗을 보냈어요' : '좋아요를 보냈어요',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSuperChat ? AppColors.secondary : AppColors.textSecondary,
                        fontWeight: isSuperChat ? FontWeight.w500 : FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: AppDimensions.spacing8),
                    
                    // Actions
                    Row(
                      children: [
                        Text(
                          like.timeAgo,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        GestureDetector(
                          onTap: () => _cancelLike(like),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacing8,
                              vertical: AppDimensions.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Text(
                              '취소',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildProfileImageWidget(LikeModel like) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        image: _getProfileImage(like),
      ),
      child: _shouldShowPlaceholder(like)
          ? const Center(
              child: Icon(
                CupertinoIcons.person_circle,
                color: AppColors.textHint,
                size: 30,
              ),
            )
          : null,
    );
  }

  DecorationImage? _getProfileImage(LikeModel like) {
    final profile = like.profile;
    final images = profile?.profileImages;
    if (profile != null && images != null && images.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(images.first),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  bool _shouldShowPlaceholder(LikeModel like) {
    final profile = like.profile;
    final images = profile?.profileImages;
    return images == null || images.isEmpty;
  }

  void _showSuperChatDetails(LikeModel like) {
    final profile = like.profile;
    final images = profile?.profileImages;
    final profileImageUrl = (profile != null && images != null && images.isNotEmpty)
        ? images.first
        : '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SuperChatBottomSheet(
        profileImageUrl: profileImageUrl,
        name: profile?.name ?? 'Unknown',
        age: profile?.age ?? 0,
        location: profile?.location ?? 'Unknown',
      ),
    );
  }

  void _showEmptyActionSheet(BuildContext context, String message) {
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
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing16),
          ],
        ),
      ),
    );
  }
}