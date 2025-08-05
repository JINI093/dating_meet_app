import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class DailyProfileCounter {
  final String userId;
  final DateTime date;
  final int profilesViewed;
  final String vipTier;
  final int dailyLimit;

  const DailyProfileCounter({
    required this.userId,
    required this.date,
    required this.profilesViewed,
    required this.vipTier,
    required this.dailyLimit,
  });

  DailyProfileCounter copyWith({
    String? userId,
    DateTime? date,
    int? profilesViewed,
    String? vipTier,
    int? dailyLimit,
  }) {
    return DailyProfileCounter(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      profilesViewed: profilesViewed ?? this.profilesViewed,
      vipTier: vipTier ?? this.vipTier,
      dailyLimit: dailyLimit ?? this.dailyLimit,
    );
  }

  factory DailyProfileCounter.create({
    required String userId,
    required String vipTier,
  }) {
    return DailyProfileCounter(
      userId: userId,
      date: DateTime.now(),
      profilesViewed: 0,
      vipTier: vipTier,
      dailyLimit: _getDailyLimitForTier(vipTier),
    );
  }

  static int _getDailyLimitForTier(String vipTier) {
    switch (vipTier.toUpperCase()) {
      case 'GOLD':
        return 15;
      case 'SILVER':
        return 10;
      case 'BRONZE':
        return 5;
      default:
        return 5; // Free users get same as Bronze
    }
  }

  bool get hasReachedLimit => profilesViewed >= dailyLimit;
  
  int get remainingProfiles => dailyLimit - profilesViewed;
  
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'date': date.toIso8601String(),
    'profilesViewed': profilesViewed,
    'vipTier': vipTier,
    'dailyLimit': dailyLimit,
  };

  factory DailyProfileCounter.fromJson(Map<String, dynamic> json) {
    return DailyProfileCounter(
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      profilesViewed: json['profilesViewed'] as int,
      vipTier: json['vipTier'] as String,
      dailyLimit: json['dailyLimit'] as int,
    );
  }
}