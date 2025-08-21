import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';
import '../services/admin_payment_service_amplify.dart';

/// 결제 상태
class AdminPaymentState {
  final List<PaymentModel> payments;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final PaymentStatus? selectedStatus;
  final PaymentMethod? selectedPaymentMethod;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sortField;
  final bool sortAscending;

  AdminPaymentState({
    this.payments = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.pageSize = 20,
    this.totalCount = 0,
    this.totalPages = 0,
    this.selectedStatus,
    this.selectedPaymentMethod,
    this.searchQuery = '',
    this.startDate,
    this.endDate,
    this.sortField,
    this.sortAscending = false, // 최신순이 기본
  });

  AdminPaymentState copyWith({
    List<PaymentModel>? payments,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? pageSize,
    int? totalCount,
    int? totalPages,
    PaymentStatus? selectedStatus,
    PaymentMethod? selectedPaymentMethod,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    String? sortField,
    bool? sortAscending,
  }) {
    return AdminPaymentState(
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

/// 결제 노티파이어
class AdminPaymentNotifier extends StateNotifier<AdminPaymentState> {
  final AdminPaymentServiceAmplify _service;

  AdminPaymentNotifier(this._service) : super(AdminPaymentState()) {
    loadPayments();
  }

  /// 결제 목록 로드
  Future<void> loadPayments() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _service.getPayments(
        page: state.currentPage,
        pageSize: state.pageSize,
        status: state.selectedStatus,
        paymentMethod: state.selectedPaymentMethod,
        searchQuery: state.searchQuery,
        startDate: state.startDate,
        endDate: state.endDate,
        sortField: state.sortField,
        sortAscending: state.sortAscending,
      );

      state = state.copyWith(
        payments: result['payments'],
        totalCount: result['totalCount'],
        totalPages: result['totalPages'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 상태별 필터링
  Future<void> filterByStatus(PaymentStatus? status) async {
    state = state.copyWith(
      selectedStatus: status,
      currentPage: 1,
    );
    await loadPayments();
  }

  /// 결제 방법별 필터링
  Future<void> filterByPaymentMethod(PaymentMethod? paymentMethod) async {
    state = state.copyWith(
      selectedPaymentMethod: paymentMethod,
      currentPage: 1,
    );
    await loadPayments();
  }

  /// 검색
  Future<void> search(String query) async {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1,
    );
    await loadPayments();
  }

  /// 날짜 범위 필터링
  Future<void> filterByDateRange(DateTime? startDate, DateTime? endDate) async {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      currentPage: 1,
    );
    await loadPayments();
  }

  /// 정렬
  Future<void> sort(String? field, bool ascending) async {
    state = state.copyWith(
      sortField: field,
      sortAscending: ascending,
      currentPage: 1,
    );
    await loadPayments();
  }

  /// 페이지 이동
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    
    state = state.copyWith(currentPage: page);
    await loadPayments();
  }

  /// 이전 페이지
  Future<void> previousPage() async {
    if (state.currentPage > 1) {
      await goToPage(state.currentPage - 1);
    }
  }

  /// 다음 페이지
  Future<void> nextPage() async {
    if (state.currentPage < state.totalPages) {
      await goToPage(state.currentPage + 1);
    }
  }

  /// 페이지 크기 변경
  Future<void> setPageSize(int size) async {
    state = state.copyWith(
      pageSize: size,
      currentPage: 1,
    );
    await loadPayments();
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadPayments();
  }

  /// 환불 처리
  Future<PaymentModel> processRefund(String paymentId, RefundProcessDto dto) async {
    try {
      final payment = await _service.processRefund(paymentId, dto);
      await refresh(); // 목록 새로고침
      return payment;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 결제 상태 변경
  Future<void> updatePaymentStatus(String paymentId, PaymentStatus status) async {
    try {
      await _service.updatePaymentStatus(paymentId, status);
      await refresh(); // 목록 새로고침
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 결제 상세 조회
  Future<PaymentModel> getPayment(String paymentId) async {
    try {
      return await _service.getPayment(paymentId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

/// 결제 서비스 프로바이더
final adminPaymentServiceProvider = Provider<AdminPaymentServiceAmplify>((ref) {
  return AdminPaymentServiceAmplify();
});

/// 결제 관리 프로바이더
final adminPaymentProvider = StateNotifierProvider<AdminPaymentNotifier, AdminPaymentState>((ref) {
  final service = ref.watch(adminPaymentServiceProvider);
  return AdminPaymentNotifier(service);
});

/// 특정 결제 상세 프로바이더
final paymentDetailProvider = FutureProvider.family<PaymentModel, String>((ref, paymentId) async {
  final service = ref.watch(adminPaymentServiceProvider);
  return service.getPayment(paymentId);
});

/// 결제 통계 프로바이더
final paymentStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(adminPaymentServiceProvider);
  try {
    return await service.getPaymentStats();
  } catch (e) {
    // 실패 시 기본값 반환
    return {
      'todayAmount': 0,
      'todayCount': 0,
      'weekAmount': 0,
      'weekCount': 0,
      'monthAmount': 0,
      'monthCount': 0,
      'failedCount': 0,
      'failureRate': 0.0,
    };
  }
});