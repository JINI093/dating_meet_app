import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notice_model.dart';
import '../services/admin_notice_service.dart';
import '../services/admin_notice_service_amplify.dart';

/// 공지사항 상태
class AdminNoticeState {
  final List<NoticeModel> notices;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final NoticeTargetType? selectedTargetType;
  final NoticeStatus? selectedStatus;
  final String searchQuery;
  final String? sortField;
  final bool sortAscending;

  AdminNoticeState({
    this.notices = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.pageSize = 20,
    this.totalCount = 0,
    this.totalPages = 0,
    this.selectedTargetType,
    this.selectedStatus,
    this.searchQuery = '',
    this.sortField,
    this.sortAscending = false, // 최신순이 기본
  });

  AdminNoticeState copyWith({
    List<NoticeModel>? notices,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? pageSize,
    int? totalCount,
    int? totalPages,
    NoticeTargetType? selectedTargetType,
    NoticeStatus? selectedStatus,
    String? searchQuery,
    String? sortField,
    bool? sortAscending,
  }) {
    return AdminNoticeState(
      notices: notices ?? this.notices,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      selectedTargetType: selectedTargetType ?? this.selectedTargetType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

/// 공지사항 노티파이어
class AdminNoticeNotifier extends StateNotifier<AdminNoticeState> {
  final dynamic _service; // AdminNoticeService 또는 AdminNoticeServiceAmplify

  AdminNoticeNotifier(this._service) : super(AdminNoticeState()) {
    loadNotices();
  }

  /// 공지사항 목록 로드
  Future<void> loadNotices() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _service.getNotices(
        page: state.currentPage,
        pageSize: state.pageSize,
        targetType: state.selectedTargetType,
        status: state.selectedStatus,
        searchQuery: state.searchQuery,
        sortField: state.sortField,
        sortAscending: state.sortAscending,
      );

      state = state.copyWith(
        notices: result['notices'],
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

  /// 대상 타입별 필터링
  Future<void> filterByTargetType(NoticeTargetType? targetType) async {
    state = state.copyWith(
      selectedTargetType: targetType,
      currentPage: 1,
    );
    await loadNotices();
  }

  /// 상태별 필터링
  Future<void> filterByStatus(NoticeStatus? status) async {
    state = state.copyWith(
      selectedStatus: status,
      currentPage: 1,
    );
    await loadNotices();
  }

  /// 검색
  Future<void> search(String query) async {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1,
    );
    await loadNotices();
  }

  /// 정렬
  Future<void> sort(String? field, bool ascending) async {
    state = state.copyWith(
      sortField: field,
      sortAscending: ascending,
      currentPage: 1,
    );
    await loadNotices();
  }

  /// 페이지 이동
  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    
    state = state.copyWith(currentPage: page);
    await loadNotices();
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
    await loadNotices();
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadNotices();
  }

  /// 공지사항 생성
  Future<NoticeModel> createNotice(NoticeCreateUpdateDto dto) async {
    try {
      final notice = await _service.createNotice(dto);
      await refresh(); // 목록 새로고침
      return notice;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 공지사항 수정
  Future<NoticeModel> updateNotice(String noticeId, NoticeCreateUpdateDto dto) async {
    try {
      final notice = await _service.updateNotice(noticeId, dto);
      await refresh(); // 목록 새로고침
      return notice;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 공지사항 삭제
  Future<void> deleteNotice(String noticeId) async {
    try {
      await _service.deleteNotice(noticeId);
      await refresh(); // 목록 새로고침
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 공지사항 상태 변경
  Future<void> updateNoticeStatus(String noticeId, NoticeStatus status) async {
    try {
      await _service.updateNoticeStatus(noticeId, status);
      await refresh(); // 목록 새로고침
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 공지사항 상세 조회
  Future<NoticeModel> getNotice(String noticeId) async {
    try {
      return await _service.getNotice(noticeId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

/// 공지사항 서비스 프로바이더 (실제 AWS Amplify 사용)
final adminNoticeServiceProvider = Provider<AdminNoticeServiceAmplify>((ref) {
  return AdminNoticeServiceAmplify();
});

/// Amplify 초기화 상태 프로바이더
final amplifyInitializationProvider = StateProvider<bool?>((ref) => null);

/// 백업용 시뮬레이션 서비스 프로바이더
final adminNoticeServiceSimulationProvider = Provider<AdminNoticeService>((ref) {
  return AdminNoticeService();
});

/// 전체 공지사항 프로바이더
final adminNoticeProvider = StateNotifierProvider<AdminNoticeNotifier, AdminNoticeState>((ref) {
  final service = ref.watch(adminNoticeServiceProvider);
  return AdminNoticeNotifier(service);
});

/// 남성회원 공지사항 프로바이더
final adminMaleNoticeProvider = StateNotifierProvider<AdminNoticeNotifier, AdminNoticeState>((ref) {
  final service = ref.watch(adminNoticeServiceProvider);
  final notifier = AdminNoticeNotifier(service);
  // 남성회원 대상으로 필터링
  Future.delayed(Duration.zero, () {
    notifier.filterByTargetType(NoticeTargetType.male);
  });
  return notifier;
});

/// 여성회원 공지사항 프로바이더
final adminFemaleNoticeProvider = StateNotifierProvider<AdminNoticeNotifier, AdminNoticeState>((ref) {
  final service = ref.watch(adminNoticeServiceProvider);
  final notifier = AdminNoticeNotifier(service);
  // 여성회원 대상으로 필터링
  Future.delayed(Duration.zero, () {
    notifier.filterByTargetType(NoticeTargetType.female);
  });
  return notifier;
});

/// 특정 공지사항 상세 프로바이더
final noticeDetailProvider = FutureProvider.family<NoticeModel, String>((ref, noticeId) async {
  final service = ref.watch(adminNoticeServiceProvider);
  return service.getNotice(noticeId);
});