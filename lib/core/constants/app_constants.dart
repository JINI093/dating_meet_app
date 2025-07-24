class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = '40대 데이팅';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // App Store & Play Store
  static const String iosAppId = '';
  static const String androidPackageName = 'com.dating.app40s';

  // Social Login App IDs
  static const String kakaoAppKey = '';
  static const String googleClientId = '';
  static const String appleServiceId = '';

  // Deep Link Scheme
  static const String deepLinkScheme = 'dating40s';

  // API Configuration
  static const String baseUrl = 'https://api.dating40s.com';
  static const String apiVersion = 'v1';
  static const int connectTimeout = 30000; // 30초
  static const int receiveTimeout = 30000; // 30초

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String isOnboardedKey = 'is_onboarded';
  static const String selectedLanguageKey = 'selected_language';
  static const String notificationEnabledKey = 'notification_enabled';
  static const String locationPermissionKey = 'location_permission';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const int imageQuality = 85;

  // Profile Configuration
  static const int maxProfileImages = 6;
  static const int minAge = 40;
  static const int maxAge = 65;
  static const int defaultSearchRadius = 50; // km
  static const int maxSearchRadius = 200; // km

  // Chat Configuration
  static const int maxChatMessageLength = 1000;
  static const int maxChatImageSize = 3 * 1024 * 1024; // 3MB

  // Point System
  static const int freePointsPerDay = 5;
  static const int superChatCost = 10;
  static const int profileBoostCost = 20;
  static const int unlimitedLikesCost = 50;

  // VIP Plans
  static const int vipMonthlyPrice = 29900; // 원
  static const int vipYearlyPrice = 299000; // 원
  static const int premiumMonthlyPrice = 49900; // 원
  static const int premiumYearlyPrice = 499000; // 원

  // Notification Types
  static const String notificationTypeLike = 'like';
  static const String notificationTypeSuperChat = 'super_chat';
  static const String notificationTypeMatch = 'match';
  static const String notificationTypeMessage = 'message';
  static const String notificationTypeVip = 'vip';

  // Error Messages
  static const String networkErrorMessage = '네트워크 연결을 확인해주세요.';
  static const String serverErrorMessage = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
  static const String unknownErrorMessage = '알 수 없는 오류가 발생했습니다.';
  static const String timeoutErrorMessage = '요청 시간이 초과되었습니다.';
  static const String unauthorizedErrorMessage = '로그인이 필요합니다.';
  static const String forbiddenErrorMessage = '접근 권한이 없습니다.';
  static const String notFoundErrorMessage = '요청한 리소스를 찾을 수 없습니다.';

  // Success Messages
  static const String loginSuccessMessage = '로그인되었습니다.';
  static const String signupSuccessMessage = '회원가입이 완료되었습니다.';
  static const String profileUpdateSuccessMessage = '프로필이 업데이트되었습니다.';
  static const String likeSuccessMessage = '좋아요를 보냈습니다.';
  static const String superChatSuccessMessage = '슈퍼챗을 보냈습니다.';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 20;
  static const int minNicknameLength = 2;
  static const int maxNicknameLength = 12;
  static const int maxBioLength = 500;

  // Regular Expressions
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^01[0-9]{8,9}$';
  static const String passwordRegex = r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]';

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'yyyy년 MM월 dd일';
  static const String displayTimeFormat = 'a HH:mm';

  // URLs
  static const String termsOfServiceUrl = 'https://dating40s.com/terms';
  static const String privacyPolicyUrl = 'https://dating40s.com/privacy';
  static const String supportUrl = 'https://dating40s.com/support';
  static const String faqUrl = 'https://dating40s.com/faq';

  // Contact Information
  static const String supportEmail = 'support@dating40s.com';
  static const String supportPhone = '1588-0000';

  // Social Media
  static const String instagramUrl = 'https://instagram.com/dating40s';
  static const String facebookUrl = 'https://facebook.com/dating40s';
  static const String blogUrl = 'https://blog.dating40s.com';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String likesCollection = 'likes';
  static const String reportsCollection = 'reports';
  static const String notificationsCollection = 'notifications';

  // Shared Preferences Keys for Settings
  static const String pushNotificationKey = 'push_notification';
  static const String likeNotificationKey = 'like_notification';
  static const String chatNotificationKey = 'chat_notification';
  static const String matchNotificationKey = 'match_notification';
  static const String marketingNotificationKey = 'marketing_notification';

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Debounce Durations
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration apiDebounce = Duration(milliseconds: 1000);

  // Cache Durations
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration mediumCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(days: 1);

  // Location
  static const List<String> koreanCities = [
    '서울특별시',
    '부산광역시',
    '대구광역시',
    '인천광역시',
    '광주광역시',
    '대전광역시',
    '울산광역시',
    '세종특별자치시',
    '경기도',
    '강원도',
    '충청북도',
    '충청남도',
    '전라북도',
    '전라남도',
    '경상북도',
    '경상남도',
    '제주특별자치도',
  ];

  // Occupation Categories
  static const List<String> occupationCategories = [
    '경영/사무',
    '영업/마케팅',
    'IT/개발',
    '디자인',
    '미디어',
    '전문직',
    '의료/보건',
    '교육',
    '공무원',
    '금융/보험',
    '서비스업',
    '생산/제조',
    '건설',
    '유통/무역',
    '자영업',
    '기타',
  ];

  // Education Levels
  static const List<String> educationLevels = [
    '고등학교 졸업',
    '전문대 졸업',
    '대학교 졸업',
    '대학원 졸업',
    '기타',
  ];

  // Smoking Status
  static const List<String> smokingStatus = [
    '비흡연',
    '가끔',
    '흡연',
  ];

  // Drinking Status
  static const List<String> drinkingStatus = [
    '전혀 마시지 않음',
    '가끔',
    '자주',
    '매일',
  ];

  // Religion
  static const List<String> religions = [
    '무교',
    '기독교',
    '천주교',
    '불교',
    '이슬람교',
    '기타',
  ];

  // Body Types
  static const List<String> bodyTypes = [
    '슬림',
    '보통',
    '통통',
    '근육질',
  ];

  // MBTI Types
  static const List<String> mbtiTypes = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP',
  ];

  // Hobbies List
  static const List<String> hobbiesList = [
    '영화/드라마',
    '음악',
    '독서',
    '요리',
    '운동/헬스',
    '등산',
    '여행',
    '사진',
    '게임',
    '춤',
    '악기 연주',
    '그림/미술',
    '카페 투어',
    '맛집 탐방',
    '쇼핑',
    '산책',
    '자전거',
    '수영',
    '골프',
    '테니스',
    '볼링',
    '낚시',
    '캠핑',
    '원예/가드닝',
    '반려동물',
    '봉사활동',
    '스터디',
    '어학공부',
    '투자/재테크',
    '와인',
    '커피',
    '베이킹',
    '공예',
    '종교활동',
    '명상/요가',
  ];

  // Meeting Types
  static const List<String> meetingTypes = [
    '건전한 만남',
    '가벼운 만남',
    '좋은 기회',
  ];

  /// 시/도, 구/군 지역 상수
  static const Map<String, List<String>> kRegions = {
    '서울': [
      '강남구', '강동구', '강북구', '강서구', '관악구', '광진구', '구로구', '금천구', '노원구', '도봉구', '동대문구', '동작구', '마포구', '서대문구', '서초구', '성동구', '성북구', '송파구', '양천구', '영등포구', '용산구', '은평구', '종로구', '중구', '중랑구',
    ],
    '경기': [
      '수원시', '성남시', '고양시', '용인시', '부천시', '안산시', '안양시', '남양주시', '화성시', '평택시', '의정부시', '시흥시', '파주시', '광명시', '김포시', '군포시', '광주시', '하남시', '오산시', '이천시', '안성시', '의왕시', '여주시', '양평군', '동두천시', '과천시', '가평군', '연천군',
    ],
    '인천': [
      '계양구', '남동구', '동구', '미추홀구', '부평구', '서구', '연수구', '중구', '강화군', '옹진군',
    ],
    '대전': [
      '대덕구', '동구', '서구', '유성구', '중구',
    ],
    '세종': [
      '세종시',
    ],
    '충남': [
      '계룡시', '공주시', '금산군', '논산시', '당진시', '보령시', '부여군', '서산시', '서천군', '아산시', '연기군', '예산군', '천안시', '청양군', '태안군', '홍성군',
    ],
    '충북': [
      '괴산군', '단양군', '보은군', '영동군', '옥천군', '음성군', '제천시', '증평군', '진천군', '청원군', '청주시', '충주시',
    ],
    // ... 필요시 추가 ...
  };
}