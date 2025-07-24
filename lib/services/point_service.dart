import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
// import 'package:amplify_datastore/amplify_datastore.dart';
// import 'package:amplify_api/amplify_api.dart'; // 실제 API 연동 시 사용

class PointService {
  // 사용자 포인트 조회 (AWS API)
  static Future<int> fetchUserPoint() async {
    // 실제 구현: Amplify API 호출 또는 Cognito 속성에서 조회
    try {
      final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      final user = await Amplify.Auth.getCurrentUser();
      // 예시: 사용자 속성에서 포인트 조회
      final attrs = await Amplify.Auth.fetchUserAttributes();
      final pointAttr = attrs.firstWhere((a) => a.userAttributeKey.key == 'custom:point', orElse: () => const AuthUserAttribute(userAttributeKey: CognitoUserAttributeKey.email, value: '0'));
      return int.tryParse(pointAttr.value) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // 포인트 적립/차감 처리 (AWS API + DynamoDB 기록)
  static Future<void> updateUserPoint(int delta, {String? reason}) async {
    // 1. Cognito 사용자 속성 업데이트
    final attrs = [
      AuthUserAttribute(
        userAttributeKey: CognitoUserAttributeKey.custom('point'),
        value: (await fetchUserPoint() + delta).toString(),
      ),
    ];
    await Amplify.Auth.updateUserAttributes(attributes: attrs);
    // 2. DynamoDB 거래 기록 (예시)
    // await Amplify.DataStore.save(PointTransactionModel(...));
  }

  // 포인트 거래 내역 동기화 (AWS DynamoDB)
  static Future<void> syncPointTransactions() async {
    // 실제 구현: Amplify.DataStore.query(PointTransactionModel)
  }

  // 포인트 만료 예정 알림 (로컬/푸시)
  static Future<void> notifyPointExpire() async {
    // 예시: 만료 예정 포인트 조회 후 알림
  }

  // 등급별 혜택 계산
  static double getBenefitRate(String grade) {
    switch (grade) {
      case 'VIP': return 0.10;
      case 'GOLD': return 0.05;
      default: return 0.0;
    }
  }

  // 포인트 통계 데이터 제공
  static Future<Map<String, dynamic>> getPointStats() async {
    // 예시: DynamoDB/로컬 데이터 집계
    return {
      'totalEarned': 100000,
      'totalSpent': 80000,
      'expireSoon': 5000,
      'grade': 'VIP',
    };
  }

  // 설정값 저장/조회 (SharedPreferences)
  static Future<void> saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is int) await prefs.setInt(key, value);
    else if (value is bool) await prefs.setBool(key, value);
    else if (value is String) await prefs.setString(key, value);
    else if (value is List<String>) await prefs.setStringList(key, value);
  }

  static Future<dynamic> getSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }
} 