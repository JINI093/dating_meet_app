import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';
import '../../models/report_model.dart';
import '../../providers/report_provider.dart';
import '../../widgets/admin_data_table.dart';
import '../../widgets/expandable_report_card.dart';
import '../../../utils/date_formatter.dart';

/// 신고 관리 화면
class AdminReportScreen extends ConsumerStatefulWidget {
  const AdminReportScreen({super.key});

  @override
  ConsumerState<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends ConsumerState<AdminReportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '전체';
  String _selectedReportType = '전체';
  String _selectedPriority = '전체';
  bool _useCardView = true; // 카드뷰/테이블뷰 토글

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(adminReportProvider);
    final reportStatsAsync = ref.watch(reportStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '신고 관리',
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
                IconButton(
                  onPressed: () {
                    ref.read(adminReportProvider.notifier).refresh();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: '새로고침',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),

        // 통계 카드
        reportStatsAsync.when(
          data: (reportStats) => Row(
            children: [
              Expanded(
                child: _buildStatCard('전체 신고', reportStats['total'] ?? 0, Icons.report, Colors.blue),
              ),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(
                child: _buildStatCard('대기중', reportStats['pending'] ?? 0, Icons.hourglass_empty, Colors.orange),
              ),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(
                child: _buildStatCard('처리중', reportStats['inProgress'] ?? 0, Icons.work, Colors.blue),
              ),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(
                child: _buildStatCard('처리완료', reportStats['resolved'] ?? 0, Icons.check_circle, Colors.green),
              ),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(
                child: _buildStatCard('긴급', reportStats['urgent'] ?? 0, Icons.warning, Colors.red),
              ),
            ],
          ),
          loading: () => Row(
            children: [
              Expanded(child: _buildStatCard('전체 신고', 0, Icons.report, Colors.blue)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard('대기중', 0, Icons.hourglass_empty, Colors.orange)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard('처리중', 0, Icons.work, Colors.blue)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard('처리완료', 0, Icons.check_circle, Colors.green)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard('긴급', 0, Icons.warning, Colors.red)),
            ],
          ),
          error: (error, stack) => Row(
            children: [
              Expanded(child: _buildStatCard('전체 신고', 0, Icons.report, Colors.blue)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard('대기중', 0, Icons.hourglass_empty, Colors.orange)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard('처리중', 0, Icons.work, Colors.blue)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard('처리완료', 0, Icons.check_circle, Colors.green)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard('긴급', 0, Icons.warning, Colors.red)),
            ],
          ),
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
                  hintText: '신고자, 피신고자, 내용으로 검색',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  ref.read(adminReportProvider.notifier).search(value);
                },
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            SizedBox(
              width: 130,
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: '상태',
                  border: OutlineInputBorder(),
                ),
                items: ['전체', '접수', '처리중', '처리완료', '반려', '종료'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedStatus = value!);
                  ReportStatus? status;
                  switch (value) {
                    case '접수':
                      status = ReportStatus.pending;
                      break;
                    case '처리중':
                      status = ReportStatus.inProgress;
                      break;
                    case '처리완료':
                      status = ReportStatus.resolved;
                      break;
                    case '반려':
                      status = ReportStatus.rejected;
                      break;
                    case '종료':
                      status = ReportStatus.closed;
                      break;
                  }
                  ref.read(adminReportProvider.notifier).filterByStatus(status);
                },
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            SizedBox(
              width: 130,
              child: DropdownButtonFormField<String>(
                value: _selectedReportType,
                decoration: const InputDecoration(
                  labelText: '신고유형',
                  border: OutlineInputBorder(),
                ),
                items: ['전체', '프로필 악용', '부적절한 내용', '괴롭힘', '스팸', '사기', '가짜 프로필', '미성년자', '폭력적 내용', '성적 내용', '기타'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedReportType = value!);
                  ReportType? reportType;
                  switch (value) {
                    case '프로필 악용':
                      reportType = ReportType.profileAbuse;
                      break;
                    case '부적절한 내용':
                      reportType = ReportType.inappropriateContent;
                      break;
                    case '괴롭힘':
                      reportType = ReportType.harassment;
                      break;
                    case '스팸':
                      reportType = ReportType.spam;
                      break;
                    case '사기':
                      reportType = ReportType.scam;
                      break;
                    case '가짜 프로필':
                      reportType = ReportType.fakeProfile;
                      break;
                    case '미성년자':
                      reportType = ReportType.underage;
                      break;
                    case '폭력적 내용':
                      reportType = ReportType.violence;
                      break;
                    case '성적 내용':
                      reportType = ReportType.sexualContent;
                      break;
                    case '기타':
                      reportType = ReportType.other;
                      break;
                  }
                  ref.read(adminReportProvider.notifier).filterByReportType(reportType);
                },
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: '우선순위',
                  border: OutlineInputBorder(),
                ),
                items: ['전체', '긴급', '높음', '보통', '낮음'].map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedPriority = value!);
                  ReportPriority? priority;
                  switch (value) {
                    case '긴급':
                      priority = ReportPriority.urgent;
                      break;
                    case '높음':
                      priority = ReportPriority.high;
                      break;
                    case '보통':
                      priority = ReportPriority.normal;
                      break;
                    case '낮음':
                      priority = ReportPriority.low;
                      break;
                  }
                  ref.read(adminReportProvider.notifier).filterByPriority(priority);
                },
              ),
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
                        '총 ${reportState.totalCount}개',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (reportState.isLoading)
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
                  child: reportState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : reportState.error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error, size: 48, color: Colors.red),
                                  const SizedBox(height: AdminTheme.spacingM),
                                  Text(
                                    '오류가 발생했습니다: ${reportState.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: AdminTheme.spacingM),
                                  ElevatedButton(
                                    onPressed: () {
                                      ref.read(adminReportProvider.notifier).refresh();
                                    },
                                    child: const Text('다시 시도'),
                                  ),
                                ],
                              ),
                            )
                          : _useCardView
                              ? _buildCardView(reportState.reports)
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AdminTheme.spacingL),
                                  child: AdminDataTable(
                                    columns: _buildColumns(),
                                    rows: _buildRows(reportState.reports),
                                    isLoading: false,
                                  ),
                                ),
                ),

                // Pagination
                if (!reportState.isLoading && reportState.error == null)
                  Padding(
                    padding: const EdgeInsets.all(AdminTheme.spacingL),
                    child: _buildPagination(reportState),
                  ),
              ],
            ),
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

  Widget _buildCardView(List<ReportModel> reports) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AdminTheme.spacingL),
      child: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return ExpandableReportCard(
            report: report,
            onProcess: (dto) {
              ref.read(adminReportProvider.notifier).processReport(report.id, dto);
            },
            onStatusChange: (status) {
              ref.read(adminReportProvider.notifier).updateReportStatus(report.id, status);
            },
          );
        },
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      const DataColumn(label: Text('ID/신고자')),
      const DataColumn(label: Text('피신고자')),
      const DataColumn(label: Text('신고유형')),
      const DataColumn(label: Text('상태')),
      const DataColumn(label: Text('우선순위')),
      const DataColumn(label: Text('신고일')),
      const DataColumn(label: Text('작업')),
    ];
  }

  List<DataRow> _buildRows(List<ReportModel> reports) {
    return reports.map((report) {
      return DataRow(
        cells: [
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  report.id,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Colors.grey,
                  ),
                ),
                Text(
                  report.reporterName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          DataCell(
            Text(
              report.reportedName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getReportTypeColor(report.reportType).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getReportTypeColor(report.reportType).withValues(alpha: 0.3)),
              ),
              child: Text(
                report.reportType.displayName,
                style: TextStyle(
                  color: _getReportTypeColor(report.reportType),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          DataCell(_buildStatusChip(report.status)),
          DataCell(_buildPriorityChip(report.priority)),
          DataCell(Text(DateFormatter.formatDateTime(report.createdAt))),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!report.isProcessed)
                  IconButton(
                    onPressed: () => _processReport(report),
                    icon: const Icon(Icons.assignment_turned_in, size: 16, color: Colors.green),
                    tooltip: '처리하기',
                  ),
                PopupMenuButton<String>(
                  onSelected: (action) => _handleReportAction(report, action),
                  itemBuilder: (context) => [
                    if (report.status != ReportStatus.pending)
                      const PopupMenuItem(
                        value: 'pending',
                        child: Text('대기중으로 변경'),
                      ),
                    if (report.status != ReportStatus.inProgress)
                      const PopupMenuItem(
                        value: 'inProgress',
                        child: Text('처리중으로 변경'),
                      ),
                    if (report.status != ReportStatus.resolved)
                      const PopupMenuItem(
                        value: 'resolved',
                        child: Text('처리완료로 변경'),
                      ),
                    if (report.status != ReportStatus.rejected)
                      const PopupMenuItem(
                        value: 'rejected',
                        child: Text('반려로 변경'),
                      ),
                    const PopupMenuItem(
                      value: 'detail',
                      child: Text('상세보기'),
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

  Widget _buildStatusChip(ReportStatus status) {
    Color color;
    String text;

    switch (status) {
      case ReportStatus.pending:
        color = Colors.orange;
        text = status.displayName;
        break;
      case ReportStatus.inProgress:
        color = Colors.blue;
        text = status.displayName;
        break;
      case ReportStatus.resolved:
        color = Colors.green;
        text = status.displayName;
        break;
      case ReportStatus.rejected:
        color = Colors.red;
        text = status.displayName;
        break;
      case ReportStatus.closed:
        color = Colors.grey;
        text = status.displayName;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

  Widget _buildPriorityChip(ReportPriority priority) {
    Color color;
    IconData icon;

    switch (priority) {
      case ReportPriority.urgent:
        color = Colors.red;
        icon = Icons.warning;
        break;
      case ReportPriority.high:
        color = Colors.orange;
        icon = Icons.priority_high;
        break;
      case ReportPriority.normal:
        color = Colors.blue;
        icon = Icons.info;
        break;
      case ReportPriority.low:
        color = Colors.grey;
        icon = Icons.low_priority;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            priority.displayName,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getReportTypeColor(ReportType type) {
    switch (type) {
      case ReportType.harassment:
      case ReportType.violence:
        return Colors.red;
      case ReportType.inappropriateContent:
      case ReportType.sexualContent:
        return Colors.purple;
      case ReportType.scam:
      case ReportType.spam:
        return Colors.orange;
      case ReportType.fakeProfile:
      case ReportType.underage:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPagination(AdminReportState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('총 ${state.totalCount}개 (${state.currentPage}/${state.totalPages} 페이지)'),
        Row(
          children: [
            IconButton(
              onPressed: state.currentPage > 1
                  ? () => ref.read(adminReportProvider.notifier).previousPage()
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text('${state.currentPage} / ${state.totalPages}'),
            IconButton(
              onPressed: state.currentPage < state.totalPages
                  ? () => ref.read(adminReportProvider.notifier).nextPage()
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }

  void _processReport(ReportModel report) {
    ReportAction? selectedAction;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('신고 처리 - ${report.id}'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('신고자: ${report.reporterName}'),
                Text('피신고자: ${report.reportedName}'),
                Text('신고 유형: ${report.reportType.displayName}'),
                const SizedBox(height: 16),
                DropdownButtonFormField<ReportAction>(
                  value: selectedAction,
                  decoration: const InputDecoration(
                    labelText: '처리 결과',
                    border: OutlineInputBorder(),
                  ),
                  items: ReportAction.values.map((action) {
                    return DropdownMenuItem(
                      value: action,
                      child: Text(action.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAction = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: '처리 메모',
                    border: OutlineInputBorder(),
                    hintText: '처리 내용을 입력하세요',
                  ),
                  maxLines: 3,
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
              onPressed: selectedAction != null ? () {
                ReportStatus status;
                if (selectedAction == ReportAction.rejected) {
                  status = ReportStatus.rejected;
                } else {
                  status = ReportStatus.resolved;
                }
                
                final dto = ReportProcessDto(
                  status: status,
                  action: selectedAction,
                  adminNotes: notesController.text,
                  processedBy: 'admin_001', // TODO: 실제 관리자 ID
                );
                ref.read(adminReportProvider.notifier).processReport(report.id, dto);
                Navigator.of(context).pop();
              } : null,
              child: const Text('처리 완료'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleReportAction(ReportModel report, String action) {
    switch (action) {
      case 'pending':
        ref.read(adminReportProvider.notifier).updateReportStatus(report.id, ReportStatus.pending);
        break;
      case 'inProgress':
        ref.read(adminReportProvider.notifier).updateReportStatus(report.id, ReportStatus.inProgress);
        break;
      case 'resolved':
        ref.read(adminReportProvider.notifier).updateReportStatus(report.id, ReportStatus.resolved);
        break;
      case 'rejected':
        ref.read(adminReportProvider.notifier).updateReportStatus(report.id, ReportStatus.rejected);
        break;
      case 'detail':
        _showReportDetail(report);
        break;
    }
  }

  void _showReportDetail(ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('신고 상세 - ${report.id}'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('신고자', report.reporterName),
                _buildDetailRow('피신고자', report.reportedName),
                _buildDetailRow('신고 유형', report.reportType.displayName),
                _buildDetailRow('신고 사유', report.reportReason),
                _buildDetailRow('신고 내용', report.reportContent),
                if (report.evidence.isNotEmpty)
                  _buildDetailRow('증거 자료', report.evidence.join(', ')),
                _buildDetailRow('상태', report.status.displayName),
                _buildDetailRow('우선순위', report.priority.displayName),
                if (report.action != null)
                  _buildDetailRow('처리 결과', report.action!.displayName),
                _buildDetailRow('신고일', DateFormatter.formatDateTime(report.createdAt)),
                if (report.processedBy != null)
                  _buildDetailRow('처리자', report.processedBy!),
                if (report.processedAt != null)
                  _buildDetailRow('처리일', DateFormatter.formatDateTime(report.processedAt!)),
                if (report.adminNotes != null && report.adminNotes!.isNotEmpty)
                  _buildDetailRow('관리자 메모', report.adminNotes!),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}