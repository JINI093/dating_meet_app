import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/profile_model.dart';
import '../../providers/point_provider.dart';
import '../../providers/enhanced_auth_provider.dart';
import '../../providers/likes_provider.dart';
import '../../providers/discover_profiles_provider.dart';
import '../../services/aws_likes_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/logger.dart';
import '../../widgets/sheets/super_chat_bottom_sheet.dart';

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
          _buildBaseImage(),
          
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
            onPressed: widget.isLocked ? _handleUnlockProfile : _handlePass,
          ),
          
          // Like button
          _buildActionButton(
            icon: Icons.favorite,
            color: AppColors.like,
            onPressed: widget.isLocked ? _handleUnlockProfile : _handleLike,
          ),
          
          // Superchat button
          _buildActionButton(
            icon: Icons.star,
            color: AppColors.superLike,
            onPressed: widget.isLocked ? _handleUnlockProfile : _handleSuperchat,
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

  Future<void> _handlePass() async {
    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인이 필요합니다.')),
          );
        }
        return;
      }

      final fromUserId = authState.currentUser!.user!.userId;
      final toProfileId = widget.profile.id;

      // Send pass
      final likesService = AWSLikesService();
      Logger.log('패스 전송 시작 - From: $fromUserId, To: $toProfileId', name: 'ProfilePass');
      
      final passResult = await likesService.sendPass(
        fromUserId: fromUserId,
        toProfileId: toProfileId,
      );

      if (passResult != null) {
        Logger.log('패스 전송 성공! Pass ID: ${passResult.id}', name: 'ProfilePass');
        
        // 평가한 프로필로 마킹하여 다시 나타나지 않도록 함
        ref.read(discoverProfilesProvider.notifier).markProfileAsEvaluated(widget.profile.id);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.profile.name}님을 패스했습니다.'),
              backgroundColor: AppColors.pass,
            ),
          );
        }

        // Refresh likes data
        ref.read(likesProvider.notifier).loadAllLikes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('패스 처리에 실패했습니다: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleLike() async {
    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그인이 필요합니다.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Send like using likes provider
      final success = await ref.read(likesProvider.notifier).sendLike(
        toProfileId: widget.profile.id,
      );

      if (success) {
        // 평가한 프로필로 마킹하여 다시 나타나지 않도록 함
        ref.read(discoverProfilesProvider.notifier).markProfileAsEvaluated(widget.profile.id);
        
        if (mounted) {
          Navigator.pop(context); // Close profile screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.profile.name}님에게 좋아요를 보냈습니다!'),
              backgroundColor: AppColors.like,
            ),
          );
        }

        // Refresh likes data
        ref.read(likesProvider.notifier).loadAllLikes();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('좋아요 전송에 실패했습니다.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('좋아요 전송에 실패했습니다: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSuperchat() async {
    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인이 필요합니다.')),
          );
        }
        return;
      }

      final profileImage = widget.profile.profileImages.isNotEmpty 
          ? widget.profile.profileImages.first 
          : '';

      // Show superchat bottom sheet
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SuperChatBottomSheet(
              profileImageUrl: profileImage,
              name: widget.profile.name,
              age: widget.profile.age,
              location: widget.profile.location,
              onSend: (message) async {
                await _sendSuperchat(message);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('슈퍼챗 실행에 실패했습니다: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendSuperchat(String message) async {
    try {
      if (message.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('메시지를 입력해주세요.')),
          );
        }
        return;
      }

      final authState = ref.read(enhancedAuthProvider);
      final fromUserId = authState.currentUser!.user!.userId;
      final toProfileId = widget.profile.id;

      // Send superchat via REST API (for likes page compatibility)
      final likesService = AWSLikesService();
      Logger.log('슈퍼챗 전송 시작 - From: $fromUserId, To: $toProfileId', name: 'ProfileSuperchat');
      
      final superchat = await likesService.sendSuperchat(
        fromUserId: fromUserId,
        toProfileId: toProfileId,
        message: message,
        pointsUsed: 50, // Default superchat cost
      );

      if (superchat != null) {
        // 평가한 프로필로 마킹하여 다시 나타나지 않도록 함
        ref.read(discoverProfilesProvider.notifier).markProfileAsEvaluated(widget.profile.id);
        
        if (mounted) {
          Navigator.pop(context); // Close bottom sheet
          Navigator.pop(context); // Close profile screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.profile.name}님에게 슈퍼챗을 보냈습니다!'),
              backgroundColor: AppColors.superLike,
            ),
          );
        }

        // Refresh likes data to show superchat
        ref.read(likesProvider.notifier).loadAllLikes();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('슈퍼챗 전송에 실패했습니다: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmUnlock() async {
    setState(() => _isUnlocking = true);
    
    try {
      // Check if user has enough points
      final pointsState = ref.read(pointProvider);
      if (pointsState.currentPoints < unlockCost) {
        setState(() => _isUnlocking = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('포인트가 부족합니다.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
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
      if (mounted) {
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
      }
      
    } catch (e) {
      setState(() => _isUnlocking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 해제에 실패했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildBaseImage() {
    final imageUrl = widget.profile.profileImages.isNotEmpty
        ? widget.profile.profileImages.first
        : '';

    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surface,
          child: const Center(
            child: CircularProgressIndicator(),
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
          Icons.person,
          size: 80,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}