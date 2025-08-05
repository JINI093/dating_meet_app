import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class DailyBenefitCounter {
  final String userId;
  final DateTime date;
  final int heartsUsed;
  final int superChatsUsed;
  final String vipTier;
  final int heartsLimit;
  final int superChatsLimit;

  const DailyBenefitCounter({
    required this.userId,
    required this.date,
    required this.heartsUsed,
    required this.superChatsUsed,
    required this.vipTier,
    required this.heartsLimit,
    required this.superChatsLimit,
  });

  DailyBenefitCounter copyWith({
    String? userId,
    DateTime? date,
    int? heartsUsed,
    int? superChatsUsed,
    String? vipTier,
    int? heartsLimit,
    int? superChatsLimit,
  }) {
    return DailyBenefitCounter(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      heartsUsed: heartsUsed ?? this.heartsUsed,
      superChatsUsed: superChatsUsed ?? this.superChatsUsed,
      vipTier: vipTier ?? this.vipTier,
      heartsLimit: heartsLimit ?? this.heartsLimit,
      superChatsLimit: superChatsLimit ?? this.superChatsLimit,
    );
  }

  factory DailyBenefitCounter.create({
    required String userId,
    required String vipTier,
  }) {
    final limits = _getBenefitLimitsForTier(vipTier);
    return DailyBenefitCounter(
      userId: userId,
      date: DateTime.now(),
      heartsUsed: 0,
      superChatsUsed: 0,
      vipTier: vipTier,
      heartsLimit: limits['hearts']!,
      superChatsLimit: limits['superChats']!,
    );
  }

  static Map<String, int> _getBenefitLimitsForTier(String vipTier) {
    switch (vipTier.toUpperCase()) {
      case 'GOLD':
        return {'hearts': 0, 'superChats': 0}; // Gold는 무제한이므로 0으로 설정 (제한 없음)
      case 'SILVER':
        return {'hearts': 2, 'superChats': 2}; // Silver는 매일 2개씩
      case 'BRONZE':
        return {'hearts': 0, 'superChats': 0}; // Bronze는 특별 혜택 없음
      default:
        return {'hearts': 0, 'superChats': 0}; // Free users
    }
  }

  bool get hasReachedHeartsLimit => heartsLimit > 0 && heartsUsed >= heartsLimit;
  bool get hasReachedSuperChatsLimit => superChatsLimit > 0 && superChatsUsed >= superChatsLimit;
  
  int get remainingHearts => heartsLimit > 0 ? heartsLimit - heartsUsed : -1; // -1 means unlimited
  int get remainingSuperChats => superChatsLimit > 0 ? superChatsLimit - superChatsUsed : -1; // -1 means unlimited
  
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  bool canUseHeart() {
    return heartsLimit == 0 || heartsUsed < heartsLimit; // 0은 무제한을 의미
  }

  bool canUseSuperChat() {
    return superChatsLimit == 0 || superChatsUsed < superChatsLimit; // 0은 무제한을 의미
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'date': date.toIso8601String(),
    'heartsUsed': heartsUsed,
    'superChatsUsed': superChatsUsed,
    'vipTier': vipTier,
    'heartsLimit': heartsLimit,
    'superChatsLimit': superChatsLimit,
  };

  factory DailyBenefitCounter.fromJson(Map<String, dynamic> json) {
    return DailyBenefitCounter(
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      heartsUsed: json['heartsUsed'] as int,
      superChatsUsed: json['superChatsUsed'] as int,
      vipTier: json['vipTier'] as String,
      heartsLimit: json['heartsLimit'] as int,
      superChatsLimit: json['superChatsLimit'] as int,
    );
  }
}