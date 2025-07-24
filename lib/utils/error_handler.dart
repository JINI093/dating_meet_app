import 'logger.dart';

class ErrorHandler {
  static void handleError(dynamic error, {StackTrace? stackTrace}) {
    Logger.e('에러 발생: $error');
    if (stackTrace != null) {
      Logger.e(stackTrace.toString());
    }
    // AWS 에러 코드 매핑 예시
    if (error is Exception) {
      final code = _extractAwsErrorCode(error);
      if (code != null) {
        Logger.e('AWS 에러 코드: $code');
        // 코드별 사용자 메시지 처리 등
      }
    }
  }

  static String? _extractAwsErrorCode(Exception error) {
    final msg = error.toString();
    final match = RegExp(r'code: (\w+)').firstMatch(msg);
    return match?.group(1);
  }
} 