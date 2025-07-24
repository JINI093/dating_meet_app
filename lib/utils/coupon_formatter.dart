import 'package:intl/intl.dart';

class CouponFormatter {
  // 쿠폰 번호 마스킹 (앞 4자리, 뒤 4자리만 노출)
  static String maskCouponNumber(String number) {
    if (number.length < 8) return '*' * number.length;
    return number.substring(0, 4) + '-' + '*' * (number.length - 8) + number.substring(number.length - 4);
  }

  // QR/바코드 데이터 포맷팅 (공백/하이픈 제거)
  static String formatBarcodeData(String data) => data.replaceAll(RegExp(r'[-\s]'), '');

  // 유효기간 표시 (yyyy-MM-dd → 2024.06.01 형식)
  static String formatExpireDate(String date) {
    try {
      final d = DateTime.parse(date);
      return DateFormat('yyyy.MM.dd').format(d);
    } catch (_) {
      return date;
    }
  }

  // 포인트 단위 포맷팅 (1,000P)
  static String formatPoint(int point) => '${NumberFormat('#,###').format(point)}P';

  // 브랜드별 쿠폰 디자인 규칙 (예시)
  static String getBrandTheme(String brand) {
    switch (brand) {
      case '신세계': return 'shinsegae';
      case '현대': return 'hyundai';
      case '롯데': return 'lotte';
      default: return 'default';
    }
  }
} 