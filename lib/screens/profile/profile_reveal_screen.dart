import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../models/like_model.dart';

class ProfileRevealScreen extends StatefulWidget {
  final LikeModel like;
  
  const ProfileRevealScreen({
    super.key,
    required this.like,
  });

  @override
  State<ProfileRevealScreen> createState() => _ProfileRevealScreenState();
}

class _ProfileRevealScreenState extends State<ProfileRevealScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            CupertinoIcons.chevron_left,
            color: Colors.black,
            size: 24,
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.like.profile?.profileImages?.isNotEmpty == true
                  ? NetworkImage(widget.like.profile!.profileImages!.first)
                  : null,
              backgroundColor: Colors.grey[300],
              child: widget.like.profile?.profileImages?.isEmpty != false
                  ? const Icon(Icons.person, size: 20, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.like.profile?.name ?? 'Unknown'}, ${widget.like.profile?.age ?? 0}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _showReportDialog();
            },
            icon: Image.asset(
              'assets/icons/siren.png',
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  color: Colors.black,
                  size: 22,
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 이미지 영역
            Stack(
              children: [
                // 프로필 이미지
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: widget.like.profile?.profileImages?.isNotEmpty == true
                      ? Image.network(
                          widget.like.profile!.profileImages!.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                size: 100,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                ),
                
                // 하단 액션 버튼들
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 싫어요 버튼
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Image.asset(
                          'assets/icons/dislike.png',
                          width: 56,
                          height: 56,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.grey[600],
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
                      
                      const SizedBox(width: 16),
                      
                      // 슈퍼챗 버튼
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Image.asset(
                          'assets/icons/superchat.png',
                          width: 56,
                          height: 56,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.paperplane_fill,
                                color: Colors.white,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // 좋아요 버튼
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Image.asset(
                          'assets/icons/like.png',
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
                ),
              ],
            ),
            
            // 하단 정보 영역
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 개인정보 섹션
                  const Text(
                    '개인정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoRow('닉네임', widget.like.profile?.name ?? 'Unknown'),
                  _buildInfoRow('사는 곳', widget.like.profile?.location ?? 'Unknown'),
                  _buildInfoRow('직업', widget.like.profile?.occupation ?? '대기업 디자이너'),
                  _buildInfoRow('키', '${widget.like.profile?.height ?? 165}'),
                  _buildInfoRow('취미', widget.like.profile?.hobbies?.isNotEmpty == true ? widget.like.profile!.hobbies!.join(', ') : '기타연주, 여행'),
                  _buildInfoRow('이상형', '키 180이상의 진중직'),
                  
                  const SizedBox(height: 20),
                  
                  // 자기소개 섹션
                  const Text(
                    '자기소개',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    widget.like.profile?.bio ?? '안녕하세요! 저는 여행과 새로운 경험을 사랑하는 28살 디자이너입니다. 한적한 사람들이 더 끌리고 행복하게 살 수 있는 서비스를 만드는 일을 하고 있어요. 주말에는 갤러리 투어나 요가를 즐기며 새로운 문화를 경험하고 내 수 있는 분과 만나고 싶어요. 😊',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 만남유형 섹션
                  const Text(
                    '만남유형',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      _buildMeetingTypeChip('진지한 만남'),
                      const SizedBox(width: 8),
                      _buildMeetingTypeChip('가벼운 만남'),
                      const SizedBox(width: 8),
                      _buildMeetingTypeChip('술 한 잔'),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMeetingTypeChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }
  
  void _showReportDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '불쾌함을 느끼셨다면\n신고해주세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                const Text(
                  '사귈래는 언제나 쾌적한 환경을 만들기 위해\n회원님들을 관리하고 있습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                _buildReportButton('불쾌한 사진이 업로드 되어 있어요', () {
                  Navigator.pop(context);
                }),
                
                const SizedBox(height: 12),
                
                _buildReportButton('광고 사진으로 설정을 해두었어요', () {
                  Navigator.pop(context);
                }),
                
                const SizedBox(height: 12),
                
                _buildReportButton('자기소개를 부적절하게 적었어요', () {
                  Navigator.pop(context);
                }),
                
                const SizedBox(height: 20),
                
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildReportButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E63),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}