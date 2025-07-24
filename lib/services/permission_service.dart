import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/logger.dart';

/// 권한 상태 클래스
class AppPermissionStatus {
  final bool notification;
  final bool location;
  final bool storage;
  final bool camera;
  final bool photos;
  final bool allRequested;

  AppPermissionStatus({
    required this.notification,
    required this.location,
    required this.storage,
    required this.camera,
    required this.photos,
    required this.allRequested,
  });

  bool get allGranted => notification && location && storage && camera && photos;
}

/// 앱 권한 관리 서비스
/// 최초 1회만 권한 요청하고, 이후에는 상태를 기억
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // SharedPreferences 키들
  static const String _keyPermissionsRequested = 'permissions_requested';
  static const String _keyNotificationPermission = 'notification_permission';
  static const String _keyLocationPermission = 'location_permission';
  static const String _keyStoragePermission = 'storage_permission';
  static const String _keyCameraPermission = 'camera_permission';
  static const String _keyPhotosPermission = 'photos_permission';

  /// 최초 실행 여부 확인 및 권한 요청
  Future<AppPermissionStatus> checkAndRequestPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final permissionsRequested = prefs.getBool(_keyPermissionsRequested) ?? false;

    if (!permissionsRequested) {
      // 최초 실행 - 모든 권한 요청
      Logger.log('최초 실행 - 권한 요청 시작', name: 'PermissionService');
      return await _requestAllPermissions();
    } else {
      // 기존 권한 상태 로드
      Logger.log('기존 권한 상태 로드', name: 'PermissionService');
      return await _loadStoredPermissions();
    }
  }

  /// 모든 권한 요청 (최초 실행 시)
  Future<AppPermissionStatus> _requestAllPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // 1. 알림 권한
      final notificationStatus = await _requestNotificationPermission();
      await prefs.setBool(_keyNotificationPermission, notificationStatus);
      Logger.log('알림 권한: $notificationStatus', name: 'PermissionService');

      // 2. 위치 권한
      final locationStatus = await _requestLocationPermission();
      await prefs.setBool(_keyLocationPermission, locationStatus);
      Logger.log('위치 권한: $locationStatus', name: 'PermissionService');

      // 3. 저장소 권한
      final storageStatus = await _requestStoragePermission();
      await prefs.setBool(_keyStoragePermission, storageStatus);
      Logger.log('저장소 권한: $storageStatus', name: 'PermissionService');

      // 4. 카메라 권한
      final cameraStatus = await _requestCameraPermission();
      await prefs.setBool(_keyCameraPermission, cameraStatus);
      Logger.log('카메라 권한: $cameraStatus', name: 'PermissionService');

      // 5. 사진 라이브러리 권한
      final photosStatus = await _requestPhotosPermission();
      await prefs.setBool(_keyPhotosPermission, photosStatus);
      Logger.log('사진 권한: $photosStatus', name: 'PermissionService');

      // 권한 요청 완료 플래그 설정
      await prefs.setBool(_keyPermissionsRequested, true);

      return AppPermissionStatus(
        notification: notificationStatus,
        location: locationStatus,
        storage: storageStatus,
        camera: cameraStatus,
        photos: photosStatus,
        allRequested: true,
      );
    } catch (e) {
      Logger.error('권한 요청 중 오류 발생: $e', name: 'PermissionService');
      
      // 오류 발생 시 기본값으로 저장
      return AppPermissionStatus(
        notification: false,
        location: false,
        storage: false,
        camera: false,
        photos: false,
        allRequested: false,
      );
    }
  }

  /// 저장된 권한 상태 로드
  Future<AppPermissionStatus> _loadStoredPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    
    return AppPermissionStatus(
      notification: prefs.getBool(_keyNotificationPermission) ?? false,
      location: prefs.getBool(_keyLocationPermission) ?? false,
      storage: prefs.getBool(_keyStoragePermission) ?? false,
      camera: prefs.getBool(_keyCameraPermission) ?? false,
      photos: prefs.getBool(_keyPhotosPermission) ?? false,
      allRequested: prefs.getBool(_keyPermissionsRequested) ?? false,
    );
  }

  /// 알림 권한 요청
  Future<bool> _requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      Logger.error('알림 권한 요청 실패: $e', name: 'PermissionService');
      return false;
    }
  }

  /// 위치 권한 요청
  Future<bool> _requestLocationPermission() async {
    try {
      // Geolocator를 사용한 위치 권한 요청
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      Logger.error('위치 권한 요청 실패: $e', name: 'PermissionService');
      return false;
    }
  }

  /// 저장소 권한 요청
  Future<bool> _requestStoragePermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.storage.request();
        return status == PermissionStatus.granted;
      } else {
        // iOS는 저장소 권한이 필요하지 않음
        return true;
      }
    } catch (e) {
      Logger.error('저장소 권한 요청 실패: $e', name: 'PermissionService');
      return false;
    }
  }

  /// 카메라 권한 요청
  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      Logger.error('카메라 권한 요청 실패: $e', name: 'PermissionService');
      return false;
    }
  }

  /// 사진 라이브러리 권한 요청
  Future<bool> _requestPhotosPermission() async {
    try {
      final status = await Permission.photos.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      Logger.error('사진 권한 요청 실패: $e', name: 'PermissionService');
      return false;
    }
  }

  /// 현재 권한 상태 확인 (실시간)
  Future<AppPermissionStatus> getCurrentPermissionStatus() async {
    try {
      final notificationStatus = await Permission.notification.status;
      final cameraStatus = await Permission.camera.status;
      final photosStatus = await Permission.photos.status;
      
      LocationPermission locationPermission = await Geolocator.checkPermission();
      bool locationGranted = locationPermission == LocationPermission.whileInUse || 
                            locationPermission == LocationPermission.always;

      bool storageGranted = true;
      if (defaultTargetPlatform == TargetPlatform.android) {
        final storageStatus = await Permission.storage.status;
        storageGranted = storageStatus == PermissionStatus.granted;
      }

      final prefs = await SharedPreferences.getInstance();
      
      return AppPermissionStatus(
        notification: notificationStatus == PermissionStatus.granted,
        location: locationGranted,
        storage: storageGranted,
        camera: cameraStatus == PermissionStatus.granted,
        photos: photosStatus == PermissionStatus.granted,
        allRequested: prefs.getBool(_keyPermissionsRequested) ?? false,
      );
    } catch (e) {
      Logger.error('권한 상태 확인 실패: $e', name: 'PermissionService');
      return await _loadStoredPermissions();
    }
  }

  /// 설정으로 이동
  Future<void> openSettings() async {
    try {
      await openAppSettings();
      Logger.log('앱 설정 열기', name: 'PermissionService');
    } catch (e) {
      Logger.error('앱 설정 열기 실패: $e', name: 'PermissionService');
    }
  }

  /// 권한 요청 상태 초기화 (개발/테스트용)
  Future<void> resetPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPermissionsRequested);
    await prefs.remove(_keyNotificationPermission);
    await prefs.remove(_keyLocationPermission);
    await prefs.remove(_keyStoragePermission);
    await prefs.remove(_keyCameraPermission);
    await prefs.remove(_keyPhotosPermission);
    
    Logger.log('권한 상태 초기화 완료', name: 'PermissionService');
  }
}