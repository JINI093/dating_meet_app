import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// 권한 관리자
/// 알림, 위치, 저장소, 카메라, 사진 권한을 확인하고 요청하는 기능 제공
class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  /// 모든 권한 확인 및 요청
  /// Returns: Map<Permission, PermissionStatus>
  Future<Map<Permission, PermissionStatus>>
      checkAndRequestAllPermissions() async {
    try {
      final permissions = [
        Permission.notification,
        Permission.location,
        Permission.storage,
        Permission.camera,
        Permission.photos,
      ];

      final results = <Permission, PermissionStatus>{};

      for (final permission in permissions) {
        final status = await _checkAndRequestPermission(permission);
        results[permission] = status;
      }

      return results;
    } catch (e) {
      // 오류 발생 시 모든 권한을 denied로 처리
      return {
        Permission.notification: PermissionStatus.denied,
        Permission.location: PermissionStatus.denied,
        Permission.storage: PermissionStatus.denied,
        Permission.camera: PermissionStatus.denied,
        Permission.photos: PermissionStatus.denied,
      };
    }
  }

  /// 특정 권한 확인 및 요청
  /// [permission]: 확인할 권한
  /// Returns: PermissionStatus
  Future<PermissionStatus> checkAndRequestPermission(
      Permission permission) async {
    try {
      return await _checkAndRequestPermission(permission);
    } catch (e) {
      return PermissionStatus.denied;
    }
  }

  /// 권한 상태만 확인 (요청하지 않음)
  /// [permission]: 확인할 권한
  /// Returns: PermissionStatus
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    try {
      return await permission.status;
    } catch (e) {
      return PermissionStatus.denied;
    }
  }

  /// 모든 권한 상태 확인 (요청하지 않음)
  /// Returns: Map<Permission, PermissionStatus>
  Future<Map<Permission, PermissionStatus>> checkAllPermissionStatuses() async {
    try {
      final permissions = [
        Permission.notification,
        Permission.location,
        Permission.storage,
        Permission.camera,
        Permission.photos,
      ];

      final results = <Permission, PermissionStatus>{};

      for (final permission in permissions) {
        final status = await permission.status;
        results[permission] = status;
      }

      return results;
    } catch (e) {
      return {
        Permission.notification: PermissionStatus.denied,
        Permission.location: PermissionStatus.denied,
        Permission.storage: PermissionStatus.denied,
        Permission.camera: PermissionStatus.denied,
        Permission.photos: PermissionStatus.denied,
      };
    }
  }

  /// 권한이 영구적으로 거부되었는지 확인
  /// [permission]: 확인할 권한
  /// Returns: bool
  Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    try {
      return await permission.isPermanentlyDenied;
    } catch (e) {
      return false;
    }
  }

  /// 앱 설정으로 이동
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      return false;
    }
  }

  /// 권한 상태를 한글로 변환
  String getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '허용됨';
      case PermissionStatus.denied:
        return '거부됨';
      case PermissionStatus.restricted:
        return '제한됨';
      case PermissionStatus.limited:
        return '제한적 허용';
      case PermissionStatus.permanentlyDenied:
        return '영구 거부';
      default:
        return '알 수 없음';
    }
  }

  /// 권한 이름을 한글로 변환
  String getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.notification:
        return '알림';
      case Permission.location:
        return '위치';
      case Permission.storage:
        return '저장소';
      case Permission.camera:
        return '카메라';
      case Permission.photos:
        return '사진';
      default:
        return '알 수 없음';
    }
  }

  /// 권한이 필요한 이유 설명
  String getPermissionReason(Permission permission) {
    switch (permission) {
      case Permission.notification:
        return '새로운 매치와 메시지를 받기 위해 필요합니다.';
      case Permission.location:
        return '주변 사용자를 찾기 위해 필요합니다.';
      case Permission.storage:
        return '프로필 이미지를 저장하기 위해 필요합니다.';
      case Permission.camera:
        return '프로필 사진을 촬영하기 위해 필요합니다.';
      case Permission.photos:
        return '갤러리에서 사진을 선택하기 위해 필요합니다.';
      default:
        return '앱 기능 사용을 위해 필요합니다.';
    }
  }

  /// 내부 권한 확인 및 요청 로직
  Future<PermissionStatus> _checkAndRequestPermission(Permission permission) async {
    try {
      // 현재 권한 상태 확인
      PermissionStatus status = await permission.status;

      // 이미 허용된 경우
      if (status.isGranted) {
        return status;
      }

      // 권한 요청
      if (status.isDenied) {
        status = await permission.request();
      }

      // 영구적으로 거부된 경우
      if (status.isPermanentlyDenied) {
        // 앱 설정으로 이동 안내는 별도로 처리
        return status;
      }

      return status;
    } catch (e) {
      return PermissionStatus.denied;
    }
  }
}

/// PermissionManager 프로바이더
final permissionManagerProvider = Provider<PermissionManager>((ref) {
  return PermissionManager();
});

/// 모든 권한 상태 프로바이더
final allPermissionsProvider =
    FutureProvider<Map<Permission, PermissionStatus>>((ref) async {
  final permissionManager = ref.read(permissionManagerProvider);
  return await permissionManager.checkAllPermissionStatuses();
});

/// 특정 권한 상태 프로바이더
final permissionStatusProvider =
    FutureProvider.family<PermissionStatus, Permission>(
        (ref, permission) async {
  final permissionManager = ref.read(permissionManagerProvider);
  return await permissionManager.checkPermissionStatus(permission);
});
