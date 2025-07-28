import 'package:flutter_dotenv/flutter_dotenv.dart';

class AWSConfig {
  // AWS 기본 정보
  static String get accountId => '213265226405';
  static String get region => dotenv.env['AWS_REGION'] ?? 'ap-northeast-2';
  static String get accessKeyId => dotenv.env['AWS_ACCESS_KEY_ID'] ?? '';
  static String get secretAccessKey => dotenv.env['AWS_SECRET_ACCESS_KEY'] ?? '';

  // Cognito 설정
  static String get userPoolId => 'ap-northeast-2_lKdTmyEaP';
  static String get userPoolClientId => dotenv.env['COGNITO_USER_POOL_CLIENT_ID'] ?? '';
  static String get identityPoolId => dotenv.env['COGNITO_IDENTITY_POOL_ID'] ?? '';

  // S3 설정
  static String get s3BucketName => 'meet-project';
  static String get s3BucketRegion => 'ap-northeast-2';

  // API Gateway 설정
  static String get apiGatewayUrl => dotenv.env['API_GATEWAY_URL'] ?? 'https://ek5h8mq0mf.execute-api.ap-northeast-2.amazonaws.com/prod';
  static String get apiGatewayStage => dotenv.env['API_GATEWAY_STAGE'] ?? 'prod';

  /// 환경 변수 로딩 (main 함수에서 호출 필요)
  static Future<void> load() async {
    await dotenv.load();
  }

  /// 필수 환경 변수 검증
  static void validate() {
    final requiredKeys = [
      'AWS_ACCESS_KEY_ID',
      'AWS_SECRET_ACCESS_KEY',
      'COGNITO_USER_POOL_CLIENT_ID',
      'COGNITO_IDENTITY_POOL_ID',
      'API_GATEWAY_URL',
    ];
    final missing = requiredKeys.where((k) => (dotenv.env[k] ?? '').isEmpty).toList();
    if (missing.isNotEmpty) {
      // 개발 환경에서는 로그만 출력하고 앱을 계속 실행
      print('⚠️  필수 환경 변수 누락: ${missing.join(', ')}');
      print('📝 개발 환경에서는 기본값으로 진행됩니다.');
    }
  }
} 