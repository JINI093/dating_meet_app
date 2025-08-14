import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/admin_users_service.dart';

/// 관리자 회원 관리 상태
class AdminUsersState {
  final List<UserModel> users;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final Set<String> selectedUsers;
  final String searchQuery;
  final Map<String, dynamic> filters;
  final int? sortColumnIndex;
  final bool sortAscending;
  final String? sortField;

  AdminUsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.pageSize = 20,
    this.totalCount = 0,
    this.selectedUsers = const {},
    this.searchQuery = '',
    this.filters = const {},
    this.sortColumnIndex,
    this.sortAscending = true,
    this.sortField,
  });

  AdminUsersState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? pageSize,
    int? totalCount,
    Set<String>? selectedUsers,
    String? searchQuery,
    Map<String, dynamic>? filters,
    int? sortColumnIndex,
    bool? sortAscending,
    String? sortField,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      sortColumnIndex: sortColumnIndex ?? this.sortColumnIndex,
      sortAscending: sortAscending ?? this.sortAscending,
      sortField: sortField ?? this.sortField,
    );
  }
}

/// 관리자 회원 관리 노티파이어
class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  final AdminUsersService _service;

  AdminUsersNotifier(this._service) : super(AdminUsersState()) {
    loadUsers();
  }

  /// 회원 목록 로드
  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _service.getUsers(
        page: state.currentPage,
        pageSize: state.pageSize,
        searchQuery: state.searchQuery,
        filters: state.filters,
        sortField: state.sortField,
        sortAscending: state.sortAscending,
      );

      state = state.copyWith(
        users: result['users'],
        totalCount: result['totalCount'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 검색
  Future<void> search(String query) async {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1, // 검색 시 첫 페이지로
      selectedUsers: {}, // 선택 초기화
    );
    await loadUsers();
  }

  /// 필터 적용
  Future<void> applyFilters(Map<String, dynamic> filters) async {
    state = state.copyWith(
      filters: filters,
      currentPage: 1, // 필터 적용 시 첫 페이지로
      selectedUsers: {}, // 선택 초기화
    );
    await loadUsers();
  }

  /// 정렬
  Future<void> sort(int columnIndex, bool ascending, String field) async {
    state = state.copyWith(
      sortColumnIndex: columnIndex,
      sortAscending: ascending,
      sortField: field,
      selectedUsers: {}, // 선택 초기화
    );
    await loadUsers();
  }

  /// 페이지 이동
  Future<void> goToPage(int page) async {
    if (page < 1) return;
    
    state = state.copyWith(
      currentPage: page,
      selectedUsers: {}, // 선택 초기화
    );
    await loadUsers();
  }

  /// 이전 페이지
  Future<void> previousPage() async {
    if (state.currentPage > 1) {
      await goToPage(state.currentPage - 1);
    }
  }

  /// 다음 페이지
  Future<void> nextPage() async {
    final totalPages = (state.totalCount / state.pageSize).ceil();
    if (state.currentPage < totalPages) {
      await goToPage(state.currentPage + 1);
    }
  }

  /// 페이지 크기 변경
  Future<void> setPageSize(int pageSize) async {
    state = state.copyWith(
      pageSize: pageSize,
      currentPage: 1, // 페이지 크기 변경 시 첫 페이지로
      selectedUsers: {}, // 선택 초기화
    );
    await loadUsers();
  }

  /// 사용자 선택 토글
  void toggleSelectUser(String userId) {
    final selectedUsers = Set<String>.from(state.selectedUsers);
    
    if (selectedUsers.contains(userId)) {
      selectedUsers.remove(userId);
    } else {
      selectedUsers.add(userId);
    }
    
    state = state.copyWith(selectedUsers: selectedUsers);
  }

  /// 전체 선택 토글
  void toggleSelectAll(bool selectAll) {
    if (selectAll) {
      final allUserIds = state.users.map((user) => user.id).toSet();
      state = state.copyWith(selectedUsers: allUserIds);
    } else {
      state = state.copyWith(selectedUsers: {});
    }
  }

  /// 회원 상태 변경
  Future<void> updateUserStatus(String userId, UserStatus status) async {
    try {
      await _service.updateUserStatus(userId, status);
      await loadUsers(); // 목록 새로고침
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// VIP 상태 변경
  Future<void> updateVipStatus(String userId, bool isVip) async {
    try {
      await _service.updateVipStatus(userId, isVip);
      await loadUsers(); // 목록 새로고침
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 일괄 작업
  Future<void> bulkAction(String action, List<String> userIds) async {
    try {
      await _service.bulkAction(action, userIds);
      await loadUsers(); // 목록 새로고침
      state = state.copyWith(selectedUsers: {}); // 선택 초기화
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadUsers();
  }
}

/// 관리자 회원 관리 프로바이더
final adminUsersProvider = StateNotifierProvider<AdminUsersNotifier, AdminUsersState>((ref) {
  final service = AdminUsersService();
  return AdminUsersNotifier(service);
});