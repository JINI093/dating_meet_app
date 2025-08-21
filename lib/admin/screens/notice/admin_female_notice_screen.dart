import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';
import '../../models/notice_model.dart';
import '../../providers/notice_provider.dart';
import '../../widgets/admin_data_table.dart';
import '../../widgets/expandable_notice_card.dart';
import '../../../utils/date_formatter.dart';

/// 여성회원 공지사항 화면
class AdminFemaleNoticeScreen extends ConsumerStatefulWidget {
  const AdminFemaleNoticeScreen({super.key});

  @override
  ConsumerState<AdminFemaleNoticeScreen> createState() => _AdminFemaleNoticeScreenState();
}

class _AdminFemaleNoticeScreenState extends ConsumerState<AdminFemaleNoticeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '전체';
  bool _useCardView = true; // 카드뷰/테이블뷰 토글

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noticeState = ref.watch(adminFemaleNoticeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '여성회원 공지사항',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Row(
              children: [
                // 뷰 모드 토글 버튼
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _useCardView = true),
                        icon: Icon(
                          Icons.view_agenda,
                          color: _useCardView ? AdminTheme.primaryColor : Colors.grey,
                        ),
                        tooltip: '카드 뷰',
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.grey[300],
                      ),
                      IconButton(
                        onPressed: () => setState(() => _useCardView = false),
                        icon: Icon(
                          Icons.table_rows,
                          color: !_useCardView ? AdminTheme.primaryColor : Colors.grey,
                        ),
                        tooltip: '테이블 뷰',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AdminTheme.spacingM),
                ElevatedButton.icon(
                  onPressed: () => _showCreateNoticeDialog(),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    '공지사항 작성',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AdminTheme.spacingL,
                      vertical: AdminTheme.spacingM,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),

        // Search and Filter Bar
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '제목, 내용으로 검색',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  ref.read(adminFemaleNoticeProvider.notifier).search(value);
                },
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: '상태',
                  border: OutlineInputBorder(),
                ),
                items: ['전체', '게시중', '임시저장', '예약게시', '보관됨'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedStatus = value!);
                  NoticeStatus? status;
                  switch (value) {
                    case '게시중':
                      status = NoticeStatus.published;
                      break;
                    case '임시저장':
                      status = NoticeStatus.draft;
                      break;
                    case '예약게시':
                      status = NoticeStatus.scheduled;
                      break;
                    case '보관됨':
                      status = NoticeStatus.archived;
                      break;
                  }
                  ref.read(adminFemaleNoticeProvider.notifier).filterByStatus(status);
                },
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            IconButton(
              onPressed: () {
                ref.read(adminFemaleNoticeProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              tooltip: '새로고침',
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),

        // Data Table
        Expanded(
          child: Card(
            child: Column(
              children: [
                // Table Header
                Padding(
                  padding: const EdgeInsets.all(AdminTheme.spacingL),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '총 ${noticeState.totalCount}개',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (noticeState.isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: noticeState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : noticeState.error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error, size: 48, color: Colors.red),
                                  const SizedBox(height: AdminTheme.spacingM),
                                  Text(
                                    '오류가 발생했습니다: ${noticeState.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: AdminTheme.spacingM),
                                  ElevatedButton(
                                    onPressed: () {
                                      ref.read(adminFemaleNoticeProvider.notifier).refresh();
                                    },
                                    child: const Text('다시 시도'),
                                  ),
                                ],
                              ),
                            )
                          : _useCardView
                              ? _buildCardView(noticeState.notices)
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AdminTheme.spacingL),
                                  child: AdminDataTable(
                                    columns: _buildColumns(),
                                    rows: _buildRows(noticeState.notices),
                                    isLoading: false,
                                  ),
                                ),
                ),

                // Pagination
                if (!noticeState.isLoading && noticeState.error == null)
                  Padding(
                    padding: const EdgeInsets.all(AdminTheme.spacingL),
                    child: _buildPagination(noticeState),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      const DataColumn(label: Text('제목')),
      const DataColumn(label: Text('상태')),
      const DataColumn(label: Text('조회수')),
      const DataColumn(label: Text('작성일')),
      const DataColumn(label: Text('작업')),
    ];
  }

  List<DataRow> _buildRows(List<NoticeModel> notices) {
    return notices.map((notice) {
      return DataRow(
        cells: [
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    if (notice.isPinned)
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '고정',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    if (notice.isImportant)
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '중요',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    Flexible(
                      child: Text(
                        notice.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (notice.contentPreview.isNotEmpty)
                  Text(
                    notice.contentPreview,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          DataCell(_buildStatusChip(notice.status)),
          DataCell(Text(notice.viewCount.toString())),
          DataCell(Text(DateFormatter.formatDateTime(notice.createdAt))),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _showEditNoticeDialog(notice),
                  icon: const Icon(Icons.edit, size: 16),
                  tooltip: '수정',
                ),
                IconButton(
                  onPressed: () => _deleteNotice(notice),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  tooltip: '삭제',
                ),
                PopupMenuButton<String>(
                  onSelected: (action) => _handleNoticeAction(notice, action),
                  itemBuilder: (context) => [
                    if (notice.status != NoticeStatus.published)
                      const PopupMenuItem(
                        value: 'publish',
                        child: Text('게시하기'),
                      ),
                    if (notice.status == NoticeStatus.published)
                      const PopupMenuItem(
                        value: 'unpublish',
                        child: Text('게시중단'),
                      ),
                    const PopupMenuItem(
                      value: 'archive',
                      child: Text('보관하기'),
                    ),
                  ],
                  child: const Icon(Icons.more_vert, size: 16),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildCardView(List<NoticeModel> notices) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AdminTheme.spacingL),
      child: ListView.builder(
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          return ExpandableNoticeCard(
            notice: notice,
            onEdit: () => _showEditNoticeDialog(notice),
            onDelete: () => _deleteNotice(notice),
            onStatusChange: (status) {
              ref.read(adminFemaleNoticeProvider.notifier).updateNoticeStatus(
                    notice.id,
                    status,
                  );
            },
          );
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPagination(AdminNoticeState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('총 ${state.totalCount}개 (${state.currentPage}/${state.totalPages} 페이지)'),
        Row(
          children: [
            IconButton(
              onPressed: state.currentPage > 1
                  ? () => ref.read(adminFemaleNoticeProvider.notifier).previousPage()
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text('${state.currentPage} / ${state.totalPages}'),
            IconButton(
              onPressed: state.currentPage < state.totalPages
                  ? () => ref.read(adminFemaleNoticeProvider.notifier).nextPage()
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }

  void _showCreateNoticeDialog() {
    _showNoticeDialog();
  }

  void _showEditNoticeDialog(NoticeModel notice) {
    _showNoticeDialog(notice: notice);
  }

  void _showNoticeDialog({NoticeModel? notice}) {
    final titleController = TextEditingController(text: notice?.title ?? '');
    final contentController = TextEditingController(text: notice?.content ?? '');
    bool isPinned = notice?.isPinned ?? false;
    bool isImportant = notice?.isImportant ?? false;
    NoticeStatus selectedStatus = notice?.status ?? NoticeStatus.draft;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(notice == null ? '공지사항 작성' : '공지사항 수정'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AdminTheme.spacingM),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 8,
                ),
                const SizedBox(height: AdminTheme.spacingM),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<NoticeStatus>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: '상태',
                          border: OutlineInputBorder(),
                        ),
                        items: NoticeStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedStatus = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminTheme.spacingM),
                Row(
                  children: [
                    Checkbox(
                      value: isPinned,
                      onChanged: (value) {
                        setState(() => isPinned = value ?? false);
                      },
                    ),
                    const Text('상단 고정'),
                    const SizedBox(width: AdminTheme.spacingL),
                    Checkbox(
                      value: isImportant,
                      onChanged: (value) {
                        setState(() => isImportant = value ?? false);
                      },
                    ),
                    const Text('중요 공지'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => _saveNotice(
                notice?.id,
                titleController.text,
                contentController.text,
                selectedStatus,
                isPinned,
                isImportant,
              ),
              child: Text(notice == null ? '작성' : '수정'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNotice(
    String? noticeId,
    String title,
    String content,
    NoticeStatus status,
    bool isPinned,
    bool isImportant,
  ) async {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 입력해주세요')),
      );
      return;
    }

    try {
      final dto = NoticeCreateUpdateDto(
        title: title.trim(),
        content: content.trim(),
        targetType: NoticeTargetType.female,
        status: status,
        isPinned: isPinned,
        isImportant: isImportant,
      );

      if (noticeId == null) {
        await ref.read(adminFemaleNoticeProvider.notifier).createNotice(dto);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('공지사항이 작성되었습니다')),
          );
        }
      } else {
        await ref.read(adminFemaleNoticeProvider.notifier).updateNotice(noticeId, dto);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('공지사항이 수정되었습니다')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _deleteNotice(NoticeModel notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공지사항 삭제'),
        content: Text('\'${notice.title}\' 공지사항을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(adminFemaleNoticeProvider.notifier).deleteNotice(notice.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('공지사항이 삭제되었습니다')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
          );
        }
      }
    }
  }

  void _handleNoticeAction(NoticeModel notice, String action) {
    switch (action) {
      case 'publish':
        ref.read(adminFemaleNoticeProvider.notifier).updateNoticeStatus(
              notice.id,
              NoticeStatus.published,
            );
        break;
      case 'unpublish':
        ref.read(adminFemaleNoticeProvider.notifier).updateNoticeStatus(
              notice.id,
              NoticeStatus.draft,
            );
        break;
      case 'archive':
        ref.read(adminFemaleNoticeProvider.notifier).updateNoticeStatus(
              notice.id,
              NoticeStatus.archived,
            );
        break;
    }
  }
}