import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vip_model.dart';
import '../models/profile_model.dart';
import '../services/aws_profile_service.dart';
import '../utils/logger.dart';
import 'enhanced_auth_provider.dart';
import 'user_provider.dart';

// VIP State
class VipState {
  final bool isVipUser;
  final VipSubscription? currentSubscription;
  final List<VipPlan> availablePlans;
  final List<VipBenefit> benefits;
  final bool isLoading;
  final String? error;

  const VipState({
    this.isVipUser = false,
    this.currentSubscription,
    this.availablePlans = const [],
    this.benefits = const [],
    this.isLoading = false,
    this.error,
  });

  VipState copyWith({
    bool? isVipUser,
    VipSubscription? currentSubscription,
    List<VipPlan>? availablePlans,
    List<VipBenefit>? benefits,
    bool? isLoading,
    String? error,
  }) {
    return VipState(
      isVipUser: isVipUser ?? this.isVipUser,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      availablePlans: availablePlans ?? this.availablePlans,
      benefits: benefits ?? this.benefits,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// VIP Provider
class VipNotifier extends StateNotifier<VipState> {
  final Ref _ref;
  final AWSProfileService _profileService = AWSProfileService();
  
  VipNotifier(this._ref) : super(const VipState()) {
    _initializeVipData();
  }

  void _initializeVipData() {
    state = state.copyWith(
      availablePlans: VipPlan.getAvailablePlans(),
      benefits: VipBenefit.getDefaultBenefits(),
    );
    
    _checkCurrentSubscription();
  }

  Future<void> _checkCurrentSubscription() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      Logger.log('VIP 구독 상태 확인 시작', name: 'VipProvider');
      
      // Get current user from auth provider
      final authState = _ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        Logger.log('사용자 인증 실패 - VIP 상태 확인 불가', name: 'VipProvider');
        state = state.copyWith(isLoading: false);
        return;
      }
      
      final userId = authState.currentUser!.user!.userId;
      
      // Get user profile to check VIP status
      final profile = await _profileService.getProfileByUserId(userId).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          Logger.log('프로필 조회 타임아웃 - 로컬 데이터 사용', name: 'VipProvider');
          return null;
        },
      );
      
      VipSubscription? subscription;
      bool isVipUser = false;
      
      if (profile != null) {
        isVipUser = profile.isVip;
        Logger.log('AWS 프로필에서 VIP 상태 확인: $isVipUser', name: 'VipProvider');
        
        // If user is VIP, create subscription object (this would normally come from a separate VIP service)
        if (isVipUser) {
          subscription = VipSubscription(
            id: 'sub_${userId}_current',
            userId: userId,
            plan: VipPlan.getAvailablePlans()[1], // Default to monthly for now
            startDate: profile.createdAt,
            endDate: DateTime.now().add(const Duration(days: 30)), // Assume 30 days from now
            status: VipSubscriptionStatus.active,
            autoRenew: true,
            paymentMethod: 'AWS_MANAGED',
          );
        }
      } else {
        Logger.log('프로필을 찾을 수 없음 - 기본값 사용', name: 'VipProvider');
      }
      
      state = state.copyWith(
        isVipUser: isVipUser,
        currentSubscription: subscription,
        isLoading: false,
      );
      
