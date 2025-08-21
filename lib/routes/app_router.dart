import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_names.dart';
import '../admin/routes/admin_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/enhanced_login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/find_id_screen.dart';
import '../screens/auth/terms_screen.dart';
import '../screens/auth/phone_verification_screen.dart';
import '../screens/auth/signup_complete_screen.dart';
import '../screens/auth/signup_id_input_screen.dart';
import '../screens/auth/signup_password_input_screen.dart';
import '../screens/auth/signup_complete_info_screen.dart';
import '../screens/auth/java_pass_auth_screen.dart';
import '../screens/onboarding/onboarding_tutorial_screen.dart';
import '../screens/onboarding/profile_setup_screen.dart';
import '../screens/bottom_navigation/bottom_navigation_screen.dart';
import '../screens/home/main_screen.dart';
import '../screens/likes/likes_screen.dart';
import '../screens/likes/received_likes_screen.dart';
import '../screens/likes/sent_likes_screen.dart';
import '../screens/chat/chat_room_screen.dart';
import '../screens/faq/faq_list_screen.dart';
import '../screens/notice/notice_list_screen.dart';
import '../screens/notice/notice_detail_screen.dart';
import '../screens/privacy/privacy_list_screen.dart';
import '../screens/error/not_found_screen.dart';
import '../screens/vip/vip_membership_screen.dart';
import '../screens/vip/vip_purchase_screen.dart';
import '../screens/vip/vip_dating_screen.dart';
import '../widgets/navigation/vip_route_guard.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/profile/my_profile_screen.dart';
import '../screens/profile/other_profile_screen.dart';
import '../screens/point/point_shop_screen.dart';
import '../screens/point/ticket_shop_screen.dart';
import '../models/match_model.dart';
import '../models/profile_model.dart';
import '../screens/point_exchange/point_exchange_main_screen.dart';
import '../screens/point_exchange/gift_card_catalog_screen.dart';
import '../screens/point_exchange/exchange_success_screen.dart';
import '../screens/notification/notification_screen.dart';
// TODO: 상품권 상세, 쿠폰함, 교환내역, 쿠폰상세 화면 import 필요

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.enhancedLogin,
        name: 'enhancedLogin',
        builder: (context, state) => const EnhancedLoginScreen(),
      ),
      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SignupScreen(
            mobileOKVerification: extra?['mobileOKVerification'],
            additionalData: extra,
          );
        },
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const FindIdScreen(),
      ),
      GoRoute(
        path: RouteNames.accountRecovery,
        name: 'accountRecovery',
        builder: (context, state) => const FindIdScreen(),
      ),
      GoRoute(
        path: RouteNames.findId,
        name: 'findId',
        builder: (context, state) => const FindIdScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: 'resetPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.terms,
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: RouteNames.phoneVerification,
        name: 'phoneVerification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PhoneVerificationScreen(agreedTerms: extra);
        },
      ),
      GoRoute(
        path: RouteNames.signupComplete,
        name: 'signupComplete',
        builder: (context, state) {
          final signupData = state.extra as Map<String, dynamic>?;
          return SignupCompleteScreen(signupData: signupData);
        },
      ),
      
      // 새로운 회원가입 플로우 라우트
      GoRoute(
        path: RouteNames.signupIdInput,
        name: 'signupIdInput',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SignupIdInputScreen(
            mobileOKVerification: extra?['mobileOKVerification'],
            additionalData: extra?['additionalData'],
          );
        },
      ),
      GoRoute(
        path: RouteNames.signupPasswordInput,
        name: 'signupPasswordInput',
        builder: (context, state) {
          final signupData = state.extra as Map<String, dynamic>?;
          return SignupPasswordInputScreen(signupData: signupData);
        },
      ),
      GoRoute(
        path: RouteNames.signupCompleteInfo,
        name: 'signupCompleteInfo',
        builder: (context, state) {
          final signupData = state.extra as Map<String, dynamic>?;
          return SignupCompleteInfoScreen(signupData: signupData);
        },
      ),
      GoRoute(
        path: RouteNames.javaPassAuth,
        name: 'javaPassAuth',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return JavaPassAuthScreen(
            purpose: extra?['purpose'] ?? '회원가입',
            additionalData: extra,
          );
        },
      ),

      // Onboarding Routes
      GoRoute(
        path: RouteNames.intro,
        name: 'intro',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('인트로 화면 - 개발 중')),
        ),
      ),
      GoRoute(
        path: RouteNames.onboardingTutorial,
        name: 'onboardingTutorial',
        builder: (context, state) => const OnboardingTutorialScreen(),
      ),
      GoRoute(
        path: RouteNames.profileSetup,
        name: 'profileSetup',
        builder: (context, state) {
          final signupData = state.extra as Map<String, dynamic>?;
          return ProfileSetupScreen(signupData: signupData);
        },
      ),
      GoRoute(
        path: RouteNames.profileComplete,
        name: 'profileComplete',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('프로필 완성 화면 - 개발 중')),
        ),
      ),

      // Main App Routes with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return BottomNavigationScreen(child: child);
        },
        routes: [
          // Home Tab
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            builder: (context, state) => const MainScreen(),
            routes: [
              GoRoute(
                path: 'matching',
                name: 'matching',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('매칭 화면 - 개발 중')),
                ),
              ),
            ],
          ),

          // Likes Tab
          GoRoute(
            path: RouteNames.likes,
            name: 'likes',
            builder: (context, state) => const LikesScreen(),
            routes: [
              GoRoute(
                path: 'received',
                name: 'receivedLikes',
                builder: (context, state) => const ReceivedLikesScreen(),
              ),
              GoRoute(
                path: 'sent',
                name: 'sentLikes',
                builder: (context, state) => const SentLikesScreen(),
              ),
              GoRoute(
                path: 'super-chat',
                name: 'superChat',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('슈퍼채팅 화면 - 개발 중')),
                ),
              ),
            ],
          ),

          // VIP Tab
          GoRoute(
            path: RouteNames.vip,
            name: 'vip',
            builder: (context, state) => const VipRouteGuard(),
            routes: [
              GoRoute(
                path: 'today',
                name: 'vipToday',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('VIP Today 화면 - 개발 중')),
                ),
              ),
              GoRoute(
                path: 'plans',
                name: 'vipPlans',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('VIP Plans 화면 - 개발 중')),
                ),
              ),
              GoRoute(
                path: 'membership',
                name: 'vipMembership',
                builder: (context, state) => const VipMembershipScreen(),
              ),
              GoRoute(
                path: 'purchase',
                name: 'vipPurchase',
                builder: (context, state) => const VipPurchaseScreen(),
              ),
            ],
          ),

          // Chat Tab
          GoRoute(
            path: RouteNames.chat,
            name: 'chat',
            builder: (context, state) => const ChatListScreen(),
          ),

          // Profile Tab
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            builder: (context, state) => const MyProfileScreen(),
          ),
        ],
      ),

      // Chat Room (Outside bottom navigation)
      GoRoute(
        path: '${RouteNames.chatRoom}/:chatId',
        name: 'chatRoom',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          
          // Debug logging
          print('🚀 ChatRoom 라우트 빌더 호출됨');
          print('   chatId: $chatId');
          print('   state.extra: ${state.extra}');
          
          // Try to get MatchModel from extra parameter
          final match = state.extra as MatchModel?;
          
          if (match != null) {
            print('✅ MatchModel 전달됨: ${match.id}, 프로필: ${match.profile.name}');
          } else {
            print('⚠️  MatchModel이 없어서 임시 생성');
          }
          
          // If no match provided, create a temporary one
          final finalMatch = match ?? MatchModel(
            id: chatId,
            profile: ProfileModel(
              id: 'temp_user',
              name: '사용자',
              age: 30,
              location: '서울',
              profileImages: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            matchedAt: DateTime.now(),
          );
          
          print('📱 ChatRoomScreen 생성: ${finalMatch.id}');
          return ChatRoomScreen(
            match: finalMatch,
            chatId: chatId,
          );
        },
      ),

      // Profile Routes (Outside bottom navigation)
      // GoRoute(
      //   path: RouteNames.editProfile,
      //   name: 'editProfile',
      //   builder: (context, state) => const EditProfileScreen(),
      // ),
      GoRoute(
        path: RouteNames.otherProfile,
        name: 'otherProfile',
        builder: (context, state) {
          final profile = state.extra as ProfileModel;
          return OtherProfileScreen(profile: profile);
        },
      ),
      // GoRoute(
      //   path: RouteNames.profileVerification,
      //   name: 'profileVerification',
      //   builder: (context, state) => const ProfileVerificationScreen(),
      // ),

      // Notification Routes
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      // Point Routes
      GoRoute(
        path: RouteNames.pointShop,
        name: 'pointShop',
        builder: (context, state) => const PointShopScreen(),
      ),
      GoRoute(
        path: RouteNames.ticketShop,
        name: 'ticketShop',
        builder: (context, state) {
          print('🎫 TicketShop 라우트 호출됨: ${RouteNames.ticketShop}');
          try {
            // 쿼리 파라미터에서 탭 인덱스 가져오기
            final tabParam = state.uri.queryParameters['tab'];
            final initialTabIndex = tabParam != null ? int.tryParse(tabParam) ?? 0 : 0;
            
            print('Tab 파라미터: $tabParam, 초기 탭 인덱스: $initialTabIndex');
            
            return TicketShopScreen(initialTabIndex: initialTabIndex);
          } catch (e) {
            print('❌ TicketShopScreen 생성 오류: $e');
            return Scaffold(
              appBar: AppBar(title: const Text('이용권 구매')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('TicketShopScreen 로딩 중 오류가 발생했습니다.'),
                    const SizedBox(height: 16),
                    Text('오류: $e'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('뒤로가기'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      // GoRoute(
      //   path: RouteNames.pointHistory,
      //   name: 'pointHistory',
      //   builder: (context, state) => const PointHistoryScreen(),
      // ),
      // GoRoute(
      //   path: RouteNames.purchase,
      //   name: 'purchase',
      //   builder: (context, state) {
      //     final productId = state.extra as String?;
      //     return PurchaseScreen(productId: productId);
      //   },
      // ),

      // Point Exchange Routes
      GoRoute(
        path: RouteNames.points,
        name: 'points',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: PointExchangeMainScreen(userPoint: 0), // TODO: 실제 포인트 전달
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        // 인증 가드 예시
        redirect: (context, state) {
          // TODO: 인증 상태 체크 후 미인증시 로그인으로 리다이렉트
          return null;
        },
      ),
      GoRoute(
        path: RouteNames.pointsCatalog,
        name: 'pointsCatalog',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: GiftCardCatalogScreen(userPoint: 0, userEmail: ''), // TODO: 실제 데이터 전달
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
              child: child,
            );
          },
        ),
        redirect: (context, state) {
          // TODO: 인증 상태 체크
          return null;
        },
      ),
      GoRoute(
        path: '/points/detail/:goodsId',
        name: 'pointsDetail',
        pageBuilder: (context, state) {
          final goodsId = state.pathParameters['goodsId']!;
          // TODO: 상품권 상세 화면 구현 및 goodsId 전달
          return CustomTransitionPage(
            key: state.pageKey,
            child: Scaffold(body: Center(child: Text('상품권 상세: $goodsId'))),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
        redirect: (context, state) {
          // TODO: 인증 상태 체크
          return null;
        },
      ),
      GoRoute(
        path: RouteNames.pointsConfirm,
        name: 'pointsConfirm',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: Scaffold(body: Center(child: Text('교환 확인 화면'))),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        redirect: (context, state) {
          // TODO: 인증 상태 체크
          return null;
        },
      ),
      GoRoute(
        path: RouteNames.pointsSuccess,
        name: 'pointsSuccess',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ExchangeSuccessScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(scale: animation, child: child);
          },
        ),
        redirect: (context, state) {
          // TODO: 인증 상태 체크
          return null;
        },
      ),
      GoRoute(
        path: RouteNames.pointsCoupons,
        name: 'pointsCoupons',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: Scaffold(body: Center(child: Text('내 쿠폰함 화면'))),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(animation),
              child: child,
            );
          },
        ),
        redirect: (context, state) {
          // TODO: 인증 상태 체크
          return null;
        },
      ),
      GoRoute(
        path: RouteNames.pointsHistory,
        name: 'pointsHistory',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: Scaffold(body: Center(child: Text('교환 내역 화면'))),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        redirect: (context, state) {
          // TODO: 인증 상태 체크
          return null;
        },
      ),
      GoRoute(
        path: '/points/coupon/:couponId',
        name: 'pointsCouponDetail',
        pageBuilder: (context, state) {
          final couponId = state.pathParameters['couponId']!;
          // TODO: 쿠폰 상세 화면 구현 및 couponId 전달
          return CustomTransitionPage(
            key: state.pageKey,
            child: Scaffold(body: Center(child: Text('쿠폰 상세: $couponId'))),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
        redirect: (context, state) {
          // TODO: 인증 상태 체크
          return null;
        },
      ),

      // Settings Routes
      // GoRoute(
      //   path: RouteNames.settings,
      //   name: 'settings',
      //   builder: (context, state) => const SettingsScreen(),
      // ),
      // GoRoute(
      //   path: RouteNames.notificationSettings,
      //   name: 'notificationSettings',
      //   builder: (context, state) => const NotificationSettingsScreen(),
      // ),
      // GoRoute(
      //   path: RouteNames.blockList,
      //   name: 'blockList',
      //   builder: (context, state) => const BlockListScreen(),
      // ),
      // GoRoute(
      //   path: RouteNames.accountSettings,
      //   name: 'accountSettings',
      //   builder: (context, state) => const AccountSettingsScreen(),
      // ),

      // Support Routes
      // GoRoute(
      //   path: RouteNames.inquiry,
      //   name: 'inquiry',
      //   builder: (context, state) => const InquiryScreen(),
      // ),
      GoRoute(
        path: RouteNames.faq,
        name: 'faq',
        builder: (context, state) => const FaqListScreen(),
      ),
      GoRoute(
        path: RouteNames.notice,
        name: 'notice',
        builder: (context, state) => const NoticeListScreen(),
      ),
      GoRoute(
        path: '${RouteNames.noticeDetail}/:noticeId',
        name: 'noticeDetail',
        builder: (context, state) {
          final noticeId = state.pathParameters['noticeId']!;
          return NoticeDetailScreen(noticeId: noticeId);
        },
      ),
      GoRoute(
        path: RouteNames.privacy,
        name: 'privacy',
        builder: (context, state) => const PrivacyListScreen(),
      ),

      // Admin Routes
      ...AdminRouter.adminRoutes,

      // Error Routes
      // GoRoute(
      //   path: RouteNames.maintenance,
      //   name: 'maintenance',
      //   builder: (context, state) => const MaintenanceScreen(),
      // ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) {
      // 관리자 페이지 인증 제거됨 - 모든 라우트 접근 허용
      return null;
    },
  );
});


