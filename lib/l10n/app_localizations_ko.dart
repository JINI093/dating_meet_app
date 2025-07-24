import 'app_localizations.dart';

/// The translations for Korean (`ko`).
class SKo extends S {
  SKo([String locale = 'ko']) : super(locale);

  // Common
  @override
  String get appName => '사랑해';

  @override
  String get ok => '확인';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get delete => '삭제';

  @override
  String get edit => '수정';

  @override
  String get save => '저장';

  @override
  String get close => '닫기';

  @override
  String get back => '뒤로';

  @override
  String get next => '다음';

  @override
  String get previous => '이전';

  @override
  String get retry => '다시 시도';

  @override
  String get loading => '로딩 중...';

  @override
  String get error => '오류';

  @override
  String get success => '성공';

  @override
  String get warning => '경고';

  @override
  String get info => '정보';

  // Authentication
  @override
  String get login => '로그인';

  @override
  String get logout => '로그아웃';

  @override
  String get signup => '회원가입';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get phoneNumber => '휴대폰 번호';

  @override
  String get verificationCode => '인증번호';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get resetPassword => '비밀번호 재설정';

  @override
  String get loginWithKakao => '카카오로 로그인';

  @override
  String get loginWithGoogle => '구글로 로그인';

  @override
  String get loginWithApple => '애플로 로그인';

  @override
  String get agreeToTerms => '이용약관에 동의합니다';

  @override
  String get termsOfService => '이용약관';

  @override
  String get privacyPolicy => '개인정보처리방침';

  // Profile
  @override
  String get profile => '프로필';

  @override
  String get editProfile => '프로필 수정';

  @override
  String get name => '이름';

  @override
  String get age => '나이';

  @override
  String get location => '지역';

  @override
  String get occupation => '직업';

  @override
  String get bio => '소개';

  @override
  String get photos => '사진';

  @override
  String get addPhoto => '사진 추가';

  @override
  String get removePhoto => '사진 삭제';

  @override
  String get profileVerification => '프로필 인증';

  @override
  String get verified => '인증됨';

  @override
  String get notVerified => '미인증';

  // Home & Matching
  @override
  String get home => '홈';

  @override
  String get matching => '매칭';

  @override
  String get filter => '필터';

  @override
  String get distance => '거리';

  @override
  String get region => '지역';

  @override
  String get popularity => '인기도';

  @override
  String get vipFilter => 'VIP 필터';

  @override
  String get like => '좋아요';

  @override
  String get pass => '패스';

  @override
  String get superChat => '슈퍼챗';

  @override
  String get noMoreProfiles => '더 이상 프로필이 없습니다';

  @override
  String get todayRecommendations => '오늘의 추천';

  // Likes
  @override
  String get likes => '좋아요';

  @override
  String get receivedLikes => '받은 좋아요';

  @override
  String get sentLikes => '보낸 좋아요';

  @override
  String get superChats => '슈퍼챗';

  @override
  String get matches => '매치';

  @override
  String get likeYou => '좋아해요';

  @override
  String get youLike => '좋아요';

  // VIP
  @override
  String get vip => 'VIP';

  @override
  String get premium => '프리미엄';

  @override
  String get todayVip => '오늘의 VIP';

  @override
  String get vipPlans => 'VIP 플랜';

  @override
  String get vipBenefits => 'VIP 혜택';

  @override
  String get unlimitedLikes => '무제한 좋아요';

  @override
  String get priorityDisplay => '우선 표시';

  @override
  String get readReceipts => '읽음 표시';

  @override
  String get advancedFilters => '고급 필터';

  // Chat
  @override
  String get chat => '채팅';

  @override
  String get chats => '채팅';

  @override
  String get messages => '메시지';

  @override
  String get typeMessage => '메시지를 입력하세요...';

  @override
  String get sendMessage => '메시지 보내기';

  @override
  String get chatList => '채팅 목록';

  @override
  String get newMatch => '새로운 매치';

  @override
  String get online => '온라인';

  @override
  String get offline => '오프라인';

  @override
  String get lastSeen => '마지막 접속';

  // Points
  @override
  String get points => '포인트';

  @override
  String get pointShop => '포인트 상점';

  @override
  String get pointHistory => '포인트 내역';

  @override
  String get purchasePoints => '포인트 구매';

