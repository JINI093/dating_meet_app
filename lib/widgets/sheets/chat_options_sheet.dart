import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../models/match_model.dart';
import '../../providers/chat_provider.dart';

class ChatOptionsSheet extends ConsumerWidget {
  final MatchModel match;
  final String chatId;

  const ChatOptionsSheet({
    super.key,
    required this.match,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
                  '${match.profile.name}님과의 채팅',
                  style: AppTextStyles.h5.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
            title: '프로필 보기',
            onTap: () {
              Navigator.pop(context);
              _showProfile(context);
            },
          ),
          
          _buildOptionItem(
            context,
            icon: CupertinoIcons.photo,
            title: '사진 및 파일 보기',
            onTap: () {
              Navigator.pop(context);
              _showMediaGallery(context);
            },
          ),
          
          _buildOptionItem(
            context,
            icon: CupertinoIcons.bell_slash,
            title: '알림 끄기',
            onTap: () {
              Navigator.pop(context);
              _muteNotifications(context, ref);
            },
          ),
          
          _buildOptionItem(
            context,
            icon: CupertinoIcons.search,
            title: '메시지 검색',
            onTap: () {
              Navigator.pop(context);
              _searchMessages(context);
            },
          ),
          
          _buildDivider(),
          
          _buildOptionItem(
            context,
            icon: CupertinoIcons.archivebox,
            title: '채팅방 보관',
            onTap: () {
              Navigator.pop(context);
              _archiveChat(context, ref);
            },
          ),
          
          _buildOptionItem(
            context,
            icon: CupertinoIcons.exclamationmark_triangle,
            title: '신고하기',
            onTap: () {
              Navigator.pop(context);
              _reportUser(context);
            },
            textColor: AppColors.warning,
          ),
          
          _buildOptionItem(
            context,
            icon: CupertinoIcons.xmark_circle,
            title: '차단하기',
            onTap: () {
              Navigator.pop(context);
              _blockUser(context, ref);
            },
            textColor: AppColors.error,
          ),
          
          const SizedBox(height: AppDimensions.spacing20),
        ],
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
      trailing: const Icon(
        CupertinoIcons.chevron_right,
        color: AppColors.textHint,
        size: AppDimensions.iconS,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
      height: 1,
      color: AppColors.divider,
    );
  }

  void _showProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${match.profile.name}의 프로필 보기')),
    );
  }

  void _showMediaGallery(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('미디어 갤러리 기능은 곧 추가될 예정입니다')),
    );
  }

  void _muteNotifications(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 끄기'),
        content: const Text('이 채팅방의 알림을 끄시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement mute functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('알림이 꺼졌습니다')),
              );
            },
            child: const Text('끄기'),
          ),
        ],
      ),
    );
  }

  void _searchMessages(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('메시지 검색 기능은 곧 추가될 예정입니다')),
    );
  }

  void _archiveChat(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('채팅방 보관'),
        content: const Text('이 채팅방을 보관하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(chatProvider.notifier).archiveChat(chatId);
              if (context.mounted) {
                Navigator.pop(context); // Close chat room
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('채팅방이 보관되었습니다')),
                );
              }
            },
            child: const Text('보관'),
          ),
        ],
      ),
    );
  }

  void _reportUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('신고하기'),
        content: Text('${match.profile.name}님을 신고하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showReportReasons(context);
            },
            child: const Text('신고'),
          ),
        ],
      ),
    );
  }

  void _showReportReasons(BuildContext context) {
    final reasons = [
      '부적절한 프로필 사진',
      '스팸 메시지',
      '욕설 및 비방',
      '성희롱',
      '사기 의심',
      '기타',
    ];

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
            
            Container(
              padding: const EdgeInsets.all(AppDimensions.bottomSheetPadding),
              child: Row(
                children: [
                  Text(
                    '신고 사유 선택',
                    style: AppTextStyles.h5.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
            
            ...reasons.map((reason) => ListTile(
              title: Text(reason),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('신고가 접수되었습니다: $reason')),
                );
              },
            )),
            
            const SizedBox(height: AppDimensions.spacing20),
          ],
        ),
      ),
    );
  }

  void _blockUser(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('차단하기'),
        content: Text(
          '${match.profile.name}님을 차단하시겠습니까?\n'
          '차단된 사용자는 더 이상 메시지를 보낼 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(chatProvider.notifier).blockChat(chatId, true);
              if (context.mounted) {
                Navigator.pop(context); // Close chat room
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${match.profile.name}님을 차단했습니다')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('차단'),
          ),
        ],
      ),
    );
  }
}