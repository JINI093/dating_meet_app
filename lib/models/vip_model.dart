import 'package:json_annotation/json_annotation.dart';

// part 'vip_model.g.dart';

@JsonSerializable()
class VipPlan {
  final String id;
  final String name;
  final String description;
  final int durationDays;
  final int originalPrice;
  final int discountPrice;
  final int discountPercent;
  final List<String> features;
  final bool isPopular;
  final bool isRecommended;
  final VipPlanType type;

  const VipPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.originalPrice,
    required this.discountPrice,
    required this.discountPercent,
    required this.features,
    this.isPopular = false,
    this.isRecommended = false,
    required this.type,
  });

  // factory VipPlan.fromJson(Map<String, dynamic> json) =>
  //     _$VipPlanFromJson(json);

  // Map<String, dynamic> toJson() => _$VipPlanToJson(this);
     
  String get displayPrice => '${discountPrice.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!(\d)))'), 
    (Match m) => '${m[1]},',
  )}원';

  String get displayOriginalPrice => '${originalPrice.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!(\d)))'), 
    (Match m) => '${m[1]},',
  )}원';

  String get durationText {
    if (durationDays == 7) return '1주';
    if (durationDays == 30) return '1개월';
    if (durationDays == 90) return '3개월';
    if (durationDays == 180) return '6개월';
    if (durationDays == 365) return '1년';
    return '${durationDays}일';
  }

  double get pricePerDay => discountPrice / durationDays;

  String get pricePerDayText => '일 ${pricePerDay.round()}원';

  bool get hasDiscount => discountPercent > 0;

  // Static factory methods for predefined plans
  static List<VipPlan> getAvailablePlans() {
    return [
      VipPlan(
        id: 'vip_1week',
        name: 'VIP 1주',
        description: 'VIP 기능을 체험해보세요',
        durationDays: 7,
        originalPrice: 9900,
        discountPrice: 7900,
        discountPercent: 20,
        features: [
          '무제한 좋아요',
          '슈퍼챗 5개 제공',
          '프로필 노출 증가',
          '읽음 확인',
          '나를 좋아요한 사람 확인',
        ],
        type: VipPlanType.weekly,
      ),
      VipPlan(
        id: 'vip_1month',
        name: 'VIP 1개월',
        description: '가장 인기있는 플랜',
        durationDays: 30,
        originalPrice: 29700,
        discountPrice: 19800,
        discountPercent: 33,
        features: [
          '무제한 좋아요',
          '슈퍼챗 20개 제공',
          '프로필 노출 증가',
          '읽음 확인',
          '나를 좋아요한 사람 확인',
          '프로필 부스트 3회',
          '고급 필터',
        ],
        isPopular: true,
        isRecommended: true,
        type: VipPlanType.monthly,
      ),
      VipPlan(
        id: 'vip_3month',
        name: 'VIP 3개월',
        description: '최고의 가성비',
        durationDays: 90,
        originalPrice: 89100,
        discountPrice: 49800,
        discountPercent: 44,
        features: [
          '무제한 좋아요',
          '슈퍼챗 80개 제공',
          '프로필 노출 증가',
          '읽음 확인',
          '나를 좋아요한 사람 확인',
          '프로필 부스트 12회',
          '고급 필터',
          '우선순위 지원',
          '24시간 고객 지원',
        ],
        isRecommended: true,
        type: VipPlanType.quarterly,
      ),
    ];
  }
}

@JsonSerializable()
class VipSubscription {
  final String id;
  final String userId;
  final VipPlan plan;
  final DateTime startDate;
  final DateTime endDate;
  final VipSubscriptionStatus status;
  final String? paymentId;
  final String? paymentMethod;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final bool autoRenew;

