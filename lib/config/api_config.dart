class ApiConfig {
  // AWS API Gateway 기본 URL
  static const String baseUrl = 'https://ek5h8mq0mf.execute-api.ap-northeast-2.amazonaws.com/prod';
  
  // API 엔드포인트들
  static const String likesEndpoint = '/likes';
  static const String superchatEndpoint = '/superchat';
  static const String notificationsEndpoint = '/notifications';
  static const String profilesEndpoint = '/profiles';
  static const String matchesEndpoint = '/matches';
  
  // 타임아웃 설정
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // 알림 폴링 간격
  static const Duration notificationPollingInterval = Duration(seconds: 30);
  
  // AWS 리전
  static const String awsRegion = 'ap-northeast-2';
  
  // DynamoDB 테이블 이름들
  static const String superchatTableName = 'Superchats';
  static const String likesTableName = 'Likes';
  static const String matchesTableName = 'Matches';
  static const String notificationsTableName = 'Notifications';
  static const String userPointsTableName = 'UserPoints';
  static const String pointsHistoryTableName = 'PointsHistory';
}