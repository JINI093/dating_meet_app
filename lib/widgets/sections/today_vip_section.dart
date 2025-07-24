import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/profile_model.dart';

class TodayVipSection extends ConsumerWidget {
  final List<ProfileModel> vipProfiles;
  final VoidCallback? onViewAll;

  const TodayVipSection({
    super.key,
    required this.vipProfiles,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (vipProfiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.spacing8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacing6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: const Icon(
                  CupertinoIcons.star_fill,
                  color: AppColors.textWhite,
                  size: AppDimensions.iconS,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing8),
              Expanded(
                child: Text(
                  '오늘의 VIP',
                  style: AppTextStyles.h5.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '전체보기',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing4),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: AppColors.primary,
                        size: AppDimensions.iconS,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacing8),
          
          Text(
            'VIP 멤버들의 프리미엄 프로필을 먼저 만나보세요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing12),
          
          // VIP Profiles Grid
          _buildVipProfilesGrid(),
        ],
      ),
    );
  }

  Widget _buildVipProfilesGrid() {
    // Show max 4 profiles in 2x2 grid
    final displayProfiles = vipProfiles.take(4).toList();
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.1),
            const Color(0xFFFFA500).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          width: AppDimensions.borderNormal,
        ),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.spacing12,
          mainAxisSpacing: AppDimensions.spacing12,
          childAspectRatio: 0.8,
        ),
        itemCount: displayProfiles.length,
        itemBuilder: (context, index) {
          final profile = displayProfiles[index];
          return _buildVipProfileCard(profile);
        },
      ),
    );
  }

  Widget _buildVipProfileCard(ProfileModel profile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.cardBorder,
          width: AppDimensions.borderNormal,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusM),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppColors.background,
                    child: profile.profileImages.isNotEmpty
                        ? Image.asset(
                            profile.profileImages.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                          )
                        : _buildImagePlaceholder(),
                  ),
                ),
                
                // VIP Badge
                Positioned(
                  top: AppDimensions.spacing6,
                  right: AppDimensions.spacing6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing6,
                      vertical: AppDimensions.spacing2,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.star_fill,
                          color: AppColors.textWhite,
                          size: 8,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'VIP',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textWhite,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Online Status
                if (profile.isOnline)
                  Positioned(
                    top: AppDimensions.spacing6,
                    left: AppDimensions.spacing6,
                    child: Container(
                      width: AppDimensions.onlineStatusSize,
                      height: AppDimensions.onlineStatusSize,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textWhite,
                          width: AppDimensions.onlineStatusBorder,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Profile Info
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacing4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing4,
                        vertical: AppDimensions.spacing2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                      ),
                      child: Text(
                        '${profile.age}세',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.spacing2),
                
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.location_solid,
                      color: AppColors.textHint,
                      size: AppDimensions.iconXS,
                    ),
                    const SizedBox(width: AppDimensions.spacing2),
                    Expanded(
                      child: Text(
                        profile.location,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textHint,
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
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusM),
        ),
      ),
      child: const Center(
        child: Icon(
          CupertinoIcons.person_circle,
          color: AppColors.textHint,
          size: 40,
        ),
      ),
    );
  }
}