  @override
  String get currentPoints => '현재 포인트';

  @override
  String get freePoints => '무료 포인트';

  @override
  String get earnPoints => '포인트 적립';

  @override
  String get spendPoints => '포인트 사용';

  // Settings
  @override
  String get settings => '설정';

  @override
  String get notifications => '알림';

  @override
  String get notificationSettings => '알림 설정';

  @override
  String get pushNotifications => '푸시 알림';

  @override
  String get likeNotifications => '좋아요 알림';

  @override
  String get chatNotifications => '채팅 알림';

  @override
  String get matchNotifications => '매치 알림';

  @override
  String get marketingNotifications => '마케팅 알림';

  @override
  String get account => '계정';

  @override
  String get accountSettings => '계정 설정';

  @override
  String get blockList => '차단 목록';

  @override
  String get blockedUsers => '차단된 사용자';

  @override
  String get reportUser => '사용자 신고';

  @override
  String get deleteAccount => '계정 삭제';

  // Support
  @override
  String get support => '고객지원';

  @override
  String get faq => '자주 묻는 질문';

  @override
  String get contactUs => '문의하기';

  @override
  String get inquiry => '문의';

  @override
  String get notice => '공지사항';

  @override
  String get announcements => '공지';

  @override
  String get version => '버전';

  @override
  String get aboutApp => '앱 정보';

  // Validation Messages
  @override
  String get emailRequired => '이메일을 입력해주세요';

  @override
  String get emailInvalid => '올바른 이메일 형식을 입력해주세요';

  @override
  String get passwordRequired => '비밀번호를 입력해주세요';

  @override
  String get passwordTooShort => '비밀번호는 8자 이상이어야 합니다';

  @override
  String get passwordMismatch => '비밀번호가 일치하지 않습니다';

  @override
  String get phoneRequired => '휴대폰 번호를 입력해주세요';

  @override
  String get phoneInvalid => '올바른 휴대폰 번호를 입력해주세요';

  @override
  String get nameRequired => '이름을 입력해주세요';

  @override
  String get ageRequired => '나이를 입력해주세요';

  @override
  String get locationRequired => '지역을 선택해주세요';

  // Error Messages
  @override
  String get networkError => '네트워크 오류가 발생했습니다';

  @override
  String get serverError => '서버 오류가 발생했습니다';

  @override
  String get unknownError => '알 수 없는 오류가 발생했습니다';

  @override
  String get timeoutError => '요청 시간이 초과되었습니다';

  @override
  String get unauthorizedError => '인증이 필요합니다';

  @override
  String get forbiddenError => '접근이 거부되었습니다';

  @override
  String get notFoundError => '요청한 리소스를 찾을 수 없습니다';

  // Success Messages
  @override
  String get loginSuccess => '로그인되었습니다';

  @override
  String get signupSuccess => '회원가입이 완료되었습니다';

  @override
  String get profileUpdateSuccess => '프로필이 업데이트되었습니다';

  @override
  String get likeSuccess => '좋아요를 보냈습니다';

  @override
  String get superChatSuccess => '슈퍼챗을 보냈습니다';

  @override
  String get messageSuccess => '메시지를 보냈습니다';

  // Action Messages
  @override
  String get confirmDelete => '정말 삭제하시겠습니까?';

  @override
  String get confirmLogout => '정말 로그아웃하시겠습니까?';

  @override
  String get confirmBlock => '정말 이 사용자를 차단하시겠습니까?';

  @override
  String get confirmReport => '정말 이 사용자를 신고하시겠습니까?';

  @override
  String get areYouSure => '정말로 하시겠습니까?';

  @override
  String get cannotUndo => '이 작업은 되돌릴 수 없습니다';

  // Date & Time
  @override
  String get today => '오늘';

  @override
  String get yesterday => '어제';

  @override
  String get thisWeek => '이번 주';

  @override
  String get thisMonth => '이번 달';

  @override
  String get ago => '전';

  @override
  String get justNow => '방금 전';

  @override
  String get minutesAgo => '분 전';

  @override
  String get hoursAgo => '시간 전';

  @override
  String get daysAgo => '일 전';

  // Units
  @override
  String get km => 'km';

  @override
  String get years => '년';

  @override
  String get yearsOld => '세';
}