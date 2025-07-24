import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/like_model.dart';

class ReceivedSuperchatBottomSheet extends StatelessWidget {
  final LikeModel like;
  
  const ReceivedSuperchatBottomSheet({
    super.key,
    required this.like,
  });

  @override
  Widget build(BuildContext context) {
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
                  '${like.profile?.name ?? '알 수 없음'}님의 슈퍼챗',
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
          
          const SizedBox(height: 20),
          
          // 프로필 카드
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 280,
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
                  
                  // 그라데이션 오버레이
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 프로필 정보
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          like.profile?.name ?? '알 수 없음',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${like.profile?.age ?? 0}세 | ${like.profile?.location ?? '알 수 없음'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 슈퍼챗 메시지
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              like.message ?? '안녕하세요! 저는 32살 직장인으로, 요리와 운동을 좋아해 건강하고 균형 잡힌 삶을 추구하고 있어요. 여행도 좋아해서 새로운 곳을 탐험하는 걸 좋아합니다. 따뜻한 마음을 가진 진솔한 대화를 나누며 서로를 알아갈 수 있으면 좋겠어요.',
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 액션 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // X 버튼
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  'assets/icons/x.png',
                  width: 56,
                  height: 56,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.xmark,
                        color: Colors.white,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(width: 32),
              
              // O 버튼
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  'assets/icons/o.png',
                  width: 56,
                  height: 56,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE91E63),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.heart_fill,
                        color: Colors.white,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ],
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