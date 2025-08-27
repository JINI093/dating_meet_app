import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_statistics_provider.dart';
import '../../../models/Payment.dart';
import '../../../utils/date_formatter.dart';

/// 통계 데이터 화면 - 결제 내역 표시
class AdminStatisticsScreen extends ConsumerStatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  ConsumerState<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends ConsumerState<AdminStatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentStatisticsProvider);
    
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
                '통계 데이터',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(paymentStatisticsProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                tooltip: '새로고침',
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 결제 내역 테이블
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
                        _buildTableHeader('결제 일자', flex: 2),
                        _buildTableHeader('결제 상품', flex: 2),
                        _buildTableHeader('회원이름', flex: 2),
                        _buildTableHeader('결제 금액', flex: 2),
                        _buildTableHeader('결제 수단', flex: 2),
                      ],
                    ),
                  ),
                  
                  // 테이블 내용
                  Expanded(
                    child: paymentState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : paymentState.error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error, size: 48, color: Colors.red),
                                    const SizedBox(height: 16),
                                    Text(
                                      paymentState.error!,
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        ref.read(paymentStatisticsProvider.notifier).refresh();
                                      },
                                      child: const Text('다시 시도'),
                                    ),
                                  ],
                                ),
                              )
                            : paymentState.payments.isEmpty
                                ? const Center(
                                    child: Text(
                                      '결제 내역이 없습니다',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: paymentState.payments.length,
                                    itemBuilder: (context, index) {
                                      final payment = paymentState.payments[index];
                                      return _buildTableRow(payment, index);
                                    },
                                  ),
                  ),
                  
                  // 페이징
                  if (!paymentState.isLoading && paymentState.error == null && paymentState.payments.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: paymentState.currentPage > 1
                                ? () => ref.read(paymentStatisticsProvider.notifier).previousPage()
                                : null,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text(
                            '${paymentState.currentPage}/${paymentState.totalPages}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            onPressed: paymentState.currentPage < paymentState.totalPages
                                ? () => ref.read(paymentStatisticsProvider.notifier).nextPage()
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
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableRow(Payment payment, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          // 결제 일자
          Expanded(
            flex: 2,
            child: Text(
              DateFormatter.formatDate(payment.createdAt.getDateTimeInUtc()),
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          // 결제 상품
          Expanded(
            flex: 2,
            child: Text(
              _getProductDisplayName(payment.productName),
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          // 회원이름 (userId에서 추출)
          Expanded(
            flex: 2,
            child: Text(
              _getUserDisplayName(payment.userId),
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          // 결제 금액
          Expanded(
            flex: 2,
            child: Text(
              _formatAmount(payment.amount.toDouble()),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // 결제 수단
          Expanded(
            flex: 2,
            child: Text(
              _getPaymentMethodDisplayName(payment.paymentMethod),
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getProductDisplayName(String productName) {
    if (productName.contains('heart') || productName.contains('하트')) {
      return '하트';
    } else if (productName.contains('superchat') || productName.contains('슈퍼챗')) {
      return '슈퍼챗';
    } else if (productName.contains('vip') || productName.contains('VIP')) {
      if (productName.contains('silver') || productName.contains('실버')) {
        return 'VIP 실버';
      } else if (productName.contains('gold') || productName.contains('골드')) {
        return 'VIP 골드';
      } else {
        return 'VIP';
      }
    } else if (productName.contains('point') || productName.contains('포인트')) {
      return '포인트';
    }
    return productName;
  }

  String _getUserDisplayName(String userId) {
    // userId를 기반으로 익명화된 표시명 생성
    if (userId.length >= 6) {
      final prefix = userId.substring(0, 3);
      return '$prefix***';
    }
    return '익명';
  }

  String _formatAmount(double amount) {
    if (amount == amount.toInt()) {
      return '${amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},',
      )}원';
    }
    return '${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    )}원';
  }

  String _getPaymentMethodDisplayName(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'card':
      case 'credit_card':
      case 'creditcard':
        return '신용카드';
      case 'npay':
      case 'naver_pay':
        return 'NPay';
      case 'toss':
      case 'tosspay':
      case 'toss_pay':
        return 'TossPay';
      case 'kakao':
      case 'kakaopay':
      case 'kakao_pay':
        return 'KakaoPay';
      case 'payco':
        return 'PAYCO';
      case 'samsung':
      case 'samsung_pay':
        return 'Samsung Pay';
      default:
        return paymentMethod;
    }
  }
}