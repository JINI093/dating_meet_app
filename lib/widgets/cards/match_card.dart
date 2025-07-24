import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/match_model.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onTap;
  final VoidCallback? onArchive;
  final VoidCallback? onBlock;
  final VoidCallback? onReport;
  final bool isNewMatch;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.onArchive,
    this.onBlock,
    this.onReport,
    this.isNewMatch = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      onLongPress: () => _showOptionsMenu(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: match.hasUnreadMessages 
                ? AppColors.primary 
                : AppColors.cardBorder,
            width: match.hasUnreadMessages ? 2.0 : AppDimensions.borderNormal,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: AppDimensions.cardElevation,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing12),
          child: Row(
            children: [
              // Profile Image
              _buildProfileImage(),
              
              const SizedBox(width: AppDimensions.spacing12),
              
              // Content
              Expanded(
                child: _buildContent(),
              ),
              
              // Trailing
              _buildTrailing(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        // Main Image
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.avatarM / 2),
          child: SizedBox(
            width: AppDimensions.avatarM,
            height: AppDimensions.avatarM,
            child: _buildImage(),
          ),
        ),
        
        // Online Status
        if (match.profile.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: AppDimensions.onlineStatusSize,
              height: AppDimensions.onlineStatusSize,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surface,
                  width: AppDimensions.onlineStatusBorder,
                ),
              ),
            ),
          ),
        
        // New Match Badge
        if (isNewMatch)
          Positioned(
            top: -2,
            left: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing4,
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
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    final imageUrl = match.profile.profileImages.isNotEmpty 
        ? match.profile.profileImages.first 
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
        imageUrl.isNotEmpty ? imageUrl : 'assets/images/default_profile.png',
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

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and Badges Row
        Row(
          children: [
            Expanded(
              child: Text(
                match.profile.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // VIP Badge
            if (match.profile.isVip)
              Container(
                margin: const EdgeInsets.only(left: AppDimensions.spacing4),
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
            
            // Super Chat Badge
            if (match.isSuperChatMatch)
              Container(
                margin: const EdgeInsets.only(left: AppDimensions.spacing4),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing4,
                  vertical: AppDimensions.spacing2,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.secondaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.paperplane_fill,
                      color: AppColors.textWhite,
                      size: 8,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '�|W',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textWhite,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        
        const SizedBox(height: AppDimensions.spacing4),
        
        // Last Message or Match Info
        Text(
          match.displayLastMessage,
          style: AppTextStyles.bodyMedium.copyWith(
            color: match.hasUnreadMessages 
                ? AppColors.textPrimary 
                : AppColors.textSecondary,
            fontWeight: match.hasUnreadMessages 
                ? FontWeight.w500 
                : FontWeight.w400,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: AppDimensions.spacing4),
        
        // Time and Match Info
        Row(
          children: [
            Text(
              match.timeAgo,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
            
            const SizedBox(width: AppDimensions.spacing8),
            
            Text(
              '"',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
            
            const SizedBox(width: AppDimensions.spacing8),
            
            Text(
              match.matchTimeAgo,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Unread Count Badge
        if (match.hasUnreadMessages && match.unreadCount > 0)
          Container(
            constraints: const BoxConstraints(minWidth: 20),
            height: 20,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                match.unreadCount > 99 ? '99+' : match.unreadCount.toString(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textWhite,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        
        const SizedBox(height: AppDimensions.spacing8),
        
        // Options Menu Button
        GestureDetector(
          onTap: () => _showOptionsMenu(context),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spacing4),
            child: const Icon(
              CupertinoIcons.ellipsis,
              color: AppColors.textHint,
              size: AppDimensions.iconS,
            ),
          ),
        ),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context) {
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
                    '${match.profile.name}�',
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
            
            // Options
            _buildOptionItem(
              context,
              icon: CupertinoIcons.person,
              title: '\D �0',
              onTap: () {
                Navigator.pop(context);
                onTap?.call();
              },
            ),
            
            _buildOptionItem(
              context,
              icon: CupertinoIcons.archivebox,
              title: '�X � ',
              onTap: () {
                Navigator.pop(context);
                onArchive?.call();
              },
            ),
            
            _buildOptionItem(
              context,
              icon: CupertinoIcons.exclamationmark_triangle,
              title: '��X0',
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context);
              },
              textColor: AppColors.warning,
            ),
            
            _buildOptionItem(
              context,
              icon: CupertinoIcons.xmark_circle,
              title: '(�X0',
              onTap: () {
                Navigator.pop(context);
                _showBlockDialog(context);
              },
              textColor: AppColors.error,
            ),
            
            const SizedBox(height: AppDimensions.spacing20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppColors.textPrimary,
        size: AppDimensions.iconM,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('��X0'),
        content: const Text('t ��D ��Xܠ��?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('�'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onReport?.call();
            },
            child: const Text('��'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('(�X0'),
        content: Text('${match.profile.name}�D (�Xܠ��?\n(�\ ���� �� �m� J���.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('�'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onBlock?.call();
            },
            child: const Text('(�'),
          ),
        ],
      ),
    );
  }
}