class PointCalculator {
  // 포인트 적립률 계산 (예: 결제금액, 적립률)
  static int calculateEarnedPoint(int amount, double rate) => (amount * rate).round();

  // 교환 수수료 계산 (예: 2% 수수료)
  static int calculateExchangeFee(int point, {double feeRate = 0.02}) => (point * feeRate).round();

  // 등급별 혜택 (예: VIP 10%, GOLD 5%, 일반 0%)
  static double getBenefitRate(String grade) {
    switch (grade) {
      case 'VIP': return 0.10;
      case 'GOLD': return 0.05;
      default: return 0.0;
    }
  }

  // 포인트 만료 예정 계산 (만료일 기준 남은 일수)
  static int daysUntilExpire(DateTime expireDate) {
    return expireDate.difference(DateTime.now()).inDays;
  }

  // 교환 가능한 최대 상품권 개수 계산 (잔여포인트, 단위)
  static int maxExchangeableCount(int userPoint, {int unit = 1000, int maxPerRound = 30}) {
    final count = userPoint ~/ unit;
    return count > maxPerRound ? maxPerRound : count;
  }
} 