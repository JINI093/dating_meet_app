import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_user.dart';
import '../services/admin_auth_service.dart';

/// 관리자 인증 상태
class AdminAuthState {
  final AdminUser? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? token;

  AdminAuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.token,
  });

  AdminAuthState copyWith({
    AdminUser? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? token,
  }) {
    return AdminAuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      token: token ?? this.token,
    );
  }
}

/// 관리자 인증 프로바이더
class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  final AdminAuthService _authService;
  final Ref ref;

  AdminAuthNotifier(this._authService, this.ref) : super(AdminAuthState()) {
    _checkAuthStatus();
  }

  /// 초기 인증 상태 확인 (로그인 불필요)
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // 임시로 기본 관리자 사용자 생성 (로그인 불필요)
      final defaultAdmin = AdminUser(
        id: 'admin_1',
        username: 'admin',
        email: 'admin@example.com',
        name: '관리자',
        role: AdminRole.superAdmin,
        isActive: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      state = state.copyWith(
        user: defaultAdmin,
        token: 'temp_admin_token',
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 로그인
  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.login(username, password);
      
      if (result != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_token', result['token']);
        
        state = state.copyWith(
          user: result['user'],
          token: result['token'],
          isAuthenticated: true,
          isLoading: false,
        );
        
        return true;
      }
      
      state = state.copyWith(
        isLoading: false,
        error: '로그인에 실패했습니다.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
    
    state = AdminAuthState();
  }

  /// 토큰 갱신
  Future<void> refreshToken() async {
    if (state.token == null) return;
    
    try {
      final newToken = await _authService.refreshToken(state.token!);
      if (newToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_token', newToken);
        
        state = state.copyWith(token: newToken);
      }
    } catch (e) {
      // 토큰 갱신 실패시 로그아웃
      await logout();
    }
  }

  /// 권한 확인
  bool hasPermission(String menu, {bool requireEdit = false}) {
    if (state.user == null) return false;
    
    final role = state.user!.role;
    
    // 메뉴 접근 권한 확인
    if (!role.accessibleMenus.contains(menu)) return false;
    
    // 편집 권한 확인
    if (requireEdit && !role.canEdit(menu)) return false;
    
    return true;
  }

  /// 특정 권한 확인
  bool hasRole(AdminRole requiredRole) {
    if (state.user == null) return false;
    
    final userRole = state.user!.role;
    
    // 최고 관리자는 모든 권한 가짐
    if (userRole == AdminRole.superAdmin) return true;
    
    return userRole == requiredRole;
  }
}

/// 관리자 인증 프로바이더
final adminAuthProvider = StateNotifierProvider<AdminAuthNotifier, AdminAuthState>((ref) {
  final authService = AdminAuthService();
  return AdminAuthNotifier(authService, ref);
});

/// 현재 관리자 사용자
final currentAdminUserProvider = Provider<AdminUser?>((ref) {
  return ref.watch(adminAuthProvider).user;
});

/// 관리자 인증 상태
final isAdminAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(adminAuthProvider).isAuthenticated;
});

/// 권한 확인 프로바이더
final hasAdminPermissionProvider = Provider.family<bool, String>((ref, menu) {
  final notifier = ref.read(adminAuthProvider.notifier);
  return notifier.hasPermission(menu);
});

/// 편집 권한 확인 프로바이더
final hasAdminEditPermissionProvider = Provider.family<bool, String>((ref, menu) {
  final notifier = ref.read(adminAuthProvider.notifier);
  return notifier.hasPermission(menu, requireEdit: true);
});