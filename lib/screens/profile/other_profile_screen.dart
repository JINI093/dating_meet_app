import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import '../../providers/heart_provider.dart';
import '../../routes/route_names.dart';
import 'package:go_router/go_router.dart';

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
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // App Bar
          _buildAppBar(),
          
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Images with Page View and Action Buttons
                  _buildImageSection(),
                  
                  // Profile Info Sections
                  _buildInfoSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              CupertinoIcons.chevron_back,
              size: 24,
              color: Colors.black,
            ),
          ),
          
          // Profile Name and Age
          Row(
            children: [
              // Profile Image Thumbnail
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: ClipOval(
                  child: _buildProfileThumbnail(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.profile.name}, ${widget.profile.age}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          
          // Notification Icon (placeholder for balance)
          const Icon(
            CupertinoIcons.bell,
            size: 24,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final images = widget.profile.profileImages.isNotEmpty 
        ? widget.profile.profileImages 
        : ['assets/icons/profile.png'];
    
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return _buildImage(images[index]);
            },
          ),
          
          // Page Indicators
          if (images.length > 1)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          
          // Action Buttons positioned at bottom of image
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass Button
          _buildActionButton(
            iconPath: 'assets/icons/x.png',
            onTap: _handlePass,
          ),
          
          // Super Chat Button
          _buildActionButton(
            iconPath: 'assets/icons/superchat.png',
            onTap: _handleSuperchat,
          ),
          
          // Like Button
          _buildActionButton(
            iconPath: 'assets/icons/like.png',
            onTap: _handleLike,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        iconPath,
        width: 60,
        height: 60,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 개인정보 섹션
          _buildSectionTitle('개인정보'),
          const SizedBox(height: 16),
          _buildInfoRow('닉네임', widget.profile.name),
          _buildInfoRow('사는 곳', widget.profile.location),
          _buildInfoRow('직업', widget.profile.occupation ?? '대기업 디자이너'),
          _buildInfoRow('키', '${widget.profile.height ?? 165}'),
          _buildInfoRow('취미', widget.profile.hobbies.isNotEmpty ? widget.profile.hobbies.join(', ') : '기타연주, 악방'),
          _buildInfoRow('이상형', '키 180이상의 전문직'),
          
          const SizedBox(height: 32),
          
          // 자기소개 섹션
          _buildSectionTitle('자기소개'),
          const SizedBox(height: 16),
          Text(
            widget.profile.bio ?? '안녕하세요! 저는 여행과 새로운 경험을 사랑하는 28살 디자이너입니다. 현재는 사람들이 더 편리하고 행복하게 살 수 있는 서비스를 만드는 일을 하고 있어요. 주말에는 엘러티 투어나 요가로 시간을 보내고, 요즘은 베이킹에도 관심이 많아 다양한 나라의 디저트를 만들어보고 있어요. 😊',
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 만남유형 섹션
          _buildSectionTitle('만남유형'),
          const SizedBox(height: 16),
          _buildMeetingTypeTags(),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMeetingTypeTags() {
    // AWS에서 가져온 만남유형 데이터 처리
    // 데이터가 없으면 "둘 다 가능"으로 기본값 설정
    final meetingType = widget.profile.mbti ?? '둘 다 가능'; // mbti 필드를 만남유형으로 사용한다고 가정
    
    // 모든 만남유형 옵션
    final allOptions = ['진지한 만남', '가벼운 만남', '둘 다 가능'];
    
    // 선택된 옵션 결정
    String selectedOption;
    if (meetingType.isEmpty || meetingType == '둘 다 가능') {
      selectedOption = '둘 다 가능';
    } else if (allOptions.contains(meetingType)) {
      selectedOption = meetingType;
    } else {
      selectedOption = '둘 다 가능'; // 기본값
    }
    
    return Wrap(
      spacing: 8,
      children: allOptions.map((option) => _buildTag(
        option,
        isSelected: option == selectedOption,
      )).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, {bool isSelected = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProfileThumbnail() {
    final imageUrl = widget.profile.profileImages.isNotEmpty
        ? widget.profile.profileImages.first
        : '';
    
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey.shade200),
        errorWidget: (context, url, error) => _buildPlaceholderThumbnail(),
      );
    } else if (imageUrl.startsWith('file://')) {
      final filePath = imageUrl.replaceFirst('file://', '');
      final file = File(filePath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    } else if (imageUrl.isNotEmpty && imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }
    
    return _buildPlaceholderThumbnail();
  }

  Widget _buildPlaceholderThumbnail() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.person,
        size: 20,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade200,
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
      }
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }
    
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.person,
          size: 80,
          color: Colors.grey,
        ),
      ),
    );
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
        
        // 먼저 likes 데이터를 새로고침
        await ref.read(likesProvider.notifier).loadAllLikes();
        
        // 평가한 프로필로 마킹하여 다시 나타나지 않도록 함
        ref.read(discoverProfilesProvider.notifier).markProfileAsEvaluated(widget.profile.id);
        
        if (mounted) {
          // 스낵바를 먼저 표시
          final snackBar = SnackBar(
            content: Text('${widget.profile.name}님을 패스했습니다.'),
            backgroundColor: const Color(0xFF6C6C6C),
            duration: const Duration(seconds: 2),
          );
          
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          
          // 약간의 지연 후 화면 닫기
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('패스 처리에 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
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
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 먼저 하트가 충분한지 확인
      final heartState = ref.read(heartProvider);
      const requiredHearts = 1; // 좋아요를 보내는데 필요한 하트 수
      
      if (heartState.currentHearts < requiredHearts) {
        // 하트가 부족한 경우 알림 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('하트가 부족합니다. (현재: ${heartState.currentHearts}개)'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: '하트 구매',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                  print('💝 하트 구매 버튼 클릭됨: ${RouteNames.ticketShop}');
                  context.push(RouteNames.ticketShop);
                },
              ),
            ),
          );
        }
        return;
      }
      
      // 하트 소모 처리
      final heartSpent = await ref.read(heartProvider.notifier).spendHearts(
        requiredHearts,
        description: '좋아요 보내기',
      );
      
      if (!heartSpent) {
        // 하트 소모 실패
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('하트 사용에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: Colors.red,
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
        // 먼저 likes 데이터를 새로고침
        await ref.read(likesProvider.notifier).loadAllLikes();
        
        // 평가한 프로필로 마킹하여 다시 나타나지 않도록 함
        ref.read(discoverProfilesProvider.notifier).markProfileAsEvaluated(widget.profile.id);
        
        if (mounted) {
          // 스낵바를 먼저 표시
          final snackBar = SnackBar(
            content: Text('${widget.profile.name}님에게 좋아요를 보냈습니다!'),
            backgroundColor: const Color(0xFFE91E63),
            duration: const Duration(seconds: 2),
          );
          
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          
          // 약간의 지연 후 화면 닫기
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        // 좋아요 전송 실패 시 하트 복구
        await ref.read(heartProvider.notifier).refreshHearts();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('좋아요 전송에 실패했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 오류 발생 시 하트 복구
      await ref.read(heartProvider.notifier).refreshHearts();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('좋아요 전송에 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
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

      // 먼저 하트가 충분한지 확인
      final heartState = ref.read(heartProvider);
      const requiredHearts = 3; // 슈퍼챗을 보내는데 필요한 하트 수
      
      if (heartState.currentHearts < requiredHearts) {
        // 하트가 부족한 경우 알림 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('슈퍼챗을 보내려면 하트 $requiredHearts개가 필요합니다. (현재: ${heartState.currentHearts}개)'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: '하트 구매',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                  print('💝 하트 구매 버튼 클릭됨: ${RouteNames.ticketShop}');
                  context.push(RouteNames.ticketShop);
                },
              ),
            ),
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
            backgroundColor: Colors.red,
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

      // 하트 소모 처리
      const requiredHearts = 3;
      final heartSpent = await ref.read(heartProvider.notifier).spendHearts(
        requiredHearts,
        description: '슈퍼챗 보내기',
      );
      
      if (!heartSpent) {
        // 하트 소모 실패
        if (mounted) {
          Navigator.pop(context); // Bottom sheet 닫기
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('하트 사용에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: Colors.red,
            ),
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
        // 먼저 likes 데이터를 새로고침
        await ref.read(likesProvider.notifier).loadAllLikes();
        
        // 평가한 프로필로 마킹하여 다시 나타나지 않도록 함
        ref.read(discoverProfilesProvider.notifier).markProfileAsEvaluated(widget.profile.id);
        
        if (mounted) {
          // 먼저 bottom sheet 닫기
          Navigator.pop(context);
          
          // 스낵바를 표시
          final snackBar = SnackBar(
            content: Text('${widget.profile.name}님에게 슈퍼챗을 보냈습니다!'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 2),
          );
          
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          
          // 약간의 지연 후 프로필 화면 닫기
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        // 슈퍼챗 전송 실패 시 하트 복구
        await ref.read(heartProvider.notifier).refreshHearts();
        
        if (mounted) {
          Navigator.pop(context); // Close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('슈퍼챗 전송에 실패했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 오류 발생 시 하트 복구
      await ref.read(heartProvider.notifier).refreshHearts();
      
      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('슈퍼챗 전송에 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}