      Logger.log('VIP 상태 확인 완료: isVip=$isVipUser', name: 'VipProvider');
    } catch (e) {
      Logger.error('VIP 구독 상태 확인 실패: $e', name: 'VipProvider');
      state = state.copyWith(
        isLoading: false,
        error: 'VIP 상태를 확인할 수 없습니다: ${e.toString()}',
      );
    }
  }

  Future<bool> purchaseVipPlan(VipPlan plan) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      Logger.log('VIP 플랜 구매 시작: ${plan.name}', name: 'VipProvider');
      
      // Get current user
      final authState = _ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final userId = authState.currentUser!.user!.userId;
      
      // In a real implementation, this would call payment service first
      // For now, we'll simulate payment success and update profile
      Logger.log('결제 처리 시뮬레이션...', name: 'VipProvider');
      await Future.delayed(const Duration(seconds: 2));
      
      // Get current profile (force refresh to get latest updatedAt)
      final profile = await _profileService.getProfile(userId, forceRefresh: true).timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      
      if (profile == null) {
        throw Exception('프로필을 찾을 수 없습니다.');
      }
      
      // Calculate VIP end date
      final vipStartDate = DateTime.now();
      final vipEndDate = vipStartDate.add(Duration(days: plan.durationDays));
      
      // Update profile to VIP status in AWS (with error handling)
      ProfileModel? updatedProfile;
      try {
        updatedProfile = await _profileService.updateProfile(
          profileId: profile.id,
          additionalData: {
            'isVip': true,
            'isPremium': plan.name.contains('PREMIUM') || plan.name.contains('GOLD'),
            'vipStartDate': vipStartDate.toIso8601String(),
            'vipEndDate': vipEndDate.toIso8601String(),
            'vipPlan': plan.name,
            'vipTier': _getVipTierFromPlan(plan.name),
          },
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            Logger.log('프로필 업데이트 타임아웃 - 로컬 상태만 업데이트', name: 'VipProvider');
            return null;
          },
        );
      } catch (e) {
        if (e.toString().contains('not authorized') || e.toString().contains('Unauthorized')) {
          Logger.log('AWS 권한 오류 감지 - 로컬 VIP 상태만 업데이트: $e', name: 'VipProvider');
        } else {
          Logger.log('프로필 업데이트 실패 - 로컬 상태만 업데이트: $e', name: 'VipProvider');
        }
        // 권한 오류여도 로컬 상태는 업데이트 진행
        updatedProfile = null;
      }
      
      // Create new subscription
      final newSubscription = VipSubscription(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        plan: plan,
        startDate: vipStartDate,
        endDate: vipEndDate,
        status: VipSubscriptionStatus.active,
        autoRenew: true,
        paymentMethod: 'AWS_PAYMENT',
      );
      
      state = state.copyWith(
        isVipUser: true,
        currentSubscription: newSubscription,
        isLoading: false,
      );
      
      // Update user provider with VIP status
      await _ref.read(userProvider.notifier).updateVipStatus(
        isVip: true,
        vipStartDate: vipStartDate,
        vipEndDate: vipEndDate,
        vipTier: _getVipTierFromPlan(plan.name),
      );
      
      Logger.log('VIP 구매 성공: ${updatedProfile != null ? "AWS 업데이트 완료" : "로컬 상태만 업데이트"}', name: 'VipProvider');
      return true;
    } catch (e) {
      Logger.error('VIP 구매 실패: $e', name: 'VipProvider');
      state = state.copyWith(
        isLoading: false,
        error: 'VIP 구매에 실패했습니다: ${e.toString()}',
      );
      return false;
    }
  }

  /// VIP 플랜명에서 등급 추출
  String _getVipTierFromPlan(String planName) {
    if (planName.toUpperCase().contains('GOLD')) return 'GOLD';
    if (planName.toUpperCase().contains('SILVER')) return 'SILVER';
    if (planName.toUpperCase().contains('BRONZE')) return 'BRONZE';
    return 'GOLD'; // 기본값
  }

  /// VIP 티켓 구매 처리 (포인트 상점에서 호출)
  Future<bool> purchaseVipTicket({
    required String tier, // GOLD, SILVER, BRONZE
    required int days,
    required int price,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      Logger.log('VIP 티켓 구매 시작: $tier $days일 ($price P)', name: 'VipProvider');
      
      // Get current user
      final authState = _ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final userId = authState.currentUser!.user!.userId;
      
      // Simulate payment processing
      Logger.log('포인트 결제 처리...', name: 'VipProvider');
      await Future.delayed(const Duration(seconds: 1));
      
      // Get current profile (force refresh to get latest updatedAt)
      final profile = await _profileService.getProfile(userId, forceRefresh: true).timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      
      if (profile == null) {
        throw Exception('프로필을 찾을 수 없습니다.');
      }
      
      // Calculate VIP dates
      final vipStartDate = DateTime.now();
      final vipEndDate = vipStartDate.add(Duration(days: days));
      
      // Update profile to VIP status
      await _profileService.updateProfile(
        profileId: profile.id,
        additionalData: {
          'isVip': true,
          'isPremium': tier == 'GOLD',
          'vipStartDate': vipStartDate.toIso8601String(),
          'vipEndDate': vipEndDate.toIso8601String(),
          'vipTier': tier,
          'lastVipPurchase': DateTime.now().toIso8601String(),
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          Logger.log('VIP 프로필 업데이트 타임아웃', name: 'VipProvider');
          return null;
        },
      );
      
      // Create subscription for tracking
      final newSubscription = VipSubscription(
        id: 'ticket_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        plan: VipPlan(
          id: 'ticket_$tier',
          name: '$tier VIP $days일',
          description: '$tier 등급 VIP $days일 이용권',
          durationDays: days,
          originalPrice: price + 100, // 가상의 원가
          discountPrice: price,
          discountPercent: ((100 * 100) / (price + 100)).round(), // 할인율 계산
          features: _getVipFeatures(tier),
          isPopular: days == 30,
          isRecommended: days == 30,
          type: _getVipPlanTypeFromDays(days),
        ),
        startDate: vipStartDate,
        endDate: vipEndDate,
        status: VipSubscriptionStatus.active,
        autoRenew: false, // 티켓은 자동갱신 없음
        paymentMethod: 'POINT_PAYMENT',
      );
      
      state = state.copyWith(
        isVipUser: true,
        currentSubscription: newSubscription,
        isLoading: false,
      );
      
      // Update user provider with VIP status
      await _ref.read(userProvider.notifier).updateVipStatus(
        isVip: true,
        vipStartDate: vipStartDate,
        vipEndDate: vipEndDate,
        vipTier: tier,
      );
      
      Logger.log('VIP 티켓 구매 성공: $tier $days일', name: 'VipProvider');
      return true;
      
    } catch (e) {
      Logger.error('VIP 티켓 구매 실패: $e', name: 'VipProvider');
      state = state.copyWith(
        isLoading: false,
        error: 'VIP 티켓 구매에 실패했습니다: ${e.toString()}',
      );
      return false;
    }
  }

  /// VIP 등급별 특징 반환
  List<String> _getVipFeatures(String tier) {
    switch (tier) {
      case 'GOLD':
        return ['VIP GOLD 배지', '프로필 우선 노출', '무제한 좋아요', '슈퍼챗 할인'];
      case 'SILVER':
        return ['VIP SILVER 배지', '프로필 노출 우선순위', '추가 좋아요'];
      case 'BRONZE':
        return ['VIP BRONZE 배지', '기본 VIP 혜택'];
      default:
        return ['VIP 혜택'];
    }
  }

  /// 일수에 따른 VIP 플랜 타입 결정
  VipPlanType _getVipPlanTypeFromDays(int days) {
    if (days <= 7) {
      return VipPlanType.weekly;
    } else if (days <= 30) {
      return VipPlanType.monthly;
    } else if (days <= 90) {
      return VipPlanType.quarterly;
    } else {
      return VipPlanType.yearly;
    }
  }

  Future<bool> cancelSubscription() async {
    if (state.currentSubscription == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      final updatedSubscription = state.currentSubscription!.copyWith(
        status: VipSubscriptionStatus.cancelled,
        autoRenew: false,
      );
      
      state = state.copyWith(
        currentSubscription: updatedSubscription,
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> renewSubscription() async {
    if (state.currentSubscription == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      final plan = state.currentSubscription!.plan;
      final newEndDate = DateTime.now().add(Duration(days: plan.durationDays));
      
      final updatedSubscription = state.currentSubscription!.copyWith(
        endDate: newEndDate,
        status: VipSubscriptionStatus.active,
        autoRenew: true,
      );
      
      state = state.copyWith(
        currentSubscription: updatedSubscription,
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> refreshVipStatus() async {
    await _checkCurrentSubscription();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // VIP 혜택 사용 관련 메서드들
  bool canUseBenefit(String benefitType) {
    if (!state.isVipUser || state.currentSubscription == null) {
      return false;
    }
    
    final subscription = state.currentSubscription!;
    
    // 구독 상태 확인
    if (subscription.status != VipSubscriptionStatus.active) {
      return false;
    }
    
    // 만료일 확인
    if (subscription.endDate.isBefore(DateTime.now())) {
      return false;
    }
    
    // 혜택별 사용 가능 여부 확인
    switch (benefitType) {
      case 'unlimited_likes':
      case 'profile_boost':
      case 'read_receipts':
      case 'who_liked_me':
      case 'advanced_filters':
        return true;
      case 'super_chat':
        // 슈퍼챗은 월 사용량 제한 확인
        return _checkSuperChatUsage();
      default:
        return false;
    }
  }

  bool _checkSuperChatUsage() {
    if (state.currentSubscription == null) return false;
    
    final superChatBenefit = state.benefits
        .where((b) => b.type == VipBenefitType.superChat)
        .firstOrNull;
    
    if (superChatBenefit == null || superChatBenefit.usageLimit == null) {
      return false;
    }
    
    // TODO: 실제 사용량 조회 로직 구현
    // 현재는 데모용으로 항상 사용 가능으로 반환
    return true;
  }

  int? getSuperChatRemaining() {
    if (!canUseBenefit('super_chat')) return null;
    
    final superChatBenefit = state.benefits
        .where((b) => b.type == VipBenefitType.superChat)
        .firstOrNull;
    
    if (superChatBenefit?.usageLimit == null) return null;
    
    // TODO: 실제 사용량 조회하여 남은 개수 반환
    // 현재는 데모용으로 랜덤 값 반환
    return superChatBenefit!.usageLimit! - (DateTime.now().day % 5);
  }

  Future<bool> useSuperChat() async {
    if (!canUseBenefit('super_chat')) return false;
    
    try {
      // TODO: 슈퍼챗 사용 API 호출
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 사용량 업데이트는 실제 구현에서 처리
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> useBenefit(String benefitId) async {
    try {
      final updatedBenefits = state.benefits.map((benefit) {
        if (benefit.id == benefitId && 
            benefit.usageLimit != null && 
            !benefit.isExhausted) {
          return VipBenefit(
            id: benefit.id,
            title: benefit.title,
            description: benefit.description,
            iconName: benefit.iconName,
            type: benefit.type,
            isAvailable: benefit.isAvailable,
            usageCount: (benefit.usageCount ?? 0) + 1,
            usageLimit: benefit.usageLimit,
          );
        }
        return benefit;
      }).toList();
      
      state = state.copyWith(benefits: updatedBenefits);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  VipBenefit? getBenefit(String benefitId) {
    try {
      return state.benefits.firstWhere((benefit) => benefit.id == benefitId);
    } catch (e) {
      return null;
    }
  }

  Future<void> toggleAutoRenew() async {
    if (state.currentSubscription == null) return;
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      final updatedSubscription = state.currentSubscription!.copyWith(
        autoRenew: !state.currentSubscription!.autoRenew,
      );
      
      state = state.copyWith(currentSubscription: updatedSubscription);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Get subscription history (mock data)
  List<VipSubscription> getSubscriptionHistory() {
    final now = DateTime.now();
    return [
      VipSubscription(
        id: 'sub_old_1',
        userId: 'user_123',
        plan: VipPlan.getAvailablePlans()[0],
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.subtract(const Duration(days: 53)),
        status: VipSubscriptionStatus.expired,
        paymentMethod: 'card_****5678',
      ),
      VipSubscription(
        id: 'sub_old_2',
        userId: 'user_123',
        plan: VipPlan.getAvailablePlans()[1],
        startDate: now.subtract(const Duration(days: 120)),
        endDate: now.subtract(const Duration(days: 90)),
        status: VipSubscriptionStatus.expired,
        paymentMethod: 'card_****9012',
      ),
    ];
  }

  // Get usage statistics
  Map<String, dynamic> getUsageStatistics() {
    int totalSuperChats = 0;
    int totalBoosts = 0;
    
    for (final benefit in state.benefits) {
      if (benefit.id == 'super_chat') {
        totalSuperChats = benefit.usageCount ?? 0;
      } else if (benefit.id == 'profile_boost') {
        totalBoosts = benefit.usageCount ?? 0;
      }
    }
    
    return {
      'totalSuperChats': totalSuperChats,
      'totalBoosts': totalBoosts,
      'memberSince': state.currentSubscription?.startDate,
      'totalSavings': _calculateTotalSavings(),
    };
  }

  int _calculateTotalSavings() {
    if (state.currentSubscription == null) return 0;
    
    final plan = state.currentSubscription!.plan;
    return plan.originalPrice - plan.discountPrice;
  }

  // 등급별 VIP 프로필 리스트 반환 (실제 사용자 데이터)
  Future<List<ProfileModel>> getProfilesByGrade(String grade) async {
    try {
      Logger.log('VIP 프로필 로드 시작 - 등급: $grade', name: 'VipProvider');
      
      // Get current user info
      final authState = _ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        Logger.log('사용자 인증 실패 - 빈 리스트 반환', name: 'VipProvider');
        return [];
      }
      
      final currentUserId = authState.currentUser!.user!.userId;
      
      // Get my profile to determine target gender
      final myProfile = await _profileService.getProfile(currentUserId);
      Logger.log('내 프로필 존재 여부: ${myProfile != null}', name: 'VipProvider');
      Logger.log('내 프로필 성별: ${myProfile?.gender}', name: 'VipProvider');
      
      String? targetGender;
      if (myProfile != null && myProfile.gender != null) {
        if (myProfile.gender == '남성' || myProfile.gender == 'M') {
          targetGender = '여성';
        } else if (myProfile.gender == '여성' || myProfile.gender == 'F') {
          targetGender = '남성';
        }
      } else {
        // 성별 정보가 없으면 기본값으로 여성 프로필을 표시
        Logger.log('성별 정보가 없어 기본값(여성) 사용', name: 'VipProvider');
        targetGender = '여성';
      }
      
      Logger.log('타겟 성별: $targetGender', name: 'VipProvider');
      
      // Get VIP profiles from AWS with grade filter
      final vipProfiles = await _profileService.getVipProfiles(
        currentUserId: currentUserId,
        gender: targetGender,
        vipGrade: grade,
        limit: 10,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          Logger.log('VIP 프로필 로드 타임아웃 - 빈 리스트 반환', name: 'VipProvider');
          return <ProfileModel>[];
        },
      );
      
      Logger.log('가져온 VIP 프로필 수: ${vipProfiles.length}', name: 'VipProvider');
      
      if (vipProfiles.isNotEmpty) {
        Logger.log('✅ AWS에서 실제 VIP 프로필 로드 성공!', name: 'VipProvider');
        Logger.log('첫 번째 프로필: ${vipProfiles.first.name} (${vipProfiles.first.gender})', name: 'VipProvider');
        return vipProfiles;
      } else {
        Logger.log('⚠️ VIP 프로필이 없음 - 일반 프로필로 대체', name: 'VipProvider');
        // If no VIP profiles available, fallback to regular discover profiles
        final fallbackProfiles = await _profileService.getDiscoverProfiles(
          currentUserId: currentUserId,
          gender: targetGender,
          limit: 5,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            Logger.log('일반 프로필 로드 타임아웃', name: 'VipProvider');
            return <ProfileModel>[];
          },
        );
        
        Logger.log('대체 프로필 수: ${fallbackProfiles.length}', name: 'VipProvider');
        return fallbackProfiles;
      }
      
    } catch (e) {
      Logger.error('VIP 프로필 로드 실패: $e', name: 'VipProvider');
      return [];
    }
  }
}

// Provider 정의
final vipProvider = StateNotifierProvider<VipNotifier, VipState>((ref) {
  return VipNotifier(ref);
});

// 편의성을 위한 추가 Provider들
final isVipUserProvider = Provider<bool>((ref) {
  final vipState = ref.watch(vipProvider);
  return vipState.isVipUser;
});

final currentVipSubscriptionProvider = Provider<VipSubscription?>((ref) {
  final vipState = ref.watch(vipProvider);
  return vipState.currentSubscription;
});

final vipBenefitsProvider = Provider<List<VipBenefit>>((ref) {
  final vipState = ref.watch(vipProvider);
  return vipState.benefits;
});

final availableVipPlansProvider = Provider<List<VipPlan>>((ref) {
  final vipState = ref.watch(vipProvider);
  return vipState.availablePlans;
});

// VIP 혜택 사용 가능 여부 확인 Provider
final canUseBenefitProvider = Provider.family<bool, String>((ref, benefitType) {
  final vipNotifier = ref.read(vipProvider.notifier);
  return vipNotifier.canUseBenefit(benefitType);
});

// 슈퍼챗 남은 개수 Provider
final superChatRemainingProvider = Provider<int?>((ref) {
  final vipNotifier = ref.read(vipProvider.notifier);
  return vipNotifier.getSuperChatRemaining();
});