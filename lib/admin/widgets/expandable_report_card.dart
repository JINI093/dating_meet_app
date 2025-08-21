import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../utils/admin_theme.dart';
import '../../utils/date_formatter.dart';

/// 확장 가능한 신고 카드 위젯
class ExpandableReportCard extends StatefulWidget {
  final ReportModel report;
  final Function(ReportProcessDto)? onProcess;
  final Function(ReportStatus)? onStatusChange;

  const ExpandableReportCard({
    super.key,
    required this.report,
    this.onProcess,
    this.onStatusChange,
  });

  @override
  State<ExpandableReportCard> createState() => _ExpandableReportCardState();
}

class _ExpandableReportCardState extends State<ExpandableReportCard> 
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
                    
                    // 신고 기본 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // 우선순위 배지
                              _buildPriorityChip(widget.report.priority),
                              const SizedBox(width: 8),
                              
                              // 신고 유형
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getReportTypeColor(widget.report.reportType).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _getReportTypeColor(widget.report.reportType).withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  widget.report.reportType.displayName,
                                  style: TextStyle(
                                    color: _getReportTypeColor(widget.report.reportType),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              
                              // 신고 ID
                              Text(
                                'ID: ${widget.report.id}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '신고자: ${widget.report.reporterName}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '피신고자: ${widget.report.reportedName}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildStatusChip(widget.report.status),
                              const SizedBox(width: 8),
                              Text(
                                DateFormatter.formatDateTime(widget.report.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (widget.report.processedAt != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '처리일: ${DateFormatter.formatDateTime(widget.report.processedAt!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.report.reportReason,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 액션 버튼들
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!widget.report.isProcessed)
                          IconButton(
                            onPressed: () => _showProcessDialog(),
                            icon: const Icon(Icons.assignment_turned_in, size: 18, color: Colors.green),
                            tooltip: '처리하기',
                          ),
                        PopupMenuButton<String>(
                          onSelected: (action) => _handleStatusAction(action),
                          itemBuilder: (context) => [
                            if (widget.report.status != ReportStatus.pending)
                              const PopupMenuItem(
                                value: 'pending',
                                child: Text('대기중으로 변경'),
                              ),
                            if (widget.report.status != ReportStatus.inProgress)
                              const PopupMenuItem(
                                value: 'inProgress',
                                child: Text('처리중으로 변경'),
                              ),
                            if (widget.report.status != ReportStatus.resolved)
                              const PopupMenuItem(
                                value: 'resolved',
                                child: Text('처리완료로 변경'),
                              ),
                            if (widget.report.status != ReportStatus.rejected)
                              const PopupMenuItem(
                                value: 'rejected',
                                child: Text('반려로 변경'),
                              ),
                            if (widget.report.status != ReportStatus.closed)
                              const PopupMenuItem(
                                value: 'closed',
                                child: Text('종료로 변경'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 신고 내용 상세
                    _buildDetailSection('신고 내용', widget.report.reportContent),
                    
                    const SizedBox(height: AdminTheme.spacingL),
                    
                    // 증거 자료
                    if (widget.report.evidence.isNotEmpty) ...[
                      _buildEvidenceSection(),
                      const SizedBox(height: AdminTheme.spacingL),
                    ],
                    
                    // 관리자 메모
                    if (widget.report.adminNotes != null && widget.report.adminNotes!.isNotEmpty) ...[
                      _buildDetailSection('관리자 메모', widget.report.adminNotes!),
                      const SizedBox(height: AdminTheme.spacingL),
                    ],
                    
                    // 처리 정보
                    if (widget.report.processedBy != null) ...[
                      _buildProcessInfo(),
                    ],
                    
                    // 처리 결과
                    if (widget.report.action != null) ...[
                      const SizedBox(height: AdminTheme.spacingL),
                      _buildActionInfo(),
                    ],
                    
                    // 추가 상세 정보
                    const SizedBox(height: AdminTheme.spacingL),
                    _buildAdditionalDetails(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '증거 자료',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.report.evidence.map((evidence) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    evidence.endsWith('.jpg') || evidence.endsWith('.png') 
                        ? Icons.image 
                        : Icons.description,
                    size: 16,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    evidence,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '처리 정보',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text('처리자: ${widget.report.processedBy}'),
          if (widget.report.processedAt != null)
            Text('처리일: ${DateFormatter.formatDateTime(widget.report.processedAt!)}'),
          if (widget.report.processingTime != null)
            Text('처리 소요시간: ${_formatDuration(widget.report.processingTime!)}'),
        ],
      ),
    );
  }

  Widget _buildActionInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '처리 결과',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getActionColor(widget.report.action!).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getActionColor(widget.report.action!)),
            ),
            child: Text(
              widget.report.action!.displayName,
              style: TextStyle(
                color: _getActionColor(widget.report.action!),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
          Icon(icon, size: 12, color: color),
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

  Color _getActionColor(ReportAction action) {
    switch (action) {
      case ReportAction.suspendedPermanent:
        return Colors.red[800]!;
      case ReportAction.suspended30Days:
        return Colors.red[600]!;
      case ReportAction.suspended5Days:
        return Colors.orange[600]!;
      case ReportAction.suspended3Days:
        return Colors.orange[400]!;
      case ReportAction.warning:
        return Colors.amber[600]!;
      case ReportAction.rejected:
        return Colors.grey[600]!;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }

  Widget _buildAdditionalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '추가 상세 정보',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AdminTheme.spacingM),
        
        // 상세 정보 그리드
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AdminTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 신고한 사진 (evidence에서 이미지 파일들)
              _buildDetailRow('신고한 사진', _getReportedImages()),
              const SizedBox(height: AdminTheme.spacingM),
              
              // 신고자 정보
              _buildDetailRow('신고자 ID', widget.report.reporterUserId),
              const SizedBox(height: AdminTheme.spacingS),
              _buildDetailRow('신고자 이름', widget.report.reporterName),
              const SizedBox(height: AdminTheme.spacingM),
              
              // 피신고자 정보
              _buildDetailRow('피신고자 ID', widget.report.reportedUserId),
              const SizedBox(height: AdminTheme.spacingS),
              _buildDetailRow('피신고자 이름', widget.report.reportedName),
              const SizedBox(height: AdminTheme.spacingM),
              
              // 이용정지 정보 (처리 결과에 따라)
              if (widget.report.action != null && _isSuspensionAction(widget.report.action!)) ...[
                _buildSuspensionInfo(),
                const SizedBox(height: AdminTheme.spacingM),
              ],
              
              // 이전 이력 (가상 데이터 - 실제로는 다른 테이블에서 조회해야 함)
              _buildPreviousHistory(),
              const SizedBox(height: AdminTheme.spacingM),
              
              // 블랙리스트 여부 (가상 데이터)
              _buildBlacklistStatus(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _getReportedImages() {
    final imageFiles = widget.report.evidence
        .where((evidence) => evidence.toLowerCase().endsWith('.jpg') || 
                            evidence.toLowerCase().endsWith('.png') || 
                            evidence.toLowerCase().endsWith('.jpeg') ||
                            evidence.toLowerCase().endsWith('.gif'))
        .toList();
    
    return imageFiles.isEmpty ? '없음' : imageFiles.join(', ');
  }

  bool _isSuspensionAction(ReportAction action) {
    return [
      ReportAction.suspended3Days,
      ReportAction.suspended5Days,
      ReportAction.suspended30Days,
      ReportAction.suspendedPermanent,
    ].contains(action);
  }

  Widget _buildSuspensionInfo() {
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;
    
    // 처리된 시간을 시작 시간으로 사용
    if (widget.report.processedAt != null) {
      startDate = widget.report.processedAt!;
      
      // 처리 결과에 따라 종료 시간 계산
      switch (widget.report.action!) {
        case ReportAction.suspended3Days:
          endDate = startDate.add(const Duration(days: 3));
          break;
        case ReportAction.suspended5Days:
          endDate = startDate.add(const Duration(days: 5));
          break;
        case ReportAction.suspended30Days:
          endDate = startDate.add(const Duration(days: 30));
          break;
        case ReportAction.suspendedPermanent:
          endDate = null; // 영구정지
          break;
        default:
          endDate = null;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이용정지 정보',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          if (startDate != null) ...[
            Text('시작일: ${DateFormatter.formatDateTime(startDate)}'),
            const SizedBox(height: 4),
          ],
          if (endDate != null) ...[
            Text('만료일: ${DateFormatter.formatDateTime(endDate)}'),
            const SizedBox(height: 4),
            Text(
              '상태: ${endDate.isAfter(now) ? "정지중" : "해제됨"}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: endDate.isAfter(now) ? Colors.red : Colors.green,
              ),
            ),
          ] else if (widget.report.action == ReportAction.suspendedPermanent) ...[
            const Text(
              '만료일: 영구정지',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviousHistory() {
    // 실제로는 database에서 해당 사용자의 이전 신고 이력을 조회해야 함
    // 여기서는 가상 데이터로 표시
    final previousReports = _getMockPreviousHistory();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이전 이력',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: previousReports.isEmpty
              ? const Text(
                  '이전 신고 이력이 없습니다.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Column(
                  children: previousReports.map((history) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history['date'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          history['type'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          history['result'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: (history['result'] ?? '').contains('정지') ? Colors.red : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildBlacklistStatus() {
    // 실제로는 blacklist 테이블에서 조회해야 함
    // 여기서는 가상 데이터로 표시
    final isBlacklisted = _getMockBlacklistStatus();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBlacklisted ? Colors.red[50] : Colors.green[50],
        border: Border.all(color: isBlacklisted ? Colors.red[200]! : Colors.green[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isBlacklisted ? Icons.block : Icons.check_circle,
            color: isBlacklisted ? Colors.red : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '블랙리스트 상태: ${isBlacklisted ? "등록됨" : "정상"}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isBlacklisted ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getMockPreviousHistory() {
    // Mock data - 실제로는 database에서 조회
    if (widget.report.reportedUserId == 'user_101') {
      return [
        {
          'date': '2024-01-15',
          'type': '부적절한 프로필 사진',
          'result': '경고 처리',
        },
        {
          'date': '2023-12-10',
          'type': '스팸 메시지 발송',
          'result': '3일 이용정지',
        },
      ];
    }
    return [];
  }

  bool _getMockBlacklistStatus() {
    // Mock data - 실제로는 blacklist 테이블에서 조회
    return widget.report.reportedUserId == 'user_102' || 
           widget.report.action == ReportAction.suspendedPermanent;
  }

  void _showProcessDialog() {
    ReportAction? selectedAction;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('신고 처리'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                widget.onProcess?.call(dto);
                Navigator.of(context).pop();
              } : null,
              child: const Text('처리 완료'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStatusAction(String action) {
    ReportStatus? newStatus;
    switch (action) {
      case 'pending':
        newStatus = ReportStatus.pending;
        break;
      case 'inProgress':
        newStatus = ReportStatus.inProgress;
        break;
      case 'resolved':
        newStatus = ReportStatus.resolved;
        break;
      case 'rejected':
        newStatus = ReportStatus.rejected;
        break;
      case 'closed':
        newStatus = ReportStatus.closed;
        break;
    }
    
    if (newStatus != null) {
      widget.onStatusChange?.call(newStatus);
    }
  }
}