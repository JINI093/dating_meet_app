import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../models/profile_model.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.profile,
    this.onTap,
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
              _buildTopBadges(),
              
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
            Colors.black.withValues(alpha: 0.1),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.4),
            Colors.black.withValues(alpha: 0.9),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBadges() {
    return Positioned(
      top: 16,
      left: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Badge (pop.png)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _buildPopBadge(),
          ),
          
          // Middle Badge (check.png)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _buildCheckBadge(),
          ),
          
          // Bottom Badge (gold_level.png)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _buildGoldLevelBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopBadge() {
    return Image.asset(
      'assets/icons/pop.png',
      width: 80,
      height: 80,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '1',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
      'assets/icons/check.png',
      width: 80,
      height: 80,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.checkmark_shield_fill,
            color: Colors.white,
            size: 16,
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.star_fill,
            color: Colors.white,
            size: 16,
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