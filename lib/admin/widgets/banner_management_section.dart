import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/admin_theme.dart';
import '../models/banner_model.dart';
import '../providers/banner_provider.dart';
import '../widgets/banner_card.dart';
import '../widgets/banner_upload_dialog.dart';

/// 배너 관리 섹션 위젯
class BannerManagementSection extends ConsumerStatefulWidget {
  final BannerType? type;

  const BannerManagementSection({
    super.key,
    this.type,
  });

  @override
  ConsumerState<BannerManagementSection> createState() => _BannerManagementSectionState();
}

class _BannerManagementSectionState extends ConsumerState<BannerManagementSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminBannerProvider.notifier).filterByType(widget.type);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bannerState = ref.watch(adminBannerProvider);
    final bannerStats = ref.watch(bannerStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 통계 카드들
        if (widget.type == null) ...[
          Row(
            children: [
              Expanded(
                child: _buildStatCard('전체 배너', bannerStats['total'] ?? 0, Icons.image, Colors.blue),
              ),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(
                child: _buildStatCard('활성', bannerStats['active'] ?? 0, Icons.visibility, Colors.green),
              ),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(
                child: _buildStatCard('비활성', bannerStats['inactive'] ?? 0, Icons.visibility_off, Colors.grey),
              ),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(
                child: _buildStatCard('메인 광고', bannerStats['mainAd'] ?? 0, Icons.ads_click, Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: AdminTheme.spacingL),
        ],

        // 헤더와 추가 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.type?.displayName ?? '전체 배너',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showBannerDialog(),
              icon: const Icon(Icons.add),
              label: const Text('배너 추가'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),

        // 배너 목록
        Expanded(
          child: bannerState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : bannerState.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 48, color: Colors.red),
                          const SizedBox(height: AdminTheme.spacingM),
                          Text(
                            '오류가 발생했습니다: ${bannerState.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: AdminTheme.spacingM),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(adminBannerProvider.notifier).refresh();
                            },
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    )
                  : bannerState.banners.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: AdminTheme.spacingM),
                              Text(
                                '등록된 배너가 없습니다',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: AdminTheme.spacingM),
                              ElevatedButton.icon(
                                onPressed: () => _showBannerDialog(),
                                icon: const Icon(Icons.add),
                                label: const Text('첫 번째 배너 추가'),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AdminTheme.spacingM,
                            mainAxisSpacing: AdminTheme.spacingM,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: bannerState.banners.length,
                          itemBuilder: (context, index) {
                            final banner = bannerState.banners[index];
                            return BannerCard(
                              banner: banner,
                              onEdit: () => _showBannerDialog(banner: banner),
                              onDelete: () => _deleteBanner(banner),
                              onToggleStatus: () => _toggleBannerStatus(banner),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AdminTheme.spacingM),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBannerDialog({BannerModel? banner}) {
    showDialog(
      context: context,
      builder: (context) => BannerUploadDialog(
        banner: banner,
        defaultType: widget.type,
        onSave: (dto) async {
          try {
            if (banner != null) {
              await ref.read(adminBannerProvider.notifier).updateBanner(banner.id, dto);
            } else {
              await ref.read(adminBannerProvider.notifier).createBanner(dto);
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(banner != null ? '배너가 수정되었습니다' : '배너가 생성되었습니다'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('오류가 발생했습니다: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _deleteBanner(BannerModel banner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('배너 삭제'),
        content: Text('${banner.title} 배너를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(adminBannerProvider.notifier).deleteBanner(banner.id);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('배너가 삭제되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('오류가 발생했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _toggleBannerStatus(BannerModel banner) async {
    try {
      await ref.read(adminBannerProvider.notifier).toggleBannerStatus(banner.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(banner.isActive ? '배너가 비활성화되었습니다' : '배너가 활성화되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}