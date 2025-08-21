import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';
import '../../widgets/excel_download_button.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../../utils/date_formatter.dart';

/// 결제 내역 관리 화면
class AdminPaymentHistoryScreen extends ConsumerStatefulWidget {
  const AdminPaymentHistoryScreen({super.key});

  @override
  ConsumerState<AdminPaymentHistoryScreen> createState() => _AdminPaymentHistoryScreenState();
}

class _AdminPaymentHistoryScreenState extends ConsumerState<AdminPaymentHistoryScreen> {
  String _selectedStatus = '전체';
  String _selectedMethod = '전체';
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(adminPaymentProvider);
    final paymentStatsAsync = ref.watch(paymentStatsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '결제 내역',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ExcelDownloadButton(
              onPressed: () => _downloadExcel(),
              text: '엑셀 다운로드',
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Statistics Cards
        paymentStatsAsync.when(
          data: (stats) => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: '오늘 결제',
                  value: '${_formatNumber(stats['todayAmount'])}원',
                  subtitle: '${stats['todayCount']}건',
                  color: AdminTheme.primaryColor,
                  icon: Icons.payments,
                ),
              ),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  title: '이번 주 결제',
                  value: '${_formatNumber(stats['weekAmount'])}원',
                  subtitle: '${stats['weekCount']}건',
                  color: AdminTheme.successColor,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  title: '이번 달 결제',
                  value: '${_formatNumber(stats['monthAmount'])}원',
                  subtitle: '${stats['monthCount']}건',
                  color: AdminTheme.infoColor,
                  icon: Icons.bar_chart,
                ),
              ),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  title: '결제 실패',
                  value: '${stats['failedCount']}건',
                  subtitle: '실패율 ${stats['failureRate'].toStringAsFixed(1)}%',
                  color: AdminTheme.errorColor,
                  icon: Icons.error,
                ),
              ),
            ],
          ),
          loading: () => Row(
            children: [
              Expanded(child: _buildStatCard(title: '오늘 결제', value: '로딩중...', subtitle: '', color: AdminTheme.primaryColor, icon: Icons.payments)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard(title: '이번 주 결제', value: '로딩중...', subtitle: '', color: AdminTheme.successColor, icon: Icons.trending_up)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard(title: '이번 달 결제', value: '로딩중...', subtitle: '', color: AdminTheme.infoColor, icon: Icons.bar_chart)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard(title: '결제 실패', value: '로딩중...', subtitle: '', color: AdminTheme.errorColor, icon: Icons.error)),
            ],
          ),
          error: (error, stack) => Row(
            children: [
              Expanded(child: _buildStatCard(title: '오늘 결제', value: '0원', subtitle: '0건', color: AdminTheme.primaryColor, icon: Icons.payments)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard(title: '이번 주 결제', value: '0원', subtitle: '0건', color: AdminTheme.successColor, icon: Icons.trending_up)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard(title: '이번 달 결제', value: '0원', subtitle: '0건', color: AdminTheme.infoColor, icon: Icons.bar_chart)),
              const SizedBox(width: AdminTheme.spacingM),
              Expanded(child: _buildStatCard(title: '결제 실패', value: '0건', subtitle: '실패율 0%', color: AdminTheme.errorColor, icon: Icons.error)),
            ],
          ),
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Filters
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AdminTheme.spacingL),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '회원명, 결제번호 검색...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (value) => ref.read(adminPaymentProvider.notifier).search(value),
                  ),
                ),
                const SizedBox(width: AdminTheme.spacingM),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: '전체', child: Text('전체')),
                    DropdownMenuItem(value: '완료', child: Text('완료')),
                    DropdownMenuItem(value: '실패', child: Text('실패')),
                    DropdownMenuItem(value: '취소', child: Text('취소')),
                    DropdownMenuItem(value: '환불', child: Text('환불')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value ?? '전체');
                    PaymentStatus? status;
                    switch (value) {
                      case '완료':
                        status = PaymentStatus.completed;
                        break;
                      case '실패':
                        status = PaymentStatus.failed;
                        break;
                      case '취소':
                        status = PaymentStatus.cancelled;
                        break;
                      case '환불':
                        status = PaymentStatus.refunded;
                        break;
                    }
                    ref.read(adminPaymentProvider.notifier).filterByStatus(status);
                  },
                ),
                const SizedBox(width: AdminTheme.spacingM),
                DropdownButton<String>(
                  value: _selectedMethod,
                  items: const [
                    DropdownMenuItem(value: '전체', child: Text('전체')),
                    DropdownMenuItem(value: '카드', child: Text('카드')),
                    DropdownMenuItem(value: '계좌이체', child: Text('계좌이체')),
                    DropdownMenuItem(value: '페이팔', child: Text('페이팔')),
                    DropdownMenuItem(value: '구글플레이', child: Text('구글플레이')),
                    DropdownMenuItem(value: '앱스토어', child: Text('앱스토어')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedMethod = value ?? '전체');
                    PaymentMethod? method;
                    switch (value) {
                      case '카드':
                        method = PaymentMethod.creditCard;
                        break;
                      case '계좌이체':
                        method = PaymentMethod.bankTransfer;
                        break;
                      case '페이팔':
                        method = PaymentMethod.paypal;
                        break;
                      case '구글플레이':
                        method = PaymentMethod.googlePlay;
                        break;
                      case '앱스토어':
                        method = PaymentMethod.appStore;
                        break;
                    }
                    ref.read(adminPaymentProvider.notifier).filterByPaymentMethod(method);
                  },
                ),
                const SizedBox(width: AdminTheme.spacingM),
                OutlinedButton.icon(
                  onPressed: () => _selectDateRange(),
                  icon: const Icon(Icons.date_range),
                  label: Text(_getDateRangeText()),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Payment Table
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminTheme.spacingL),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '결제 내역 (총 ${paymentState.totalCount}건)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (paymentState.isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: AdminTheme.spacingL),
                  Expanded(
                    child: paymentState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : paymentState.error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error, size: 48, color: Colors.red),
                                    const SizedBox(height: AdminTheme.spacingM),
                                    Text(
                                      '오류가 발생했습니다: ${paymentState.error}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                    const SizedBox(height: AdminTheme.spacingM),
                                    ElevatedButton(
                                      onPressed: () {
                                        ref.read(adminPaymentProvider.notifier).refresh();
                                      },
                                      child: const Text('다시 시도'),
                                    ),
                                  ],
                                ),
                              )
                            : _buildPaymentTable(paymentState.payments),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AdminTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminTheme.spacingS),
            Text(
              title,
              style: const TextStyle(
                color: AdminTheme.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: AdminTheme.secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTable(List<PaymentModel> payments) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('결제번호')),
          DataColumn(label: Text('회원명')),
          DataColumn(label: Text('상품명')),
          DataColumn(label: Text('결제방법')),
          DataColumn(label: Text('금액')),
          DataColumn(label: Text('상태')),
          DataColumn(label: Text('결제일시')),
          DataColumn(label: Text('관리')),
        ],
        rows: payments.map((payment) => _buildPaymentRow(payment)).toList(),
      ),
    );
  }

  DataRow _buildPaymentRow(PaymentModel payment) {
    Color statusColor;
    switch (payment.status) {
      case PaymentStatus.completed:
        statusColor = AdminTheme.successColor;
        break;
      case PaymentStatus.failed:
        statusColor = AdminTheme.errorColor;
        break;
      case PaymentStatus.cancelled:
        statusColor = AdminTheme.warningColor;
        break;
      case PaymentStatus.refunded:
      case PaymentStatus.partialRefund:
        statusColor = AdminTheme.infoColor;
        break;
      default:
        statusColor = AdminTheme.secondaryTextColor;
    }

    return DataRow(
      cells: [
        DataCell(Text(payment.id)),
        DataCell(Text(payment.userName)),
        DataCell(Text(payment.productName)),
        DataCell(Text(payment.paymentMethod.displayName)),
        DataCell(Text(payment.formattedAmount)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              payment.status.displayName,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(Text(DateFormatter.formatDateTime(payment.createdAt))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 18),
                onPressed: () => _viewPaymentDetail(payment.id),
                tooltip: '상세보기',
              ),
              if (payment.status == PaymentStatus.completed)
                IconButton(
                  icon: const Icon(Icons.receipt, size: 18),
                  onPressed: () => _downloadReceipt(payment.id),
                  tooltip: '영수증',
                ),
              if (payment.canRefund)
                IconButton(
                  icon: const Icon(Icons.money_off, size: 18, color: Colors.orange),
                  onPressed: () => _showRefundDialog(payment),
                  tooltip: '환불 처리',
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDateRangeText() {
    if (_startDate != null && _endDate != null) {
      return '${_formatDate(_startDate!)} ~ ${_formatDate(_endDate!)}';
    }
    return '기간 선택';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      ref.read(adminPaymentProvider.notifier).filterByDateRange(_startDate, _endDate);
    }
  }

  void _viewPaymentDetail(String paymentId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$paymentId 상세보기 기능 구현 예정')),
    );
  }

  void _downloadReceipt(String paymentId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$paymentId 영수증 다운로드 기능 구현 예정')),
    );
  }

  void _downloadExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('결제 내역 엑셀 다운로드 시작')),
    );
  }

  void _showRefundDialog(PaymentModel payment) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();
    
    // 기본값으로 전액 환불 금액 설정
    amountController.text = payment.refundableAmount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('환불 처리 - ${payment.id}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('회원명: ${payment.userName}'),
              Text('상품명: ${payment.productName}'),
              Text('결제 금액: ${payment.formattedAmount}'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: '환불 금액 (최대: ${payment.refundableAmount}원)',
                  border: const OutlineInputBorder(),
                  suffixText: '원',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: '환불 사유',
                  border: OutlineInputBorder(),
                  hintText: '환불 사유를 입력하세요',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final refundAmount = int.tryParse(amountController.text) ?? 0;
              final refundReason = reasonController.text.trim();

              if (refundAmount <= 0 || refundAmount > payment.refundableAmount) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('환불 금액은 1원 이상 ${payment.refundableAmount}원 이하여야 합니다'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (refundReason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('환불 사유를 입력하세요'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final dto = RefundProcessDto(
                  refundAmount: refundAmount,
                  refundReason: refundReason,
                  processedBy: 'admin_001', // TODO: 실제 관리자 ID
                );

                await ref.read(adminPaymentProvider.notifier).processRefund(payment.id, dto);
                
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('환불 처리가 완료되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('환불 처리 실패: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('환불 처리'),
          ),
        ],
      ),
    );
  }
}