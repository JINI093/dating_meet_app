import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/permission_service.dart';
import '../utils/logger.dart';

/// 권한 상태
class PermissionState {
  final AppPermissionStatus? permissions;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const PermissionState({
    this.permissions,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  PermissionState copyWith({
    AppPermissionStatus? permissions,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return PermissionState(
      permissions: permissions ?? this.permissions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// 권한 관리 Provider
class PermissionNotifier extends StateNotifier<PermissionState> {
  final PermissionService _permissionService = PermissionService();

  PermissionNotifier() : super(const PermissionState());

  /// 앱 시작 시 권한 초기화
  Future<void> initializePermissions() async {
    if (state.isInitialized) {
      Logger.log('권한이 이미 초기화됨', name: 'PermissionProvider');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      Logger.log('권한 초기화 시작', name: 'PermissionProvider');
      
      // 권한 확인 및 요청
      final permissions = await _permissionService.checkAndRequestPermissions();
      
      Logger.log('권한 초기화 완료: ${permissions.allGranted ? "모든 권한 허용됨" : "일부 권한 거부됨"}', 
        name: 'PermissionProvider');

      state = state.copyWith(
        permissions: permissions,
        isLoading: false,
        isInitialized: true,
      );

      // 권한 상태 로그
      _logPermissionStatus(permissions);

    } catch (e) {
      Logger.error('권한 초기화 실패: $e', name: 'PermissionProvider');
      state = state.copyWith(
        isLoading: false,
        error: '권한 초기화에 실패했습니다: ${e.toString()}',
        isInitialized: false,
      );
    }
  }

  /// 현재 권한 상태 새로고침
  Future<void> refreshPermissions() async {
    state = state.copyWith(isLoading: true);

    try {
      final permissions = await _permissionService.getCurrentPermissionStatus();
      
      state = state.copyWith(
        permissions: permissions,
        isLoading: false,
        error: null,
      );

      Logger.log('권한 상태 새로고침 완료', name: 'PermissionProvider');
      _logPermissionStatus(permissions);

    } catch (e) {
      Logger.error('권한 상태 새로고침 실패: $e', name: 'PermissionProvider');
      state = state.copyWith(
        isLoading: false,
        error: '권한 상태 확인에 실패했습니다: ${e.toString()}',
      );
    }
  }

  /// 앱 설정으로 이동
  Future<void> openAppSettings() async {
    try {
      await _permissionService.openSettings();
    } catch (e) {
      Logger.error('앱 설정 열기 실패: $e', name: 'PermissionProvider');
      state = state.copyWith(error: '설정을 열 수 없습니다: ${e.toString()}');
    }
  }

  /// 특정 권한이 허용되었는지 확인
  bool isPermissionGranted(String permissionType) {
    final permissions = state.permissions;
    if (permissions == null) return false;

    switch (permissionType.toLowerCase()) {
      case 'notification':
        return permissions.notification;
      case 'location':
        return permissions.location;
      case 'storage':
        return permissions.storage;
      case 'camera':
        return permissions.camera;
      case 'photos':
        return permissions.photos;
      default:
        return false;
    }
  }

  /// 모든 필수 권한이 허용되었는지 확인
  bool get areEssentialPermissionsGranted {
    final permissions = state.permissions;
    if (permissions == null) return false;
    
    // 카메라와 사진 권한은 프로필 사진 등록에 필수
    return permissions.camera && permissions.photos;
  }

  /// 권한 상태 로깅
  void _logPermissionStatus(AppPermissionStatus permissions) {
    Logger.log('=== 권한 상태 ===', name: 'PermissionProvider');
    Logger.log('알림: ${permissions.notification ? "허용" : "거부"}', name: 'PermissionProvider');
    Logger.log('위치: ${permissions.location ? "허용" : "거부"}', name: 'PermissionProvider');
    Logger.log('저장소: ${permissions.storage ? "허용" : "거부"}', name: 'PermissionProvider');
    Logger.log('카메라: ${permissions.camera ? "허용" : "거부"}', name: 'PermissionProvider');
    Logger.log('사진: ${permissions.photos ? "허용" : "거부"}', name: 'PermissionProvider');
    Logger.log('요청 완료: ${permissions.allRequested ? "예" : "아니오"}', name: 'PermissionProvider');
    Logger.log('===============', name: 'PermissionProvider');
  }

  /// 개발용: 권한 상태 초기화
  Future<void> resetPermissions() async {
    try {
      await _permissionService.resetPermissions();
      state = const PermissionState(); // 초기 상태로 리셋
      Logger.log('권한 상태 초기화 완료', name: 'PermissionProvider');
    } catch (e) {
      Logger.error('권한 초기화 실패: $e', name: 'PermissionProvider');
      state = state.copyWith(error: '권한 초기화에 실패했습니다: ${e.toString()}');
    }
  }
}

/// Provider 인스턴스
final permissionProvider = StateNotifierProvider<PermissionNotifier, PermissionState>(
  (ref) => PermissionNotifier(),
);