  const VipSubscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.paymentId,
    this.paymentMethod,
    this.cancelledAt,
    this.cancellationReason,
    this.autoRenew = true,
  });

  // factory VipSubscription.fromJson(Map<String, dynamic> json) =>
  //     _$VipSubscriptionFromJson(json);

  // Map<String, dynamic> toJson() => _$VipSubscriptionToJson(this);

  VipSubscription copyWith({
    String? id,
    String? userId,
    VipPlan? plan,
    DateTime? startDate,
    DateTime? endDate,
    VipSubscriptionStatus? status,
    String? paymentId,
    String? paymentMethod,
    DateTime? cancelledAt,
    String? cancellationReason,
    bool? autoRenew,
  }) {
    return VipSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }

  bool get isActive => status == VipSubscriptionStatus.active && 
                     DateTime.now().isBefore(endDate);

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isExpiringSoon => DateTime.now().isAfter(
    endDate.subtract(const Duration(days: 3))
  );

  int get remainingDays {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  String get remainingTimeText {
    if (isExpired) return '만료됨';
    
    final remaining = endDate.difference(DateTime.now());
    if (remaining.inDays > 0) {
      return '${remaining.inDays}일 남음';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}시간 남음';
    } else {
      return '곧 만료';
    }
  }

  String get statusText {
    switch (status) {
      case VipSubscriptionStatus.active:
        return isExpired ? '만료됨' : '활성';
      case VipSubscriptionStatus.cancelled:
        return '취소됨';
      case VipSubscriptionStatus.expired:
        return '만료됨';
      case VipSubscriptionStatus.pending:
        return '대기중';
    }
  }
}

@JsonSerializable()
class VipBenefit {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final VipBenefitType type;
  final bool isAvailable;
  final int? usageCount;
  final int? usageLimit;

  const VipBenefit({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.type,
    this.isAvailable = true,
    this.usageCount,
    this.usageLimit,
  });

  // factory VipBenefit.fromJson(Map<String, dynamic> json) =>
  //     _$VipBenefitFromJson(json);

  // Map<String, dynamic> toJson() => _$VipBenefitToJson(this);

  String get usageText {
    if (usageLimit == null) return '무제한';
    if (usageCount == null) return '${usageLimit}개 사용 가능';
    return '${usageLimit! - usageCount!}개 남음';
  }

  bool get isExhausted => usageLimit != null && 
                         usageCount != null && 
                         usageCount! >= usageLimit!;

  static List<VipBenefit> getDefaultBenefits() {
    return [
      VipBenefit(
        id: 'unlimited_likes',
        title: '무제한 좋아요',
        description: '하루 좋아요 제한 없이 모든 사람에게 좋아요를 보낼 수 있습니다',
        iconName: 'heart_fill',
        type: VipBenefitType.unlimited,
      ),
      VipBenefit(
        id: 'super_chat',
        title: '슈퍼챗',
        description: '매칭 전에도 메시지를 먼저 보낼 수 있습니다',
        iconName: 'paperplane_fill',
        type: VipBenefitType.superChat,
        usageCount: 5,
        usageLimit: 20,
      ),
      VipBenefit(
        id: 'profile_boost',
        title: '프로필 부스트',
        description: '30분간 프로필을 상위에 노출시킵니다',
        iconName: 'flame_fill',
        type: VipBenefitType.boost,
        usageCount: 1,
        usageLimit: 3,
      ),
      VipBenefit(
        id: 'read_receipts',
        title: '읽음 확인',
        description: '상대방이 메시지를 읽었는지 확인할 수 있습니다',
        iconName: 'checkmark_circle_fill',
        type: VipBenefitType.feature,
      ),
      VipBenefit(
        id: 'who_likes_you',
        title: '나를 좋아요한 사람',
        description: '나에게 좋아요를 보낸 사람들을 먼저 볼 수 있습니다',
        iconName: 'eye_fill',
        type: VipBenefitType.feature,
      ),
      VipBenefit(
        id: 'premium_filters',
        title: '고급 필터',
        description: '더 세밀한 조건으로 상대방을 찾을 수 있습니다',
        iconName: 'slider_horizontal_3',
        type: VipBenefitType.feature,
      ),
    ];
  }
}

enum VipPlanType {
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly,
  @JsonValue('yearly')
  yearly,
}

enum VipBenefitType {
  @JsonValue('unlimited')
  unlimited,
  @JsonValue('super_chat')
  superChat,
  @JsonValue('boost')
  boost,
  @JsonValue('feature')
  feature,
}

enum VipSubscriptionStatus {
  @JsonValue('active')
  active,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('expired')
  expired,
  @JsonValue('pending')
  pending,
}