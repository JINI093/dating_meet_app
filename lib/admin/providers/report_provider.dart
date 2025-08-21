import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';
import '../services/admin_report_service_amplify.dart';

/// 신고 상태
class AdminReportState {
  final List<ReportModel> reports;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final ReportType? selectedReportType;
  final ReportStatus? selectedStatus;
  final ReportPriority? selectedPriority;
  final String searchQuery;
  final String? sortField;
  final bool sortAscending;

  AdminReportState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.pageSize = 20,
    this.totalCount = 0,
    this.totalPages = 0,
    this.selectedReportType,
    this.selectedStatus,
    this.selectedPriority,
    this.searchQuery = '',
    this.sortField,
    this.sortAscending = false, // 최신순이 기본
  });

  AdminReportState copyWith({
    List<ReportModel>? reports,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? pageSize,
    int? totalCount,
    int? totalPages,
    ReportType? selectedReportType,
    ReportStatus? selectedStatus,
    ReportPriority? selectedPriority,
    String? searchQuery,
    String? sortField,
    bool? sortAscending,
  }) {
    return AdminReportState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      selectedReportType: selectedReportType ?? this.selectedReportType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      searchQuery: searchQuery ?? this.searchQuery,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

/// 신고 노티파이어
class AdminReportNotifier extends StateNotifier<AdminReportState> {
  final AdminReportServiceAmplify _service;

  AdminReportNotifier(this._service) : super(AdminReportState()) {
    loadReports();
  }

  /// 신고 목록 로드
  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _service.getReports(
        page: state.currentPage,
        pageSize: state.pageSize,
        reportType: state.selectedReportType,
        status: state.selectedStatus,
        priority: state.selectedPriority,
        searchQuery: state.searchQuery,
        sortField: state.sortField,
        sortAscending: state.sortAscending,
      );

      state = state.copyWith(
        reports: result['reports'],
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

  /// 신고 유형별 필터링
  Future<void> filterByReportType(ReportType? reportType) async {
    state = state.copyWith(
      selectedReportType: reportType,
      currentPage: 1,
    );
    await loadReports();
  }

  /// 상태별 필터링
  Future<void> filterByStatus(ReportStatus? status) async {
    state = state.copyWith(
      selectedStatus: status,
      currentPage: 1,
    );
    await loadReports();
  }

  /// 우선순위별 필터링
  Future<void> filterByPriority(ReportPriority? priority) async {
    state = state.copyWith(
      selectedPriority: priority,
      currentPage: 1,
    );
    await loadReports();
  }

  /// 검색
  Future<void> search(String query) async {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1,
    );
    await loadReports();
  }

  /// 정렬
  Future<void> sort(String? field, bool ascending) async {
    state = state.copyWith(
      sortField: field,
      sortAscending: ascending,
      currentPage: 1,
    );
    await loadReports();
  }

  /// 페이지 이동
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    
    state = state.copyWith(currentPage: page);
    await loadReports();
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
    await loadReports();
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadReports();
  }

  /// 신고 처리
  Future<ReportModel> processReport(String reportId, ReportProcessDto dto) async {
    try {
      final report = await _service.processReport(reportId, dto);
      await refresh(); // 목록 새로고침
      return report;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 신고 상태 변경
  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    try {
      await _service.updateReportStatus(reportId, status);
      await refresh(); // 목록 새로고침
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 신고 상세 조회
  Future<ReportModel> getReport(String reportId) async {
    try {
      return await _service.getReport(reportId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

/// 신고 서비스 프로바이더
final adminReportServiceProvider = Provider<AdminReportServiceAmplify>((ref) {
  return AdminReportServiceAmplify();
});

/// 신고 관리 프로바이더
final adminReportProvider = StateNotifierProvider<AdminReportNotifier, AdminReportState>((ref) {
  final service = ref.watch(adminReportServiceProvider);
  return AdminReportNotifier(service);
});

/// 특정 신고 상세 프로바이더
final reportDetailProvider = FutureProvider.family<ReportModel, String>((ref, reportId) async {
  final service = ref.watch(adminReportServiceProvider);
  return service.getReport(reportId);
});

/// 신고 통계 프로바이더
final reportStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(adminReportServiceProvider);
  try {
    return await service.getReportStats();
  } catch (e) {
    // 실패 시 기본값 반환
    return {
      'total': 0,
      'pending': 0,
      'inProgress': 0,
      'resolved': 0,
      'rejected': 0,
      'urgent': 0,
    };
  }
});