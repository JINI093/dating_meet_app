import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUXUtils {
  static const String _loginHistoryKey = 'login_history';
  static const String _savedAccountsKey = 'saved_accounts';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _deviceInfoKey = 'device_info';
  static const String _securityAlertsKey = 'security_alerts';
  static const int _maxLoginHistory = 10;
  static const int _maxSavedAccounts = 5;

  // 자동 완성: 저장된 계정 목록
  static Future<List<SavedAccount>> getSavedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getStringList(_savedAccountsKey) ?? [];
    
    return accountsJson
        .map((json) => SavedAccount.fromJson(jsonDecode(json)))
        .toList();
  }

  // 계정 저장
  static Future<void> saveAccount(String username, String email, String loginType) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = await getSavedAccounts();
    
    // 기존 계정이 있으면 제거
    accounts.removeWhere((account) => 
        account.username == username || account.email == email);
    
    // 새 계정 추가
    final newAccount = SavedAccount(
      username: username,
      email: email,
      loginType: loginType,
      savedAt: DateTime.now(),
    );
    
    accounts.insert(0, newAccount);
    
    // 최대 개수 제한
    if (accounts.length > _maxSavedAccounts) {
      accounts.removeRange(_maxSavedAccounts, accounts.length);
    }
    
    // 저장
    final accountsJson = accounts
        .map((account) => jsonEncode(account.toJson()))
        .toList();
    
    await prefs.setStringList(_savedAccountsKey, accountsJson);
  }

  // 계정 삭제
  static Future<void> removeAccount(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = await getSavedAccounts();
    
    accounts.removeWhere((account) => account.username == username);
    
    final accountsJson = accounts
        .map((account) => jsonEncode(account.toJson()))
        .toList();
    
    await prefs.setStringList(_savedAccountsKey, accountsJson);
  }

  // 모든 저장된 계정 삭제
  static Future<void> clearSavedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedAccountsKey);
  }

  // 로그인 기록 관리
  static Future<List<LoginRecord>> getLoginHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_loginHistoryKey) ?? [];
    
    return historyJson
        .map((json) => LoginRecord.fromJson(jsonDecode(json)))
        .toList();
  }

  // 로그인 기록 추가
  static Future<void> addLoginRecord(String username, String loginType, bool success, [String? errorMessage]) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getLoginHistory();
    
    final newRecord = LoginRecord(
      username: username,
      loginType: loginType,
      timestamp: DateTime.now(),
      success: success,
      errorMessage: errorMessage,
      deviceInfo: await _getCurrentDeviceInfo(),
    );
    
    history.insert(0, newRecord);
    
    // 최대 개수 제한
    if (history.length > _maxLoginHistory) {
      history.removeRange(_maxLoginHistory, history.length);
    }
    
    final historyJson = history
        .map((record) => jsonEncode(record.toJson()))
        .toList();
    
    await prefs.setStringList(_loginHistoryKey, historyJson);
  }

  // 로그인 기록 삭제
  static Future<void> clearLoginHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginHistoryKey);
  }

  // 생체 인증 지원 확인
  static Future<BiometricSupport> checkBiometricSupport() async {
    final localAuth = LocalAuthentication();
    
    try {
      final isAvailable = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();
      
      if (!isAvailable || !isDeviceSupported) {
        return BiometricSupport(
          isSupported: false,
          availableBiometrics: [],
          message: '생체 인증을 지원하지 않는 기기입니다.',
        );
      }
      
      final availableBiometrics = await localAuth.getAvailableBiometrics();
      
      return BiometricSupport(
        isSupported: true,
        availableBiometrics: availableBiometrics,
        message: '생체 인증을 사용할 수 있습니다.',
      );
    } catch (e) {
      return BiometricSupport(
        isSupported: false,
        availableBiometrics: [],
        message: '생체 인증 확인 중 오류가 발생했습니다.',
      );
    }
  }

  // 생체 인증 활성화
  static Future<bool> enableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, true);
    return true;
  }

  // 생체 인증 비활성화
  static Future<bool> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, false);
    return true;
  }

  // 생체 인증 상태 확인
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  // 생체 인증으로 로그인
  static Future<BiometricAuthResult> authenticateWithBiometric() async {
    final localAuth = LocalAuthentication();
    
    try {
      final isAuthenticated = await localAuth.authenticate(
        localizedReason: '로그인을 위해 생체 인증을 사용합니다.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      return BiometricAuthResult(
        success: isAuthenticated,
        message: isAuthenticated ? '인증 성공' : '인증 실패',
      );
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        message: '생체 인증 중 오류가 발생했습니다: $e',
      );
    }
  }

  // 현재 기기 정보 가져오기
  static Future<DeviceInfo> _getCurrentDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return DeviceInfo(
          platform: 'Android',
          model: androidInfo.model,
          version: androidInfo.version.release,
          deviceId: androidInfo.id,
        );
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return DeviceInfo(
          platform: 'iOS',
          model: iosInfo.model,
          version: iosInfo.systemVersion,
          deviceId: iosInfo.identifierForVendor ?? '',
        );
      } else {
        return DeviceInfo(
          platform: 'Unknown',
          model: 'Unknown',
          version: 'Unknown',
          deviceId: 'Unknown',
        );
      }
    } catch (e) {
      return DeviceInfo(
        platform: 'Error',
        model: 'Error',
        version: 'Error',
        deviceId: 'Error',
      );
    }
  }

  // 다중 기기 로그인 감지
  static Future<MultiDeviceResult> checkMultiDeviceLogin(String username) async {
    final history = await getLoginHistory();
    final userHistory = history.where((record) => record.username == username).toList();
    
    if (userHistory.length < 2) {
      return MultiDeviceResult(
        isMultiDevice: false,
        devices: [],
        message: '단일 기기에서만 로그인했습니다.',
      );
    }
    
    final currentDevice = await _getCurrentDeviceInfo();
    final uniqueDevices = <DeviceInfo>[];
    
    for (final record in userHistory) {
      final device = record.deviceInfo;
      final isDuplicate = uniqueDevices.any((d) => 
          d.deviceId == device.deviceId && d.platform == device.platform);
      
      if (!isDuplicate) {
        uniqueDevices.add(device);
      }
    }
    
    final isMultiDevice = uniqueDevices.length > 1;
    
    return MultiDeviceResult(
      isMultiDevice: isMultiDevice,
      devices: uniqueDevices,
      message: isMultiDevice 
          ? '${uniqueDevices.length}개의 기기에서 로그인했습니다.'
          : '단일 기기에서만 로그인했습니다.',
    );
  }

  // 보안 알림 관리
  static Future<List<SecurityAlert>> getSecurityAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final alertsJson = prefs.getStringList(_securityAlertsKey) ?? [];
    
    return alertsJson
        .map((json) => SecurityAlert.fromJson(jsonDecode(json)))
        .toList();
  }

  // 보안 알림 추가
  static Future<void> addSecurityAlert(SecurityAlertType type, String message, [Map<String, dynamic>? details]) async {
    final prefs = await SharedPreferences.getInstance();
    final alerts = await getSecurityAlerts();
    
    final newAlert = SecurityAlert(
      type: type,
      message: message,
      timestamp: DateTime.now(),
      details: details ?? {},
      isRead: false,
    );
    
    alerts.insert(0, newAlert);
    
    // 최대 50개까지만 저장
    if (alerts.length > 50) {
      alerts.removeRange(50, alerts.length);
    }
    
    final alertsJson = alerts
        .map((alert) => jsonEncode(alert.toJson()))
        .toList();
    
    await prefs.setStringList(_securityAlertsKey, alertsJson);
  }

  // 알림 읽음 처리
  static Future<void> markAlertAsRead(String alertId) async {
    final prefs = await SharedPreferences.getInstance();
    final alerts = await getSecurityAlerts();
    
    final index = alerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      alerts[index] = alerts[index].copyWith(isRead: true);
      
      final alertsJson = alerts
          .map((alert) => jsonEncode(alert.toJson()))
          .toList();
      
      await prefs.setStringList(_securityAlertsKey, alertsJson);
    }
  }

  // 모든 알림 읽음 처리
  static Future<void> markAllAlertsAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final alerts = await getSecurityAlerts();
    
    final updatedAlerts = alerts.map((alert) => alert.copyWith(isRead: true)).toList();
    
    final alertsJson = updatedAlerts
        .map((alert) => jsonEncode(alert.toJson()))
        .toList();
    
    await prefs.setStringList(_securityAlertsKey, alertsJson);
  }

  // 읽지 않은 알림 개수
  static Future<int> getUnreadAlertCount() async {
    final alerts = await getSecurityAlerts();
    return alerts.where((alert) => !alert.isRead).length;
  }

  // 보안 알림 삭제
  static Future<void> clearSecurityAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_securityAlertsKey);
  }

  // 로그인 시도 통계
  static Future<LoginStatistics> getLoginStatistics() async {
    final history = await getLoginHistory();
    
    final totalAttempts = history.length;
    final successfulLogins = history.where((record) => record.success).length;
    final failedLogins = totalAttempts - successfulLogins;
    
    final loginTypes = <String, int>{};
    for (final record in history) {
      loginTypes[record.loginType] = (loginTypes[record.loginType] ?? 0) + 1;
    }
    
    final recentActivity = history
        .where((record) => 
            DateTime.now().difference(record.timestamp).inDays <= 7)
        .length;
    
    return LoginStatistics(
      totalAttempts: totalAttempts,
      successfulLogins: successfulLogins,
      failedLogins: failedLogins,
      successRate: totalAttempts > 0 ? (successfulLogins / totalAttempts) * 100 : 0,
      loginTypes: loginTypes,
      recentActivity: recentActivity,
    );
  }

  // 의심스러운 활동 감지
  static Future<List<SuspiciousActivity>> detectSuspiciousActivity() async {
    final history = await getLoginHistory();
    final suspiciousActivities = <SuspiciousActivity>[];
    
    // 최근 24시간 내 실패한 로그인 시도가 5회 이상
    final recentFailures = history
        .where((record) => 
            !record.success &&
            DateTime.now().difference(record.timestamp).inHours <= 24)
        .length;
    
    if (recentFailures >= 5) {
      suspiciousActivities.add(SuspiciousActivity(
        type: SuspiciousActivityType.multipleFailures,
        severity: SuspiciousActivitySeverity.high,
        message: '최근 24시간 내 로그인 실패가 $recentFailures회 발생했습니다.',
        timestamp: DateTime.now(),
      ));
    }
    
    // 새로운 기기에서의 로그인
    final currentDevice = await _getCurrentDeviceInfo();
    final knownDevices = <String>{};
    
    for (final record in history.where((record) => record.success)) {
      knownDevices.add(record.deviceInfo.deviceId);
    }
    
    if (!knownDevices.contains(currentDevice.deviceId)) {
      suspiciousActivities.add(SuspiciousActivity(
        type: SuspiciousActivityType.newDevice,
        severity: SuspiciousActivitySeverity.medium,
        message: '새로운 기기에서 로그인이 감지되었습니다.',
        timestamp: DateTime.now(),
      ));
    }
    
    // 비정상적인 시간대 로그인 (새벽 2-6시)
    final recentLogins = history
        .where((record) => 
            record.success &&
            DateTime.now().difference(record.timestamp).inHours <= 24)
        .toList();
    
    for (final record in recentLogins) {
      final hour = record.timestamp.hour;
      if (hour >= 2 && hour <= 6) {
        suspiciousActivities.add(SuspiciousActivity(
          type: SuspiciousActivityType.unusualTime,
          severity: SuspiciousActivitySeverity.low,
          message: '비정상적인 시간대에 로그인이 감지되었습니다.',
          timestamp: record.timestamp,
        ));
      }
    }
    
    return suspiciousActivities;
  }
}

