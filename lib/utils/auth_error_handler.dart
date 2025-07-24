import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthErrorHandler {
  static const int _maxRetryAttempts = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  
  // AWS Cognito 에러 코드별 사용자 친화적 메시지
  static const Map<String, String> _cognitoErrorMessages = {
    // 인증 관련 에러
    'NotAuthorizedException': '아이디 또는 비밀번호가 올바르지 않습니다.',
    'UserNotFoundException': '등록되지 않은 사용자입니다.',
    'UserNotConfirmedException': '이메일 인증이 필요합니다. 이메일을 확인해주세요.',
    'PasswordResetRequiredException': '비밀번호 재설정이 필요합니다.',
    'UserLambdaValidationException': '사용자 정보 검증에 실패했습니다.',
    
    // 회원가입 관련 에러
    'UsernameExistsException': '이미 사용 중인 아이디입니다.',
    'InvalidPasswordException': '비밀번호가 정책에 맞지 않습니다.',
    'CodeMismatchException': '인증 코드가 올바르지 않습니다.',
    'ExpiredCodeException': '인증 코드가 만료되었습니다. 새로운 코드를 요청해주세요.',
    'LimitExceededException': '요청 횟수가 초과되었습니다. 잠시 후 다시 시도해주세요.',
    
    // 소셜 로그인 관련 에러
    'ResourceNotFoundException': '소셜 로그인 설정을 찾을 수 없습니다.',
    'InvalidParameterException': '잘못된 로그인 정보입니다.',
    'TooManyRequestsException': '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.',
    
    // 네트워크 관련 에러
    'NetworkError': '네트워크 연결을 확인해주세요.',
    'TimeoutException': '요청 시간이 초과되었습니다.',
    'ServiceUnavailableException': '서비스가 일시적으로 사용할 수 없습니다.',
  };

  // 소셜 로그인 에러 메시지
  static const Map<String, String> _socialLoginErrorMessages = {
    'CANCELLED': '로그인이 취소되었습니다.',
    'NETWORK_ERROR': '네트워크 연결을 확인해주세요.',
    'INVALID_CREDENTIALS': '잘못된 인증 정보입니다.',
    'ACCOUNT_DISABLED': '비활성화된 계정입니다.',
    'SIGN_IN_REQUIRED': '다시 로그인해주세요.',
    'DEVELOPER_ERROR': '앱 설정에 문제가 있습니다.',
    'INVALID_ACCOUNT': '유효하지 않은 계정입니다.',
    'SIGN_IN_CANCELLED': '로그인이 취소되었습니다.',
    'SIGN_IN_FAILED': '로그인에 실패했습니다.',
  };

  // 전화번호 인증 에러 메시지
  static const Map<String, String> _phoneAuthErrorMessages = {
    'invalid-phone-number': '올바른 전화번호 형식이 아닙니다.',
    'invalid-verification-code': '인증 코드가 올바르지 않습니다.',
    'invalid-verification-id': '인증 정보가 유효하지 않습니다.',
    'quota-exceeded': 'SMS 발송 한도를 초과했습니다. 잠시 후 다시 시도해주세요.',
    'sms-retry-limit-exceeded': 'SMS 재전송 횟수를 초과했습니다.',
    'session-expired': '인증 세션이 만료되었습니다. 다시 시도해주세요.',
    'too-many-requests': '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.',
  };

  // 에러 타입별 분류
  static AuthErrorType classifyError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return AuthErrorType.network;
    } else if (errorString.contains('timeout')) {
      return AuthErrorType.timeout;
    } else if (errorString.contains('cancelled') || errorString.contains('canceled')) {
      return AuthErrorType.cancelled;
    } else if (errorString.contains('invalid') || errorString.contains('wrong')) {
      return AuthErrorType.invalidInput;
    } else if (errorString.contains('quota') || errorString.contains('limit')) {
      return AuthErrorType.quotaExceeded;
    } else {
      return AuthErrorType.unknown;
    }
  }

  // AWS Cognito 에러 메시지 변환
  static String getCognitoErrorMessage(String errorCode, [String? defaultMessage]) {
    return _cognitoErrorMessages[errorCode] ?? 
           defaultMessage ?? 
           '알 수 없는 오류가 발생했습니다. (코드: $errorCode)';
  }

  // 소셜 로그인 에러 메시지 변환
  static String getSocialLoginErrorMessage(String errorCode, [String? defaultMessage]) {
    return _socialLoginErrorMessages[errorCode] ?? 
           defaultMessage ?? 
           '소셜 로그인 중 오류가 발생했습니다.';
  }

  // 전화번호 인증 에러 메시지 변환
  static String getPhoneAuthErrorMessage(String errorCode, [String? defaultMessage]) {
    return _phoneAuthErrorMessages[errorCode] ?? 
           defaultMessage ?? 
           '전화번호 인증 중 오류가 발생했습니다.';
  }

  // 일반 에러 메시지 변환
  static String getErrorMessage(dynamic error, [String? context]) {
    final errorString = error.toString();
    final errorType = classifyError(error);
    
    switch (errorType) {
      case AuthErrorType.network:
        return '네트워크 연결을 확인해주세요.';
      case AuthErrorType.timeout:
        return '요청 시간이 초과되었습니다. 다시 시도해주세요.';
      case AuthErrorType.cancelled:
        return context == 'login' ? '로그인이 취소되었습니다.' : '작업이 취소되었습니다.';
      case AuthErrorType.invalidInput:
        return '입력 정보를 확인해주세요.';
      case AuthErrorType.quotaExceeded:
        return '요청 횟수가 초과되었습니다. 잠시 후 다시 시도해주세요.';
      case AuthErrorType.unknown:
      default:
        return '알 수 없는 오류가 발생했습니다. 다시 시도해주세요.';
    }
  }

  // 네트워크 연결 상태 확인
  static Future<bool> isNetworkAvailable() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      return !connectivityResults.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  // 자동 재시도 로직
  static Future<T> retryOperation<T>({
    required Future<T> Function() operation,
    int maxAttempts = _maxRetryAttempts,
    Duration delay = _retryDelay,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      try {
        // 네트워크 상태 확인
        if (!await isNetworkAvailable()) {
          throw AuthException('네트워크 연결이 없습니다.', AuthErrorType.network);
        }
        
        return await operation();
      } catch (error) {
        attempts++;
        
        // 재시도 여부 결정
        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }
        
        // 마지막 시도가 아니면 대기 후 재시도
        if (attempts < maxAttempts) {
          await Future.delayed(delay * attempts); // 지수 백오프
        } else {
          rethrow;
        }
      }
    }
    
    throw AuthException('최대 재시도 횟수를 초과했습니다.', AuthErrorType.unknown);
  }

  // 오프라인 상태 처리
  static Future<void> handleOfflineState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_offline', true);
    await prefs.setString('offline_since', DateTime.now().toIso8601String());
  }

  // 온라인 상태 복구
  static Future<void> handleOnlineState() async {
    final prefs = await SharedPreferences.getInstance();
    final wasOffline = prefs.getBool('is_offline') ?? false;
    
    if (wasOffline) {
      await prefs.setBool('is_offline', false);
      await prefs.remove('offline_since');
      
      // 오프라인 중에 발생한 작업들을 동기화
      await _syncOfflineActions();
    }
  }

  // 오프라인 중 발생한 작업 동기화
  static Future<void> _syncOfflineActions() async {
    final prefs = await SharedPreferences.getInstance();
    final offlineActions = prefs.getStringList('offline_actions') ?? [];
    
    if (offlineActions.isNotEmpty) {
      // 오프라인 중 발생한 작업들을 처리
      for (final action in offlineActions) {
        try {
          // 각 작업을 서버에 동기화
          await _processOfflineAction(action);
        } catch (e) {
          // 동기화 실패 시 로그 기록
          print('Offline action sync failed: $action - $e');
        }
      }
      
      // 동기화 완료 후 오프라인 액션 목록 삭제
      await prefs.remove('offline_actions');
    }
  }

  // 오프라인 액션 처리
  static Future<void> _processOfflineAction(String action) async {
    // 실제 구현에서는 각 액션 타입에 따라 처리
    // 예: 로그인 시도, 데이터 업로드 등
  }

  // 오프라인 액션 저장
  static Future<void> saveOfflineAction(String action) async {
    final prefs = await SharedPreferences.getInstance();
    final offlineActions = prefs.getStringList('offline_actions') ?? [];
    offlineActions.add('${DateTime.now().toIso8601String()}:$action');
    await prefs.setStringList('offline_actions', offlineActions);
  }

  // 에러 로깅
  static Future<void> logError(dynamic error, String context) async {
    final prefs = await SharedPreferences.getInstance();
    final errorLogs = prefs.getStringList('error_logs') ?? [];
    
    final errorLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'context': context,
      'error': error.toString(),
      'type': classifyError(error).toString(),
    };
    
    errorLogs.add(errorLog.toString());
    
    // 최대 100개까지만 저장
    if (errorLogs.length > 100) {
      errorLogs.removeRange(0, errorLogs.length - 100);
    }
    
    await prefs.setStringList('error_logs', errorLogs);
  }

  // 에러 통계 가져오기
  static Future<Map<String, dynamic>> getErrorStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final errorLogs = prefs.getStringList('error_logs') ?? [];
    
    final errorTypes = <String, int>{};
    final contextStats = <String, int>{};
    
    for (final log in errorLogs) {
      // 간단한 파싱 (실제로는 JSON 사용 권장)
      if (log.contains('AuthErrorType.')) {
        final type = log.split('AuthErrorType.')[1].split('}')[0];
        errorTypes[type] = (errorTypes[type] ?? 0) + 1;
      }
      
      if (log.contains("'context': '")) {
        final context = log.split("'context': '")[1].split("'")[0];
        contextStats[context] = (contextStats[context] ?? 0) + 1;
      }
    }
    
    return {
      'totalErrors': errorLogs.length,
      'errorTypes': errorTypes,
      'contextStats': contextStats,
      'lastError': errorLogs.isNotEmpty ? errorLogs.last : null,
    };
  }

  // 에러 로그 삭제
  static Future<void> clearErrorLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('error_logs');
  }
}

