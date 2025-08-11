class RouteNames {
  RouteNames._();

  // Splash
  static const String splash = '/';

  // Authentication
  static const String login = '/login';
  static const String enhancedLogin = '/enhanced-login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String accountRecovery = '/account-recovery';
  static const String findId = '/find-id';
  static const String resetPassword = '/reset-password';
  static const String terms = '/terms';
  static const String phoneVerification = '/phone-verification';
  static const String signupComplete = '/signup-complete';

  // Onboarding
  static const String intro = '/intro';
  static const String onboardingTutorial = '/onboarding-tutorial';
  static const String profileSetup = '/profile-setup';
  static const String profileComplete = '/profile-complete';

  // Main App (Bottom Navigation)
  static const String home = '/home';
  static const String likes = '/likes';
  static const String vip = '/vip';
  static const String chat = '/chat';
  static const String profile = '/profile';

  // Home Sub-routes
  static const String matching = '/home/matching';

  // Likes Sub-routes
  static const String receivedLikes = '/likes/received';
  static const String sentLikes = '/likes/sent';
  static const String superChat = '/likes/super-chat';

  // VIP Sub-routes
  static const String vipToday = '/vip/today';
  static const String vipPlans = '/vip/plans';
  static const String vipMembership = '/vip/membership';
  static const String vipPurchase = '/vip/purchase';

  // Chat Routes
  static const String chatRoom = '/chat-room';

  // Profile Routes
  static const String editProfile = '/edit-profile';
  static const String otherProfile = '/other-profile';
  static const String profileVerification = '/profile-verification';

  // Point Routes
  static const String pointShop = '/point-shop';
  static const String pointHistory = '/point-history';
  static const String purchase = '/purchase';
  static const String pointSettings = '/point-settings';
  static const String withdrawal = '/withdrawal';

  // Point Exchange Routes
  static const String points = '/points';
  static const String pointsCatalog = '/points/catalog';
  static const String pointsDetail = '/points/detail/:goodsId';
  static const String pointsConfirm = '/points/confirm';
  static const String pointsSuccess = '/points/success';
  static const String pointsCoupons = '/points/coupons';
  static const String pointsHistory = '/points/history';
  static const String pointsCouponDetail = '/points/coupon/:couponId';

  // Notifications Routes
  static const String notifications = '/notifications';

  // Settings Routes
  static const String settings = '/settings';
  static const String notificationSettings = '/notification-settings';
  static const String blockList = '/block-list';
  static const String accountSettings = '/account-settings';

  // Support Routes
  static const String inquiry = '/inquiry';
  static const String faq = '/faq';
  static const String notice = '/notice';
  static const String noticeDetail = '/notice-detail';
  static const String privacy = '/privacy';

  // User Management Routes (Admin)
  static const String userList = '/user-list';
  static const String userDetail = '/user-detail';

  // Ticket Routes
  static const String ticketSettings = '/ticket-settings';

  // Error Routes
  static const String notFound = '/404';
  static const String maintenance = '/maintenance';

  // Route Groups for easy management
  static const List<String> authRoutes = [
    login,
    enhancedLogin,
    signup,
    forgotPassword,
    accountRecovery,
    findId,
    resetPassword,
    terms,
    phoneVerification,
    signupComplete,
  ];

  static const List<String> onboardingRoutes = [
    intro,
    onboardingTutorial,
    profileSetup,
    profileComplete,
  ];

  static const List<String> mainAppRoutes = [
    home,
    likes,
    vip,
    chat,
    profile,
  ];

  static const List<String> profileRoutes = [
    editProfile,
    otherProfile,
    profileVerification,
  ];

  static const List<String> pointRoutes = [
    pointShop,
    pointHistory,
    purchase,
    pointSettings,
    withdrawal,
  ];

  static const List<String> settingsRoutes = [
    settings,
    notificationSettings,
    blockList,
    accountSettings,
  ];

  static const List<String> supportRoutes = [
    inquiry,
    faq,
    notice,
    noticeDetail,
    privacy,
  ];

  static const List<String> adminRoutes = [
    userList,
    userDetail,
    ticketSettings,
  ];

  static const List<String> publicRoutes = [
    splash,
    maintenance,
    notFound,
  ];

  // Route path helpers
  static String getChatRoomPath(String chatId) => '$chatRoom/$chatId';
  static String getOtherProfilePath(String userId) => '$otherProfile/$userId';
  static String getNoticeDetailPath(String noticeId) => '$noticeDetail/$noticeId';
  static String getUserDetailPath(String userId) => '$userDetail/$userId';

  // Query parameter helpers
  static String getChatRoomWithUser(String chatId, String userName) =>
      '$chatRoom/$chatId?userName=$userName';
  
  static String getProfileWithAction(String userId, String action) =>
      '$otherProfile/$userId?action=$action';

  // Route validation helpers
  static bool isAuthRoute(String route) => authRoutes.contains(route);
  static bool isOnboardingRoute(String route) => onboardingRoutes.contains(route);
  static bool isMainAppRoute(String route) => mainAppRoutes.contains(route);
  static bool isProfileRoute(String route) => profileRoutes.contains(route);
  static bool isPointRoute(String route) => pointRoutes.contains(route);
  static bool isSettingsRoute(String route) => settingsRoutes.contains(route);
  static bool isSupportRoute(String route) => supportRoutes.contains(route);
  static bool isAdminRoute(String route) => adminRoutes.contains(route);
  static bool isPublicRoute(String route) => publicRoutes.contains(route);
  
  static bool isProtectedRoute(String route) => 
      !authRoutes.contains(route) && 
      !publicRoutes.contains(route);

  static bool requiresAuth(String route) =>
      isMainAppRoute(route) ||
      isProfileRoute(route) ||
      isPointRoute(route) ||
      isSettingsRoute(route) ||
      isSupportRoute(route) ||
      isAdminRoute(route);

  static bool requiresOnboarding(String route) =>
      requiresAuth(route) && !isOnboardingRoute(route);

  // Route group getters
  static List<String> get allRoutes => [
    ...authRoutes,
    ...onboardingRoutes,
    ...mainAppRoutes,
    ...profileRoutes,
    ...pointRoutes,
    ...settingsRoutes,
    ...supportRoutes,
    ...adminRoutes,
    ...publicRoutes,
  ];

  static List<String> get bottomNavigationRoutes => [
    home,
    likes,
    vip,
    chat,
    profile,
  ];

  // Route metadata
  static Map<String, String> get routeTitles => {
    splash: '스플래시',
    login: '로그인',
    enhancedLogin: '향상된 로그인',
    signup: '회원가입',
    forgotPassword: 'ID/PW 찾기',
    accountRecovery: '계정 복구',
    findId: '아이디 찾기',
    resetPassword: '비밀번호 찾기',
    terms: '이용약관',
    phoneVerification: '본인인증',
    signupComplete: '가입완료',
    intro: '앱소개',
    onboardingTutorial: '온보딩 튜토리얼',
    profileSetup: '프로필설정',
    profileComplete: '프로필완료',
    home: '홈',
    likes: '좋아요',
    vip: 'VIP',
    chat: '채팅',
    profile: '프로필',
    matching: '매칭',
    receivedLikes: '받은 좋아요',
    sentLikes: '보낸 좋아요',
    superChat: '슈퍼챗',
    vipToday: '오늘의 VIP',
    vipPlans: 'VIP 플랜',
    vipMembership: 'VIP 이용권',
    vipPurchase: 'VIP 구매',
    chatRoom: '채팅방',
    editProfile: '프로필 수정',
    otherProfile: '프로필 보기',
    profileVerification: '프로필 인증',
    pointShop: '포인트 상점',
    pointHistory: '포인트 내역',
    purchase: '결제',
    pointSettings: '포인트 설정',
    withdrawal: '출금',
    settings: '설정',
    notificationSettings: '알림 설정',
    blockList: '차단 목록',
    accountSettings: '계정 설정',
    inquiry: '문의하기',
    faq: '자주 묻는 질문',
    notice: '공지사항',
    noticeDetail: '공지사항 상세',
    privacy: '개인정보처리방침',
    notifications: '알림',
    userList: '사용자 목록',
    userDetail: '사용자 상세',
    ticketSettings: '티켓 설정',
    notFound: '페이지를 찾을 수 없음',
    maintenance: '서비스 점검',
  };
}
