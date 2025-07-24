import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/profile_model.dart';
import '../../widgets/sheets/super_chat_bottom_sheet.dart';
import '../../widgets/dialogs/match_success_dialog.dart';
import '../../providers/match_provider.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  final ProfileModel profile;
  final bool showActionButtons;
  final String? chatId;

  const ProfileDetailScreen({
    super.key,
    required this.profile,
    this.showActionButtons = true,
    this.chatId,
  });

  @override
  ConsumerState<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  final SwiperController _swiperController = SwiperController();
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Carousel
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            pinned: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.6,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  CupertinoIcons.chevron_left,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _showMoreOptions(context),
                  icon: const Icon(
                    CupertinoIcons.ellipsis,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(),
            ),
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusXL),
                ),
              ),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  _buildProfileInfo(),
                  _buildInterests(),
                  _buildPhotos(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: widget.showActionButtons ? _buildActionButtons() : null,
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        Swiper(
          controller: _swiperController,
          itemCount: widget.profile.profileImages.length,
          onIndexChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.profile.profileImages[index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
          pagination: null,
          control: null,
        ),
        
        // Image indicators
        Positioned(
          top: 60,
          left: 16,
          right: 16,
          child: Row(
            children: widget.profile.profileImages
                .asMap()
                .entries
                .map((entry) => Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(
                          right: entry.key == widget.profile.profileImages.length - 1
                              ? 0
                              : 4,
                        ),
                        decoration: BoxDecoration(
                          color: _currentImageIndex == entry.key
                              ? AppColors.textWhite
                              : AppColors.textWhite.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),

        // VIP Badge
        if (widget.profile.isVip)
          Positioned(
            top: 80,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.vipGradient,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.vip.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'VIP',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

        // Online Status
        if (widget.profile.isOnline)
          Positioned(
            bottom: 20,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.textWhite,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '온라인',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Age
          Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.profile.name}, ${widget.profile.age}',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (widget.profile.isVerified)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.checkmark,
                    color: AppColors.textWhite,
                    size: 16,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacing8),
          
          // Location and Distance
          Row(
            children: [
              const Icon(
                CupertinoIcons.location,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                widget.profile.location,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                CupertinoIcons.location_fill,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.profile.distance}km',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          // Bio
          if (widget.profile.bio != null && widget.profile.bio!.isNotEmpty)
            Text(
              widget.profile.bio!,
              style: AppTextStyles.bodyLarge.copyWith(
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기본 정보',
            style: AppTextStyles.h6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          _buildInfoRow('직업', widget.profile.occupation ?? '정보 없음'),
          _buildInfoRow('학력', widget.profile.education ?? '정보 없음'),
          _buildInfoRow('키', widget.profile.height != null ? '${widget.profile.height}cm' : '정보 없음'),
          _buildInfoRow('종교', widget.profile.religion ?? '정보 없음'),
          _buildInfoRow('흡연', widget.profile.smoking ?? '정보 없음'),
          _buildInfoRow('음주', widget.profile.drinking ?? '정보 없음'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterests() {
    if (widget.profile.hobbies.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '취미',
            style: AppTextStyles.h6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.profile.hobbies.map((hobby) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                hobby,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotos() {
    if (widget.profile.profileImages.length <= 1) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '사진',
            style: AppTextStyles.h6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing12),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: widget.profile.profileImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentImageIndex = index;
                  });
                  _swiperController.move(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: _currentImageIndex == index
                        ? Border.all(
                            color: AppColors.primary,
                            width: 2,
                          )
                        : null,
                    image: DecorationImage(
                      image: NetworkImage(widget.profile.profileImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!widget.showActionButtons) return const SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingL,
        right: AppDimensions.paddingL,
        top: AppDimensions.spacing16,
        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.spacing16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Pass Button
          Expanded(
            child: GestureDetector(
              onTap: _onPassTap,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(
                    color: AppColors.cardBorder,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppDimensions.spacing12),
          
          // Super Chat Button
          Expanded(
            child: GestureDetector(
              onTap: _onSuperChatTap,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.secondaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: const Icon(
                  CupertinoIcons.paperplane_fill,
                  color: AppColors.textWhite,
                  size: 24,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppDimensions.spacing12),
          
          // Like Button
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _onLikeTap,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: const Icon(
                  CupertinoIcons.heart_fill,
                  color: AppColors.textWhite,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPassTap() async {
    try {
      final result = await ref.read(matchProvider.notifier).passProfile();
      if (result != null && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.textSecondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('패스 처리 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _onLikeTap() async {
    try {
      final result = await ref.read(matchProvider.notifier).likeProfile();
      if (result != null && mounted) {
        Navigator.pop(context);
        if (result.isMatch) {
          _showMatchDialog(result);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _onSuperChatTap() async {
    try {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => SuperChatBottomSheet(
          profileImageUrl: widget.profile.profileImages.first,
          name: widget.profile.name,
          age: widget.profile.age,
          location: widget.profile.location,
        ),
      );
      
      if (result != null && result['type'] == 'super_chat') {
        final matchResult = await ref.read(matchProvider.notifier).superChatProfile(result['message']);
        if (matchResult != null && mounted) {
          Navigator.pop(context);
          if (matchResult.isMatch) {
            _showMatchDialog(matchResult);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(matchResult.message),
                backgroundColor: AppColors.secondary,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('슈퍼챗 처리 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _showMatchDialog(MatchResult result) {
    if (result.matchedProfile == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MatchSuccessDialog(
        matchedProfile: result.matchedProfile!,
        onChatTap: () {
          // TODO: Navigate to chat screen
        },
        onContinueTap: () {
          // Continue with current flow
        },
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
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
            
            // Options
            ListTile(
              leading: const Icon(CupertinoIcons.share, color: AppColors.textSecondary),
              title: const Text('프로필 공유'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share profile
              },
            ),
            
            ListTile(
              leading: const Icon(CupertinoIcons.exclamationmark_triangle, color: AppColors.warning),
              title: const Text('신고하기'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Report profile
              },
            ),
            
            ListTile(
              leading: const Icon(CupertinoIcons.eye_slash, color: AppColors.error),
              title: const Text('차단하기'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Block profile
              },
            ),
            
            const SizedBox(height: AppDimensions.spacing20),
          ],
        ),
      ),
    );
  }
}