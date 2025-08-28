import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:convert';
import '../../models/Payment.dart';

// Provider for payment statistics
final paymentStatisticsProvider = StateNotifierProvider<PaymentStatisticsNotifier, PaymentStatisticsState>((ref) {
  return PaymentStatisticsNotifier();
});

// State class
class PaymentStatisticsState {
  final List<Payment> payments;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  PaymentStatisticsState({
    required this.payments,
    required this.isLoading,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
  });

  PaymentStatisticsState copyWith({
    List<Payment>? payments,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalCount,
  }) {
    return PaymentStatisticsState(
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

// Notifier class
class PaymentStatisticsNotifier extends StateNotifier<PaymentStatisticsState> {
  PaymentStatisticsNotifier() : super(PaymentStatisticsState(payments: [], isLoading: false)) {
    loadPaymentStatistics();
  }

  // Load payment statistics from AWS
  Future<void> loadPaymentStatistics({int page = 1, int pageSize = 10}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // AWS에서 결제 데이터 로드 시도
      try {
        final request = GraphQLRequest<String>(
          document: '''query ListPayments(\$limit: Int, \$nextToken: String) {
            listPayments(limit: \$limit, nextToken: \$nextToken) {
              items {
                id
                userId
                productName
                amount
                paymentMethod
                status
                transactionId
                refundId
                createdAt
                updatedAt
              }
              nextToken
            }
          }''',
          variables: {
            'limit': pageSize,
          },
        );
        
        final response = await Amplify.API.query(request: request).response;
        
        if (response.data != null && response.errors.isEmpty) {
          // JSON 문자열을 파싱
          final jsonData = json.decode(response.data!);
          final items = jsonData['listPayments']['items'] as List?;
          
          if (items != null) {
            final payments = items
                .map((item) => Payment.fromJson(item as Map<String, dynamic>))
                .toList();
            
            // 날짜순으로 정렬 (최신순)
            payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            
            state = state.copyWith(
              payments: payments,
              isLoading: false,
              totalCount: payments.length,
              totalPages: (payments.length / pageSize).ceil(),
            );
          } else {
            // 데이터가 없으면 빈 리스트
            state = state.copyWith(
              payments: [],
              isLoading: false,
              totalCount: 0,
              totalPages: 1,
            );
          }
        } else {
          // 데이터가 없으면 빈 리스트
          state = state.copyWith(
            payments: [],
            isLoading: false,
            totalCount: 0,
            totalPages: 1,
          );
        }
      } catch (e) {
        // AWS 연결 실패 시 빈 리스트 표시
        // AWS 연결 실패 로깅 (프로덕션에서는 로깅 프레임워크 사용 권장)
        debugPrint('AWS 연결 실패, 빈 테이블 표시: $e');
        state = state.copyWith(
          payments: [],
          isLoading: false,
          totalCount: 0,
          totalPages: 1,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '결제 데이터를 불러오는 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadPaymentStatistics();
  }

  // Go to specific page
  Future<void> goToPage(int page) async {
    state = state.copyWith(currentPage: page);
    await loadPaymentStatistics(page: page);
  }

  // Previous page
  Future<void> previousPage() async {
    if (state.currentPage > 1) {
      await goToPage(state.currentPage - 1);
    }
  }

  // Next page
  Future<void> nextPage() async {
    if (state.currentPage < state.totalPages) {
      await goToPage(state.currentPage + 1);
    }
  }
}