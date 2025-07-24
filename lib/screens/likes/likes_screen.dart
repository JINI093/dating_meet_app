import 'package:dating_app_40s/screens/likes/sent_likes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/like_model.dart';
import '../../widgets/sheets/received_superchat_bottom_sheet.dart';
import '../../widgets/sheets/sent_action_bottom_sheet.dart';
import '../../providers/likes_provider.dart';
import '../../providers/superchat_provider.dart';
import 'received_likes_screen.dart';

class LikesScreen extends ConsumerStatefulWidget {
  const LikesScreen({super.key});

  @override
  ConsumerState<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends ConsumerState<LikesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final likesState = ref.watch(likesProvider);
    
    // 실제 데이터에서 카운트 계산
    final receivedSuperChatCount = likesState.receivedLikes
        .where((like) => like.isSuperChat)
        .length;
    final receivedLikeCount = likesState.receivedLikes
        .where((like) => !like.isSuperChat)
        .length;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar (로고만 중앙) - 상단으로 이동
            SizedBox(
              height: 80,
              child: Center(
                child: Image.asset(
                  'assets/icons/logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // 탭 버튼 (커스텀) - 상단으로 이동
            _CustomLikeTabBar(
              controller: _tabController,
              receivedSuperChat: receivedSuperChatCount,
              receivedLike: receivedLikeCount,
            ),
            // Tab View - 스크롤 가능한 전체 페이지
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _SuperChatTab(),
                  _LikeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 커스텀 탭바 (Flat, 하단선, 첨부 이미지 스타일)
class _CustomLikeTabBar extends StatelessWidget {
  final TabController controller;
  final int receivedSuperChat;
  final int receivedLike;
  const _CustomLikeTabBar({required this.controller, required this.receivedSuperChat, required this.receivedLike});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.animateTo(0),
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final selected = controller.index == 0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '슈퍼챗 $receivedSuperChat개',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: selected ? Colors.black : Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 3,
                        color: selected ? Colors.black : Colors.grey[200],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.animateTo(1),
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final selected = controller.index == 1;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '좋아요 $receivedLike개',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: selected ? Colors.black : Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 3,
                        color: selected ? Colors.black : Colors.grey[200],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 슈퍼챗 탭: 상단(내가 받은 슈퍼챗), 하단(내가 보낸 슈퍼챗)
class _SuperChatTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likesState = ref.watch(likesProvider);
    
    // 받은 슈퍼챗: likes provider에서 슈퍼챗만 필터링
    final receivedSuperchat = likesState.receivedLikes
        .where((like) => like.isSuperChat)
        .toList();
    
    // 보낸 슈퍼챗: likes provider에서 슈퍼챗만 필터링
    final sentSuperchat = likesState.sentLikes
        .where((like) => like.isSuperChat)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 내가 받은 슈퍼챗 섹션
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Text('내가 받은 슈퍼챗', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Spacer(),
                Text('${receivedSuperchat.length}명', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          ),
          _buildCardGrid(receivedSuperchat, false, true),
          
          // 구분선
          Divider(height: 32, thickness: 8, color: Colors.grey[100]),
          
          // 내가 보낸 슈퍼챗 섹션
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Text('내가 보낸 슈퍼챗', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Spacer(),
                Text('${sentSuperchat.length}명', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          ),
          _buildCardGrid(sentSuperchat, false, false),
          
          // 하단 여백
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCardGrid(List<LikeModel> items, bool shouldBlur, bool isReceived) {
    if (items.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '아직 슈퍼챗이 없어요',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _LikeCard(
          like: items[index],
          shouldBlur: shouldBlur,
          onTap: isReceived 
            ? () => _showReceivedSuperchatBottomSheet(context, items[index])
            : () => _showSentActionBottomSheet(context, items[index]),
        );
      },
    );
  }
  
  void _showReceivedSuperchatBottomSheet(BuildContext context, LikeModel like) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReceivedSuperchatBottomSheet(like: like),
    );
  }
  
  void _showSentActionBottomSheet(BuildContext context, LikeModel like) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SentActionBottomSheet(like: like),
    );
  }
}

// 좋아요 탭: 상단(내가 받은 좋아요), 하단(내가 보낸 좋아요)
class _LikeTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likesState = ref.watch(likesProvider);
    
    // 실제 데이터 사용
    final receivedLikes = likesState.receivedLikes
        .where((like) => !like.isSuperChat)
        .toList();
    final sentLikes = likesState.sentLikes
        .where((like) => !like.isSuperChat)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 내가 받은 좋아요 섹션
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Text('내가 받은 좋아요', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Spacer(),
                Text('${receivedLikes.length}명', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          ),
          _buildCardGrid(receivedLikes, true, true), // 받은 좋아요 블러 처리
          
          // 구분선
          Divider(height: 32, thickness: 8, color: Colors.grey[100]),
          
          // 내가 보낸 좋아요 섹션
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Text('내가 보낸 좋아요', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Spacer(),
                Text('${sentLikes.length}명', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          ),
          _buildCardGrid(sentLikes, false, false), // 보낸 좋아요는 블러 처리 안함
          
          // 하단 여백
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCardGrid(List<LikeModel> items, bool shouldBlur, bool isReceived) {
    if (items.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '아직 좋아요가 없어요',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _LikeCard(
          like: items[index],
          shouldBlur: shouldBlur,
          onTap: shouldBlur ? null : () => _showSentActionBottomSheet(context, items[index]),
        );
      },
    );
  }
  
  void _showSentActionBottomSheet(BuildContext context, LikeModel like) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SentActionBottomSheet(like: like),
    );
  }
}

// Like Card Widget
class _LikeCard extends StatelessWidget {
  final LikeModel like;
  final bool shouldBlur;
  final VoidCallback? onTap;

  const _LikeCard({
    required this.like,
    required this.shouldBlur,
    this.onTap,
  });

  Widget _buildProfileImage(LikeModel like) {
    final profile = like.profile;
    final images = profile?.profileImages;
    
    if (profile != null && images != null && images.isNotEmpty) {
      return Image.network(
        images.first,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.person,
              size: 60,
              color: Colors.grey,
            ),
          );
        },
      );
    }
    
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
              children: [
                // Profile Image
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildProfileImage(like),
                ),
                // Blur Effect for received likes
                if (shouldBlur)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                  ),
                // Profile Info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          like.profile?.name ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${like.profile?.age ?? 0}세, ${like.profile?.location ?? 'Unknown'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              ),
            ),
          ),
          // D-7 Countdown Badge
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'D-7',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}