// 에러 타입 열거형
enum AuthErrorType {
  network,
  timeout,
  cancelled,
  invalidInput,
  quotaExceeded,
  unknown,
}

// 커스텀 인증 예외 클래스
class AuthException implements Exception {
  final String message;
  final AuthErrorType type;
  final dynamic originalError;

  AuthException(this.message, this.type, [this.originalError]);

  @override
  String toString() => 'AuthException: $message (Type: $type)';
}

// 에러 처리 결과 클래스
class ErrorHandlingResult {
  final bool success;
  final String message;
  final AuthErrorType? errorType;
  final bool shouldRetry;
  final Duration? retryDelay;

  ErrorHandlingResult({
    required this.success,
    required this.message,
    this.errorType,
    this.shouldRetry = false,
    this.retryDelay,
  });

  factory ErrorHandlingResult.success() {
    return ErrorHandlingResult(
      success: true,
      message: '성공',
    );
  }

  factory ErrorHandlingResult.failure(
    String message, {
    AuthErrorType? errorType,
    bool shouldRetry = false,
    Duration? retryDelay,
  }) {
    return ErrorHandlingResult(
      success: false,
      message: message,
      errorType: errorType,
      shouldRetry: shouldRetry,
      retryDelay: retryDelay,
    );
  }
} 