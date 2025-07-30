import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/like_model.dart';
import '../../screens/profile/profile_reveal_screen.dart';
import '../../providers/likes_provider.dart';
import '../../screens/profile/other_profile_screen.dart';
import 'dart:ui';

class SentActionBottomSheet extends ConsumerWidget {
  final LikeModel like;
  
  const SentActionBottomSheet({
    super.key,
    required this.like,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 핸들
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '프로필 해제',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 블러 처리된 프로필 카드
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // 프로필 이미지
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: _hasProfileImage(like)
                        ? Image.network(
                            _getFirstProfileImage(like),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  
                  // 강한 블러 효과
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 안내 메시지
          const Text(
            '내가 좋아요 누른 사람을 확인합니다.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 4),
          
          const Text(
            '확인하시겠습니까?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // 해제 버튼
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () async {
                // 프로필 해제 처리
                await ref.read(likesProvider.notifier).addUnlockedProfile(like.toProfileId);
                
                if (!context.mounted) return;
                Navigator.pop(context);
                
                // 해제된 프로필 직접 표시
                if (like.profile != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OtherProfileScreen(
                        profile: like.profile!,
                        isLocked: false,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700), // 골드 색상
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.monetization_on,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '프로필 해제 (20P)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  bool _hasProfileImage(LikeModel like) {
    final profile = like.profile;
    final images = profile?.profileImages;
    return profile != null && images != null && images.isNotEmpty;
  }

  String _getFirstProfileImage(LikeModel like) {
    final profile = like.profile;
    final images = profile?.profileImages;
    if (profile != null && images != null && images.isNotEmpty) {
      return images.first;
    }
    return '';
  }
}