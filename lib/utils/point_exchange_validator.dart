class PointExchangeValidator {
  // 포인트 잔액 검증
  static bool canExchange(int userPoint, int requiredPoint) => userPoint >= requiredPoint;

  // 한국 휴대폰 번호 형식 검증
  static bool isValidPhoneNumber(String phone) {
    final reg = RegExp(r'^01[016789]-?\d{3,4}-?\d{4}$');
    return reg.hasMatch(phone.replaceAll(' ', ''));
  }

  // 선물 메시지 길이 및 특수문자 검증 (최대 40자, 이모지/특수문자 제한)
  static bool isValidGiftMessage(String msg) {
    if (msg.length > 40) return false;
    final reg = RegExp(r'^[가-힣a-zA-Z0-9 .,!?\-]+$');
    return reg.hasMatch(msg);
  }

  // 쿠폰 만료일 검증 (yyyy-MM-dd)
  static bool isCouponExpired(String expireDate) {
    try {
      final exp = DateTime.parse(expireDate);
      return exp.isBefore(DateTime.now());
    } catch (_) {
      return true;
    }
  }

  // 교환 횟수 제한 검증 (일일/월간)
  static bool isExchangeLimitExceeded(int todayCount, int monthCount, {int dailyLimit = 3, int monthlyLimit = 10}) {
    return todayCount >= dailyLimit || monthCount >= monthlyLimit;
  }

  // 중복 교환 방지 (최근 동일 상품/수령자/시간 기준)
  static bool isDuplicateExchange(DateTime lastExchange, {int minMinutes = 5}) {
    return DateTime.now().difference(lastExchange).inMinutes < minMinutes;
  }
} 