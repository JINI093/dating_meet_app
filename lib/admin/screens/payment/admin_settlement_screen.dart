import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settlement_records_provider.dart';
import '../../../models/SettlementRecord.dart';

/// 정산 내역 화면
class AdminSettlementScreen extends ConsumerStatefulWidget {
  const AdminSettlementScreen({super.key});

  @override
  ConsumerState<AdminSettlementScreen> createState() => _AdminSettlementScreenState();
}

class _AdminSettlementScreenState extends ConsumerState<AdminSettlementScreen> {
  @override
  Widget build(BuildContext context) {
    final settlementState = ref.watch(settlementRecordsProvider);
    
    return Container(
      color: const Color(0xFFF5F7FA),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '정산내역',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // 페이지 크기 선택 드롭다운
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButton<int>(
                  value: settlementState.pageSize,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('15개씩 보기')),
                    DropdownMenuItem(value: 30, child: Text('30개씩 보기')),
                    DropdownMenuItem(value: 50, child: Text('50개씩 보기')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settlementRecordsProvider.notifier).changePageSize(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 에러 메시지
          if (settlementState.error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                settlementState.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          
          // 테이블
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 테이블 헤더
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildTableHeader('요청 일자', flex: 2),
                        _buildTableHeader('회원이름', flex: 2),
                        _buildTableHeader('개수', flex: 1),
                        _buildTableHeader('정산금액', flex: 2),
                        _buildTableHeader('계좌번호', flex: 2),
                        _buildTableHeader('정산 상태', flex: 2),
                      ],
                    ),
                  ),
                  
                  // 테이블 내용
                  Expanded(
                    child: settlementState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : settlementState.records.isEmpty
                            ? const Center(
                                child: Text(
                                  '정산 내역이 없습니다',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: settlementState.records.length,
                                itemBuilder: (context, index) {
                                  final record = settlementState.records[index];
                                  return _buildTableRow(record, index);
                                },
                              ),
                  ),
                  
                  // 페이지네이션
                  if (settlementState.totalPages > 1)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: settlementState.currentPage > 1
                                ? () => ref.read(settlementRecordsProvider.notifier)
                                    .goToPage(settlementState.currentPage - 1)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text(
                            '${settlementState.currentPage}/${settlementState.totalPages}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            onPressed: settlementState.currentPage < settlementState.totalPages
                                ? () => ref.read(settlementRecordsProvider.notifier)
                                    .goToPage(settlementState.currentPage + 1)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTableRow(SettlementRecord record, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          // 요청 일자
          Expanded(
            flex: 2,
            child: Text(
              record.requestDate ?? '-',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          // 회원이름
          Expanded(
            flex: 2,
            child: Text(
              record.memberName ?? '-',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          // 개수
          Expanded(
            flex: 1,
            child: Text(
              record.pointCount?.toString() ?? '-',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          // 정산금액
          Expanded(
            flex: 2,
            child: Text(
              record.settlementAmount != null
                  ? _formatNumber(record.settlementAmount!)
                  : '-',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          // 계좌번호
          Expanded(
            flex: 2,
            child: Text(
              record.accountNumber ?? '-',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          // 정산 상태
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildStatusChip(record.settlementStatus ?? 'PENDING'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _showStatusDialog(record),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    '상태 관리',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    String displayText;
    
    switch (status) {
      case 'COMPLETED':
        backgroundColor = Colors.green;
        displayText = '정산완료';
        break;
      case 'PROCESSING':
        backgroundColor = Colors.orange;
        displayText = '정산 대기중';
        break;
      case 'PENDING':
      default:
        backgroundColor = Colors.blue;
        displayText = '신청 대기중';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showStatusDialog(SettlementRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${record.memberName} 정산 상태 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('신청 대기중'),
              leading: Radio<String>(
                value: 'PENDING',
                groupValue: record.settlementStatus,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settlementRecordsProvider.notifier)
                        .updateSettlementStatus(record.id, value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('정산 대기중'),
              leading: Radio<String>(
                value: 'PROCESSING',
                groupValue: record.settlementStatus,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settlementRecordsProvider.notifier)
                        .updateSettlementStatus(record.id, value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('정산완료'),
              leading: Radio<String>(
                value: 'COMPLETED',
                groupValue: record.settlementStatus,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settlementRecordsProvider.notifier)
                        .updateSettlementStatus(record.id, value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}