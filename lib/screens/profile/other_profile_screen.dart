import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../../models/profile_model.dart';
import '../../providers/point_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_text_styles.dart';

class OtherProfileScreen extends ConsumerStatefulWidget {
  final ProfileModel profile;
  final bool isLocked;
  final String? superChatMessage;

  const OtherProfileScreen({
    Key? key,
    required this.profile,
    this.isLocked = false,
    this.superChatMessage,
  }) : super(key: key);

  @override
  ConsumerState<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends ConsumerState<OtherProfileScreen> {
  bool _isUnlocking = false;
  bool _showUnlockDialog = false;
  
  static const int unlockCost = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Profile content
          _buildProfileContent(),
          
          // Unlock dialog overlay
          if (_showUnlockDialog) _buildUnlockDialog(),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return Column(
      children: [
        // App bar
        _buildAppBar(),
        
        // Profile card
        Expanded(
          child: Center(
            child: _buildProfileCard(),
          ),
        ),
        
        // Action buttons
        _buildActionButtons(),
        
        SizedBox(height: AppDimensions.safeAreaBottom + AppDimensions.paddingL),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: AppDimensions.safeAreaTop + AppDimensions.appBarHeight,
      padding: EdgeInsets.only(
        top: AppDimensions.safeAreaTop,
        left: AppDimensions.paddingM,
        right: AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.textPrimary,
          ),
          const Spacer(),
          Text(
            widget.isLocked ? '프로필 확인' : '${widget.profile.name}님의 프로필',
            style: AppTextStyles.appBarTitle,
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: AppDimensions.profileCardWidth,
      height: AppDimensions.profileCardHeight,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
        child: Column(
          children: [
            // Profile image
            _buildProfileImage(),
            
            // Profile info
            _buildProfileInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      height: AppDimensions.profileImageHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base image
          Image.asset(
            widget.profile.profileImages.first,
            fit: BoxFit.cover,
          ),
          
          // Blur overlay for locked profiles
          if (widget.isLocked)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),
          
          // Lock icon overlay
          if (widget.isLocked)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and age
            Row(
              children: [
                Text(
                  widget.profile.name,
                  style: AppTextStyles.profileName,
                ),
                const SizedBox(width: AppDimensions.spacing8),
                Text(
                  '${widget.profile.age}살',
                  style: AppTextStyles.profileAge,
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.spacing4),
            
            // Location
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: AppDimensions.locationIconSize,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.spacing4),
                Text(
                  widget.profile.location,
                  style: AppTextStyles.cardSubtitle,
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.spacing16),
            
            // Description or super chat message
            if (widget.superChatMessage != null)
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.superLike.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(
                    color: AppColors.superLike.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble,
                          size: AppDimensions.iconS,
                          color: AppColors.superLike,
                        ),
                        const SizedBox(width: AppDimensions.spacing4),
                        Text(
                          '슈퍼챗',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.superLike,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(
                      widget.superChatMessage!,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: Text(
                  widget.isLocked 
                    ? '안녕하세요! 저는 32살 직장인으로, 요리와 운동을 즐기고 있습니다. 여행도 좋아하고 음악듣기도 좋아하는 편입니다. 서로 친해지면 좋겠네요.'
                    : (widget.profile.bio ?? ''),
                  style: AppTextStyles.bodyMedium,
                  maxLines: widget.isLocked ? 5 : null,
                  overflow: widget.isLocked ? TextOverflow.ellipsis : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass button
          _buildActionButton(
            icon: Icons.close,
            color: AppColors.pass,
            onPressed: () => Navigator.pop(context),
          ),
          
          // Like button
          _buildActionButton(
            icon: Icons.favorite,
            color: AppColors.like,
            onPressed: widget.isLocked ? _handleUnlockProfile : _handleLike,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: AppDimensions.likeButtonSize,
      height: AppDimensions.likeButtonSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: AppDimensions.actionButtonElevation,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: AppDimensions.matchActionIconSize,
        ),
      ),
    );
  }

  Widget _buildUnlockDialog() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width - 48,
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                '프로필 해제',
                style: AppTextStyles.h4,
              ),
              
              const SizedBox(height: AppDimensions.spacing16),
              
              // Blurred profile image
              Container(
                width: 120,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        widget.profile.profileImages.first,
                        fit: BoxFit.cover,
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppDimensions.spacing24),
              
              // Description
              Text(
                '나를 좋아요 누른 사람을 확인합니다.\n확인하시겠습니까?',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.spacing32),
              
              // Unlock button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUnlocking ? null : _confirmUnlock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vip,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                    ),
                  ),
                  child: _isUnlocking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.flash_on,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          Text(
                            '프로필 해제 (${unlockCost}P)',
                            style: AppTextStyles.buttonMedium,
                          ),
                        ],
                      ),
                ),
              ),
              
              const SizedBox(height: AppDimensions.spacing12),
              
              // Cancel button
              TextButton(
                onPressed: () => setState(() => _showUnlockDialog = false),
                child: Text(
                  '취소',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleUnlockProfile() {
    setState(() => _showUnlockDialog = true);
  }

  void _handleLike() {
    // Handle regular like action
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.profile.name}님에게 좋아요를 보냈습니다!'),
        backgroundColor: AppColors.like,
      ),
    );
  }

  Future<void> _confirmUnlock() async {
    setState(() => _isUnlocking = true);
    
    try {
      // Check if user has enough points
      final pointsState = ref.read(pointProvider);
      if (pointsState.currentPoints < unlockCost) {
        setState(() => _isUnlocking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('포인트가 부족합니다.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      // Simulate unlocking process
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Deduct points
      ref.read(pointProvider.notifier).spendPoints(unlockCost, 'Profile unlock');
      
      setState(() {
        _isUnlocking = false;
        _showUnlockDialog = false;
      });
      
      // Navigate to unlocked profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtherProfileScreen(
            profile: widget.profile,
            isLocked: false,
            superChatMessage: widget.superChatMessage,
          ),
        ),
      );
      
    } catch (e) {
      setState(() => _isUnlocking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필 해제에 실패했습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}