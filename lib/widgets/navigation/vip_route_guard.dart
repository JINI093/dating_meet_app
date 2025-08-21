import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/vip_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/vip/vip_dating_screen.dart';
import '../../screens/vip/vip_purchase_screen.dart';
import '../../models/vip_model.dart';

/// VIP 라우트 가드 위젯
/// 사용자의 VIP 상태에 따라 적절한 화면으로 라우팅
class VipRouteGuard extends ConsumerWidget {
  const VipRouteGuard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vipState = ref.watch(vipProvider);
    final userState = ref.watch(userProvider);
    
    // 로딩 중일 때
    if (vipState.isLoading || userState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // VIP 상태 확인
    final isVip = _checkVipStatus(userState, vipState);
    
    if (isVip) {
      // VIP 사용자: VIP 데이팅 화면으로 이동
      return const VipDatingScreen();
    } else {
      // 비VIP 사용자: 바로 VIP 구매 화면으로 이동
      return const VipPurchaseScreen();
    }
  }

  /// VIP 상태 확인
  bool _checkVipStatus(UserState userState, VipState vipState) {
    // 1. VIP 상태에서 확인
    if (vipState.isVipUser && vipState.currentSubscription != null) {
      final subscription = vipState.currentSubscription!;
      // 구독이 활성화되어 있고 만료되지 않았는지 확인
      if (subscription.status == VipSubscriptionStatus.active &&
          subscription.endDate.isAfter(DateTime.now())) {
        return true;
      }
    }
    
    // 2. 사용자 프로필에서 확인
    if (userState.currentUser?.isVip == true) {
      return true;
    }
    
    return false;
  }
}

/// VIP 네비게이션 헬퍼
class VipNavigationHelper {
  /// VIP 아이콘 클릭 시 호출되는 메서드
  static void navigateToVip(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VipRouteGuard(),
      ),
    );
  }
  
  /// 현재 사용자의 VIP 상태 확인
  static bool isCurrentUserVip(WidgetRef ref) {
    final vipState = ref.read(vipProvider);
    final userState = ref.read(userProvider);
    
    // VIP 상태 확인
    if (vipState.isVipUser && vipState.currentSubscription != null) {
      final subscription = vipState.currentSubscription!;
      if (subscription.status == VipSubscriptionStatus.active &&
          subscription.endDate.isAfter(DateTime.now())) {
        return true;
      }
    }
    
    // 사용자 프로필에서 확인
    if (userState.currentUser?.isVip == true) {
      return true;
    }
    
    return false;
  }
  
  /// VIP 만료일 확인
  static DateTime? getVipExpirationDate(WidgetRef ref) {
    final vipState = ref.read(vipProvider);
    
    if (vipState.currentSubscription != null) {
      return vipState.currentSubscription!.endDate;
    }
    
    return null;
  }
  
  /// VIP 등급 확인
  static String? getVipTier(WidgetRef ref) {
    final vipState = ref.read(vipProvider);
    
    // VIP 상태에서 확인
    if (vipState.currentSubscription != null) {
      final planName = vipState.currentSubscription!.plan.name.toUpperCase();
      if (planName.contains('GOLD')) return 'GOLD';
      if (planName.contains('SILVER')) return 'SILVER';
      if (planName.contains('BRONZE')) return 'BRONZE';
    }
    
    // 사용자 프로필에서 확인 (추후 구현 시)
    // if (userState.currentUser?.vipTier != null) {
    //   return userState.currentUser!.vipTier;
    // }
    
    return isCurrentUserVip(ref) ? 'GOLD' : null;
  }
}