// Navigation Extensions for easy navigation
extension AppRouterExtension on GoRouter {
  // Auth Navigation
  void goToLogin() => go(RouteNames.login);
  void goToSignup() => go(RouteNames.signup);
  void goToTerms() => go(RouteNames.terms);
  void goToPhoneVerification(Map<String, dynamic>? agreedTerms) {
    go(RouteNames.phoneVerification, extra: agreedTerms);
  }
  void goToSignupComplete() => go(RouteNames.signupComplete);

  // Onboarding Navigation
  void goToOnboardingTutorial() => go(RouteNames.onboardingTutorial);
  void goToProfileSetup() => go(RouteNames.profileSetup);

  // Main App Navigation
  void goToHome() => go(RouteNames.home);
  void goToLikes() => go(RouteNames.likes);
  void goToVip() => go(RouteNames.vip);
  void goToChat() => go(RouteNames.chat);
  void goToProfile() => go(RouteNames.profile);

  // Chat Navigation
  void goToChatRoom(String chatId, {String? userName}) {
    final uri = Uri(
      path: '${RouteNames.chatRoom}/$chatId',
      queryParameters: userName != null ? {'userName': userName} : null,
    );
    go(uri.toString());
  }

  // Profile Navigation
  void goToOtherProfile(String userId) {
    go('${RouteNames.otherProfile}/$userId');
  }
  void goToEditProfile() => go(RouteNames.editProfile);

  // Settings Navigation
  void goToSettings() => go(RouteNames.settings);
  void goToNotificationSettings() => go(RouteNames.notificationSettings);
  
  // Point Navigation
  void goToPointShop() => go(RouteNames.pointShop);
  void goToPurchase({String? productId}) {
    go(RouteNames.purchase, extra: productId);
  }
}