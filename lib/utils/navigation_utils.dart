import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/route_names.dart';

/// 안전한 네비게이션 유틸리티
class NavigationUtils {
  /// 안전하게 이전 페이지로 이동 (스택이 비어있으면 홈으로)
  static void safePopOrHome(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  /// 안전하게 이전 페이지로 이동 (스택이 비어있으면 지정된 경로로)
  static void safePopOr(BuildContext context, String fallbackRoute) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute);
    }
  }

  /// Navigator.pop 대신 사용하는 안전한 버전
  static void safePop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }
}