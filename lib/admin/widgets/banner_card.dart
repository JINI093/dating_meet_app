import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../utils/admin_theme.dart';
import '../../utils/date_formatter.dart';

/// 배너 카드 위젯
class BannerCard extends StatelessWidget {
  final BannerModel banner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const BannerCard({
    super.key,
    required this.banner,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 영역
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Stack(
                  children: [
                    // 배너 이미지
                    banner.imageUrl.isNotEmpty && _isValidImageUrl(banner.imageUrl)
                        ? Image.network(
                            banner.imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackBanner();
                            },
                          )
                        : _buildFallbackBanner(),
                    
                    // 상태 배지
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: banner.isActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          banner.isActive ? '활성' : '비활성',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

          // 내용 영역
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AdminTheme.spacingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    banner.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // 설명
                  if (banner.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      banner.description!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const Spacer(),

                  // 액션 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormatter.formatDate(banner.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: onToggleStatus,
                            icon: Icon(
                              banner.isActive ? Icons.visibility_off : Icons.visibility,
                              size: 16,
                            ),
                            tooltip: banner.isActive ? '비활성화' : '활성화',
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          IconButton(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 16),
                            tooltip: '수정',
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                            tooltip: '삭제',
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getBannerColors(banner.type),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getBannerIcon(banner.type),
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              banner.type.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && 
             (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  List<Color> _getBannerColors(BannerType type) {
    switch (type) {
      case BannerType.mainAd:
        return [Colors.blue[400]!, Colors.blue[600]!];
      case BannerType.pointStore:
        return [Colors.green[400]!, Colors.green[600]!];
      case BannerType.terms:
        return [Colors.orange[400]!, Colors.orange[600]!];
    }
  }

  IconData _getBannerIcon(BannerType type) {
    switch (type) {
      case BannerType.mainAd:
        return Icons.ads_click;
      case BannerType.pointStore:
        return Icons.store;
      case BannerType.terms:
        return Icons.description;
    }
  }

}