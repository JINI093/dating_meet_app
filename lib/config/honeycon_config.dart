import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

class HoneyconConfig {
  // 환경별 URL
  static String get baseUrl {
    final env = dotenv.env['HONEYCON_ENVIRONMENT'] ?? 'development';
    return env == 'production'
        ? dotenv.env['HONEYCON_PROD_URL'] ?? 'https://api.honeycon.net'
        : dotenv.env['HONEYCON_DEV_URL'] ?? 'https://tapi.honeycon.net';
  }

  // API 기본 정보
  static String get memberId => dotenv.env['HONEYCON_MEMBER_ID'] ?? 'apitest';
  static String get eventId => dotenv.env['HONEYCON_EVENT_ID'] ?? '995';
  static String get goodsId => dotenv.env['HONEYCON_GOODS_ID'] ?? '0000000664';
  static String get securityKey => dotenv.env['HONEYCON_SECURITY_KEY'] ?? 'iapitest';

  // 기본 설정값
  static String get orderMobile => dotenv.env['HONEYCON_ORDER_MOBILE'] ?? '01012341234';

  // API 엔드포인트
  static String get orderSendUrl => '$baseUrl/external/orderSend.do';
  static String get orderCancelUrl => '$baseUrl/external/orderCancel.do';
  static String get orderResendUrl => '$baseUrl/external/orderResend.do';
  static String get orderDetailUrl => '$baseUrl/external/orderDetail.do';
  static String get eventGoodsListUrl => '$baseUrl/external/eventGoodsList.do';

  // 환경 변수 검증
  static void validate() {
    final requiredKeys = [
      'HONEYCON_DEV_URL',
      'HONEYCON_PROD_URL',
      'HONEYCON_MEMBER_ID',
      'HONEYCON_EVENT_ID',
      'HONEYCON_GOODS_ID',
      'HONEYCON_SECURITY_KEY',
      'HONEYCON_ENVIRONMENT',
      'HONEYCON_ORDER_MOBILE',
    ];
    final missing = requiredKeys.where((k) => (dotenv.env[k] ?? '').isEmpty).toList();
    if (missing.isNotEmpty) {
      Logger.e('[HoneyconConfig] 필수 환경 변수 누락: ${missing.join(', ')}');
      throw Exception('Honeycon 환경 변수 누락: ${missing.join(', ')}');
    }
    Logger.i('[HoneyconConfig] 모든 환경 변수 정상');
  }

  // 로깅
  static void logConfig() {
    Logger.i('[HoneyconConfig] baseUrl: $baseUrl');
    Logger.i('[HoneyconConfig] memberId: $memberId, eventId: $eventId, goodsId: $goodsId');
    Logger.i('[HoneyconConfig] orderMobile: $orderMobile');
  }
} 