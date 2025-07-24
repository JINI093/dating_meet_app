import 'package:geolocator/geolocator.dart';
import '../utils/logger.dart';

/// 위치 서비스
/// 사용자의 현재 위치를 가져오고 위치 관련 기능을 제공합니다.
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// 현재 위치 가져오기
  Future<Position> getCurrentLocation() async {
    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('위치 서비스가 비활성화되어 있습니다.');
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
      }

      // 현재 위치 가져오기
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      Logger.log('현재 위치: ${position.latitude}, ${position.longitude}', name: 'LocationService');
      return position;
    } catch (e) {
      Logger.error('위치 가져오기 실패', error: e, name: 'LocationService');
      rethrow;
    }
  }

  /// 두 위치 간의 거리 계산 (미터 단위)
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// 위치 권한 상태 확인
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// 위치 권한 요청
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// 위치 서비스 활성화 여부 확인
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// 앱 설정으로 이동
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// 위치 설정으로 이동
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}