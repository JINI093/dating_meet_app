import '../../../models/auth_result.dart' as app_auth_result;

/// SMS 제공업체 인터페이스
abstract class SMSProvider {
  /// SMS 전송
  Future<app_auth_result.AuthResult> sendSMS({
    required String phoneNumber,
    required String message,
  });

  /// 서비스 초기화
  Future<void> initialize();

  /// 서비스 상태 확인
  Future<bool> isAvailable();

  /// 제공업체 이름
  String get providerName;
}

/// SMS 전송 결과
class SMSResult {
  final bool success;
  final String? messageId;
  final String? error;
  final Map<String, dynamic>? metadata;

  SMSResult({
    required this.success,
    this.messageId,
    this.error,
    this.metadata,
  });

  factory SMSResult.success({String? messageId, Map<String, dynamic>? metadata}) {
    return SMSResult(
      success: true,
      messageId: messageId,
      metadata: metadata,
    );
  }

  factory SMSResult.failure({required String error, Map<String, dynamic>? metadata}) {
    return SMSResult(
      success: false,
      error: error,
      metadata: metadata,
    );
  }
}