// 저장된 계정 모델
class SavedAccount {
  final String username;
  final String email;
  final String loginType;
  final DateTime savedAt;

  SavedAccount({
    required this.username,
    required this.email,
    required this.loginType,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'loginType': loginType,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedAccount.fromJson(Map<String, dynamic> json) => SavedAccount(
    username: json['username'],
    email: json['email'],
    loginType: json['loginType'],
    savedAt: DateTime.parse(json['savedAt']),
  );
}

// 로그인 기록 모델
class LoginRecord {
  final String username;
  final String loginType;
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;
  final DeviceInfo deviceInfo;

  LoginRecord({
    required this.username,
    required this.loginType,
    required this.timestamp,
    required this.success,
    this.errorMessage,
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'loginType': loginType,
    'timestamp': timestamp.toIso8601String(),
    'success': success,
    'errorMessage': errorMessage,
    'deviceInfo': deviceInfo.toJson(),
  };

  factory LoginRecord.fromJson(Map<String, dynamic> json) => LoginRecord(
    username: json['username'],
    loginType: json['loginType'],
    timestamp: DateTime.parse(json['timestamp']),
    success: json['success'],
    errorMessage: json['errorMessage'],
    deviceInfo: DeviceInfo.fromJson(json['deviceInfo']),
  );
}

// 기기 정보 모델
class DeviceInfo {
  final String platform;
  final String model;
  final String version;
  final String deviceId;

  DeviceInfo({
    required this.platform,
    required this.model,
    required this.version,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'model': model,
    'version': version,
    'deviceId': deviceId,
  };

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
    platform: json['platform'],
    model: json['model'],
    version: json['version'],
    deviceId: json['deviceId'],
  );
}

// 생체 인증 지원 정보
class BiometricSupport {
  final bool isSupported;
  final List<BiometricType> availableBiometrics;
  final String message;

  BiometricSupport({
    required this.isSupported,
    required this.availableBiometrics,
    required this.message,
  });
}

// 생체 인증 결과
class BiometricAuthResult {
  final bool success;
  final String message;

  BiometricAuthResult({
    required this.success,
    required this.message,
  });
}

// 다중 기기 로그인 결과
class MultiDeviceResult {
  final bool isMultiDevice;
  final List<DeviceInfo> devices;
  final String message;

  MultiDeviceResult({
    required this.isMultiDevice,
    required this.devices,
    required this.message,
  });
}

// 보안 알림 모델
class SecurityAlert {
  final String id;
  final SecurityAlertType type;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> details;
  final bool isRead;

  SecurityAlert({
    String? id,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.details,
    required this.isRead,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  SecurityAlert copyWith({
    String? id,
    SecurityAlertType? type,
    String? message,
    DateTime? timestamp,
    Map<String, dynamic>? details,
    bool? isRead,
  }) {
    return SecurityAlert(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      details: details ?? this.details,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'details': details,
    'isRead': isRead,
  };

  factory SecurityAlert.fromJson(Map<String, dynamic> json) => SecurityAlert(
    id: json['id'],
    type: SecurityAlertType.values.firstWhere(
      (e) => e.toString() == json['type'],
      orElse: () => SecurityAlertType.unknown,
    ),
    message: json['message'],
    timestamp: DateTime.parse(json['timestamp']),
    details: Map<String, dynamic>.from(json['details']),
    isRead: json['isRead'],
  );
}

// 보안 알림 타입
enum SecurityAlertType {
  loginFailure,
  newDevice,
  unusualTime,
  multipleFailures,
  unknown,
}

// 로그인 통계
class LoginStatistics {
  final int totalAttempts;
  final int successfulLogins;
  final int failedLogins;
  final double successRate;
  final Map<String, int> loginTypes;
  final int recentActivity;

  LoginStatistics({
    required this.totalAttempts,
    required this.successfulLogins,
    required this.failedLogins,
    required this.successRate,
    required this.loginTypes,
    required this.recentActivity,
  });
}

// 의심스러운 활동
class SuspiciousActivity {
  final SuspiciousActivityType type;
  final SuspiciousActivitySeverity severity;
  final String message;
  final DateTime timestamp;

  SuspiciousActivity({
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
  });
}

// 의심스러운 활동 타입
enum SuspiciousActivityType {
  multipleFailures,
  newDevice,
  unusualTime,
}

// 의심스러운 활동 심각도
enum SuspiciousActivitySeverity {
  low,
  medium,
  high,
} 