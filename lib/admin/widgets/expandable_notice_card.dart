import 'package:flutter/material.dart';
import '../models/notice_model.dart';
import '../utils/admin_theme.dart';
import '../../utils/date_formatter.dart';

/// 확장 가능한 공지사항 카드 위젯
class ExpandableNoticeCard extends StatefulWidget {
  final NoticeModel notice;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(NoticeStatus)? onStatusChange;

  const ExpandableNoticeCard({
    super.key,
    required this.notice,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
  });

  @override
  State<ExpandableNoticeCard> createState() => _ExpandableNoticeCardState();
}

class _ExpandableNoticeCardState extends State<ExpandableNoticeCard> 
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AdminTheme.spacingM),
      elevation: 2,
      child: Column(
        children: [
          // Header - 항상 표시
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpansion,
              child: Padding(
                padding: const EdgeInsets.all(AdminTheme.spacingM),
                child: Row(
                  children: [
                    // 확장/축소 아이콘
                    AnimatedRotation(
                      turns: _isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.chevron_right),
                    ),
                    const SizedBox(width: AdminTheme.spacingS),
                    
                    // 제목과 기본 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // 고정, 중요 배지
                              if (widget.notice.isPinned)
                                Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '고정',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              if (widget.notice.isImportant)
                                Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '중요',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              
                              // 제목
                              Expanded(
                                child: Text(
                                  widget.notice.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildStatusChip(widget.notice.status),
                              const SizedBox(width: 8),
                              Text(
                                '조회수 ${widget.notice.viewCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormatter.formatDateTime(widget.notice.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // 액션 버튼들
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit, size: 18),
                          tooltip: '수정',
                        ),
                        IconButton(
                          onPressed: widget.onDelete,
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                          tooltip: '삭제',
                        ),
                        PopupMenuButton<String>(
                          onSelected: (action) => _handleStatusAction(action),
                          itemBuilder: (context) => [
                            if (widget.notice.status != NoticeStatus.published)
                              const PopupMenuItem(
                                value: 'publish',
                                child: Text('게시하기'),
                              ),
                            if (widget.notice.status == NoticeStatus.published)
                              const PopupMenuItem(
                                value: 'unpublish',
                                child: Text('게시중단'),
                              ),
                            const PopupMenuItem(
                              value: 'archive',
                              child: Text('보관하기'),
                            ),
                          ],
                          child: const Icon(Icons.more_vert, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 확장 영역 - 애니메이션으로 표시/숨김
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AdminTheme.spacingL),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 왼쪽: 데스크톱 뷰 (내용)
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '데스크톱 뷰',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: AdminTheme.spacingM),
                          Container(
                            padding: const EdgeInsets.all(AdminTheme.spacingM),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.notice.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '작성자: ${widget.notice.authorName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '작성일: ${DateFormatter.formatDateTime(widget.notice.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Divider(height: 24),
                                Text(
                                  widget.notice.content,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: AdminTheme.spacingXL),
                    
                    // 오른쪽: 모바일 미리보기
                    Column(
                      children: [
                        Text(
                          '모바일 미리보기',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: AdminTheme.spacingM),
                        Container(
                          width: 250,
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Column(
                              children: [
                                // 모바일 상태바
                                Container(
                                  height: 30,
                                  color: Colors.black,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // 모바일 앱 헤더
                                Container(
                                  height: 50,
                                  color: Colors.blue,
                                  child: const Row(
                                    children: [
                                      SizedBox(width: 16),
                                      Icon(Icons.arrow_back, color: Colors.white, size: 20),
                                      SizedBox(width: 16),
                                      Text(
                                        '공지사항',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // 모바일 내용 영역
                                Expanded(
                                  child: Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(12),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 모바일에서의 제목
                                          Text(
                                            widget.notice.title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          
                                          // 모바일에서의 메타 정보
                                          Text(
                                            '${widget.notice.authorName} • ${DateFormatter.formatDateTime(widget.notice.createdAt)}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // 구분선
                                          Container(
                                            height: 1,
                                            color: Colors.grey[300],
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // 모바일에서의 내용
                                          Text(
                                            widget.notice.content,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // 모바일 하단 네비게이션 (선택적)
                                Container(
                                  height: 20,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(NoticeStatus status) {
    Color color;
    String text;

    switch (status) {
      case NoticeStatus.published:
        color = Colors.green;
        text = '게시중';
        break;
      case NoticeStatus.draft:
        color = Colors.grey;
        text = '임시저장';
        break;
      case NoticeStatus.scheduled:
        color = Colors.blue;
        text = '예약게시';
        break;
      case NoticeStatus.archived:
        color = Colors.orange;
        text = '보관됨';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleStatusAction(String action) {
    NoticeStatus? newStatus;
    switch (action) {
      case 'publish':
        newStatus = NoticeStatus.published;
        break;
      case 'unpublish':
        newStatus = NoticeStatus.draft;
        break;
      case 'archive':
        newStatus = NoticeStatus.archived;
        break;
    }
    
    if (newStatus != null) {
      widget.onStatusChange?.call(newStatus);
    }
  }
}