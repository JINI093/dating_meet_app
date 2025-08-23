import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../models/profile_model.dart';
import '../../utils/app_text_styles.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback? onTap;
  final int popularityRank;

  const ProfileCard({
    super.key,
    required this.profile,
    this.onTap,
    this.popularityRank = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing8,
          vertical: AppDimensions.spacing4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.profileCardRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: AppDimensions.profileCardElevation,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.profileCardRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              _buildBackgroundImage(),
              
              // Gradient Overlay
              _buildGradientOverlay(),
              
              // Top Badges
              _buildTopBadges(profile),
              
              // Bottom Content
              _buildBottomContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    final imageUrl = profile.profileImages.isNotEmpty 
        ? profile.profileImages.first 
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
    } else if (imageUrl.startsWith('file://')) {
      final filePath = imageUrl.replaceFirst('file://', '');
      final file = File(filePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
        );
      } else {
        return _buildPlaceholderImage();
      }
    } else if (imageUrl.isNotEmpty && !imageUrl.startsWith('assets/')) {
      return _buildPlaceholderImage();
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
          size: 80,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.3, 0.6, 1.0],
          colors: [
            Colors.black.withValues(alpha: 0.2),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.4),
            Colors.black.withValues(alpha: 0.9),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBadges(ProfileModel profile) {
    return Positioned(
      top: 16,
      left: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Badge (pop.png)
          Visibility(
            visible: popularityRank <= 10,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildPopBadge(),
            ),
          ),
          
          // Middle Badge (check.png)
          Visibility(
            visible: profile.isVerified,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildCheckBadge(),
            ),
          ),
          
          // Bottom Badge (gold_level.png)
          Visibility(
            visible: profile.isVip,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildGoldLevelBadge(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopBadge() {
    // 인기도 순위가 0이거나 10위 초과인 경우 표시하지 않음
    if (popularityRank <= 0 || popularityRank > 10) {
      return const SizedBox.shrink();
    }

    var badgeColor = popularityRank <= 3
        ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
        : popularityRank <= 5
        ? [const Color(0xFFC0C0C0), const Color(0xFF808080)]
        : [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
    
    return Image.asset(
      'assets/icons/$popularityRank.png',
      width: 70,
      errorBuilder: (context, error, stackTrace) {
        // 이미지가 없는 경우 순위 표시 배지
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: badgeColor,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                popularityRank <= 3 ? Icons.star : Icons.trending_up,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '$popularityRank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckBadge() {
    return Image.asset(
      'assets/icons/ic_verified.png',
      width: 70,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 70,
          height: 70,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.checkmark_shield_fill,
            color: Colors.white,
            size: 48,
          ),
        );
      },
    );
  }

  Widget _buildGoldLevelBadge() {
    return Image.asset(
      'assets/icons/gold_level.png',
      width: 80,
      height: 80,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.star_fill,
            color: Colors.white,
            size: 48,
          ),
        );
      },
    );
  }



  Widget _buildBottomContent() {
    return Positioned(
      bottom: 100, // Position above the action buttons (super chat button)
      left: 24,
      right: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name (center aligned)
          Center(
            child: Text(
              profile.name,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Age and Location (center aligned)
          Center(
            child: Text(
              '${profile.age}세 | ${profile.location}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}