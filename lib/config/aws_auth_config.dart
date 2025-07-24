import 'package:flutter_dotenv/flutter_dotenv.dart';

class AWSAuthConfig {
  // 기존 Cognito 설정
  static String get userPoolId => 'ap-northeast-2_lKdTmyEaP';
  static String get userPoolClientId => dotenv.env['COGNITO_USER_POOL_CLIENT_ID'] ?? '';
  static String get identityPoolId => dotenv.env['COGNITO_IDENTITY_POOL_ID'] ?? '';

  // 소셜 로그인 Identity Provider 설정
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  static String get kakaoNativeAppKey => dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';
  static String get naverClientId => dotenv.env['NAVER_CLIENT_ID'] ?? '';
  static String get naverClientSecret => dotenv.env['NAVER_CLIENT_SECRET'] ?? '';

  // 전화번호 인증 설정 (AWS SNS)
  static String get snsRegion => dotenv.env['AWS_SNS_REGION'] ?? 'ap-northeast-2';
  static String get snsTopicArn => dotenv.env['AWS_SNS_TOPIC_ARN'] ?? '';

  // 전화번호 인증 코드 만료 시간 (분)
  static int get phoneVerificationTimeoutMinutes => 5;

  // Cognito Identity Provider 도메인
  static String get cognitoDomain => dotenv.env['COGNITO_DOMAIN'] ?? '';
  static String get redirectUri => 'myapp://auth';

  // 지원하는 로그인 방식
  static List<String> get supportedProviders => [
    'COGNITO', // 아이디/비밀번호
    'Google',
    'Kakao',
    'Naver',
    'PHONE' // 전화번호
  ];

  // 환경 변수 검증
  static void validate() {
    final requiredKeys = [
      'COGNITO_USER_POOL_CLIENT_ID',
      'COGNITO_IDENTITY_POOL_ID',
      'GOOGLE_CLIENT_ID',
      'KAKAO_NATIVE_APP_KEY',
      'NAVER_CLIENT_ID',
      'NAVER_CLIENT_SECRET',
      'COGNITO_DOMAIN',
      'AWS_SNS_TOPIC_ARN',
    ];
    final missing = requiredKeys.where((k) => (dotenv.env[k] ?? '').isEmpty).toList();
    if (missing.isNotEmpty) {
      throw Exception('AWSAuthConfig: 필수 환경 변수 누락: ${missing.join(', ')}');
    }
  }

  // 초기화 (dotenv 로드 및 검증)
  static Future<void> initialize() async {
    await dotenv.load();
    validate();
  }
} 