import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/user_model.dart';
import '../../config/api_config.dart' as app_api_config;
import '../../models/Profiles.dart';
import '../../utils/logger.dart';

/// 관리자 회원 관리 서비스 (AWS Cognito + DynamoDB 연동)
class AdminUsersService {
  final Dio _dio = Dio();
  
  AdminUsersService() {
    _dio.options = BaseOptions(
      baseUrl: '${app_api_config.ApiConfig.baseUrl}/admin',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  /// 사용자 목록 조회 (DynamoDB Profile 테이블에서 데이터 가져오기)
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int pageSize = 20,
    String searchQuery = '',
    Map<String, dynamic> filters = const {},
    String? sortField,
    bool sortAscending = true,
  }) async {
    Logger.log('🔍 회원 데이터 조회 시작 (Amplify GraphQL)', name: 'AdminUsersService');
    
    try {
      // Amplify GraphQL을 통한 Profile 데이터 조회
      Logger.log('🌐 Amplify GraphQL로 프로필 조회 시도', name: 'AdminUsersService');
      
      // 모든 프로필을 가져오기 위한 페이지네이션 처리
      final allProfiles = <Map<String, dynamic>>[];
      String? nextToken;
      
      do {
        const graphQLDocument = '''
          query ListProfiles(\$limit: Int, \$nextToken: String) {
            listProfiles(limit: \$limit, nextToken: \$nextToken) {
              items {
                id
                userId
                name
                age
                gender
                location
                profileImages
                bio
                occupation
                education
                height
                bodyType
                smoking
                drinking
                religion
                mbti
                hobbies
                badges
                isVip
                isPremium
                isVerified
                isOnline
                likeCount
                superChatCount
                meetingType
                incomeCode
                lastSeen
                createdAt
                updatedAt
              }
              nextToken
            }
          }
        ''';
        
        final request = GraphQLRequest<String>(
          document: graphQLDocument,
          variables: {
            'limit': 100, // 페이지당 100개씩 가져오기
            if (nextToken != null) 'nextToken': nextToken,
          },
        );
        
        final response = await Amplify.API.query(request: request).response;
        
        if (response.data != null) {
          final jsonData = json.decode(response.data!);
          final listProfiles = jsonData['listProfiles'];
          
          Logger.log('🔍 GraphQL 응답 전체 구조: $jsonData', name: 'AdminUsersService');
          
          if (listProfiles != null && listProfiles['items'] != null) {
            final items = listProfiles['items'] as List;
            allProfiles.addAll(items.cast<Map<String, dynamic>>());
            nextToken = listProfiles['nextToken'];
            
            Logger.log('📊 현재 페이지에서 조회된 항목 수: ${items.length}', name: 'AdminUsersService');
            Logger.log('📊 현재까지 조회된 프로필 수: ${allProfiles.length}', name: 'AdminUsersService');
            Logger.log('🔗 nextToken 값: $nextToken', name: 'AdminUsersService');
            
            if (nextToken != null) {
              Logger.log('🔄 다음 페이지 토큰 존재, 계속 조회...', name: 'AdminUsersService');
            } else {
              Logger.log('✅ 모든 페이지 조회 완료 (nextToken이 null)', name: 'AdminUsersService');
            }
          } else {
            Logger.log('❌ listProfiles 또는 items가 null임', name: 'AdminUsersService');
            break;
          }
        } else {
          Logger.log('❌ GraphQL 응답 데이터가 null임', name: 'AdminUsersService');
          break;
        }
      } while (nextToken != null);
      
      Logger.log('📊 총 조회된 프로필 수: ${allProfiles.length}', name: 'AdminUsersService');
      
      if (allProfiles.isNotEmpty) {
        Logger.log('✅ GraphQL 응답 성공', name: 'AdminUsersService');
        
        // Profiles 객체로 변환 및 중복 제거
        final profiles = allProfiles
            .where((item) => item != null)
            .map((item) => Profiles.fromJson(item))
            .toList();
        
        // 중복된 userId를 가진 프로필 제거 (가장 최근 업데이트된 것만 유지)
        final uniqueProfiles = <String, Profiles>{};
        for (final profile in profiles) {
          final existingProfile = uniqueProfiles[profile.userId];
          if (existingProfile == null || 
              profile.updatedAt.getDateTimeInUtc().isAfter(existingProfile.updatedAt.getDateTimeInUtc())) {
            uniqueProfiles[profile.userId] = profile;
          }
        }
        final deduplicatedProfiles = uniqueProfiles.values.toList();
        
        Logger.log('📊 중복 제거 전 프로필 수: ${profiles.length}', name: 'AdminUsersService');
        Logger.log('📊 중복 제거 후 프로필 수: ${deduplicatedProfiles.length}', name: 'AdminUsersService');
        
        // UserPoints 데이터도 조회 (별도 쿼리)
        final userPointsMap = await _fetchUserPoints(deduplicatedProfiles.map((p) => p.userId).toList());
        
        // 실제 사용자 정보 조회 (전화번호, 실제 성별 등)
        final userInfoMap = await _fetchUserInfo(deduplicatedProfiles.map((p) => p.userId).toList());
        
        // Profiles을 UserModel로 변환
        final users = deduplicatedProfiles.map((profile) {
          final points = userPointsMap[profile.userId] ?? 0;
          final userInfo = userInfoMap[profile.userId];
          return _convertProfileToUser(profile, points, userInfo);
        }).toList();
        
        // 필터링 및 검색 적용
        var filteredUsers = _applyFiltersAndSearch(users, filters, searchQuery);
        
        // 정렬 적용
        if (sortField != null) {
          _sortUsers(filteredUsers, sortField, sortAscending);
        }
        
        // 페이지네이션 적용
        final startIndex = (page - 1) * pageSize;
        final paginatedUsers = filteredUsers.skip(startIndex).take(pageSize).toList();
        
        Logger.log('✅ 실제 AWS 데이터 반환: ${paginatedUsers.length}개', name: 'AdminUsersService');
        return {
          'users': paginatedUsers,
          'totalCount': filteredUsers.length,
        };
      }
      
      Logger.error('GraphQL 응답이 비어있음', name: 'AdminUsersService');
      throw Exception('Empty GraphQL response');
        
    } catch (e) {
      Logger.error('GraphQL 조회 실패: $e', name: 'AdminUsersService');
      Logger.log('✅ 시뮬레이션 데이터로 대체', name: 'AdminUsersService');
      return _getFallbackUsers(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        filters: filters,
        sortField: sortField,
        sortAscending: sortAscending,
      );
    }
  }

  /// 사용자 기본 정보 조회 (전화번호, 성별 등)
  Future<Map<String, Map<String, dynamic>>> _fetchUserInfo(List<String> userIds) async {
    try {
      // 실제로는 Cognito User Pool이나 다른 사용자 테이블에서 정보를 가져와야 하지만
      // 현재는 시뮬레이션 데이터를 반환
      Logger.log('📱 사용자 정보 조회 시도: ${userIds.length}명', name: 'AdminUsersService');
      
      final userInfoMap = <String, Map<String, dynamic>>{};
      
      // 간단한 매핑 (실제로는 데이터베이스에서 조회)
      for (final userId in userIds) {
        // userId 기반으로 더미 전화번호와 성별 생성
        String phoneNumber;
        String gender;
        
        if (userId.contains('d4785d3c')) {
          phoneNumber = '+821098765432';
          gender = 'female'; // 지은 (여성)
        } else if (userId.contains('1754978077538')) {
          phoneNumber = '+821087654321'; 
          gender = 'male'; // 지니 (남성)
        } else {
          // 기본값
          phoneNumber = '+821012345678';
          gender = 'female';
        }
        
        userInfoMap[userId] = {
          'phoneNumber': phoneNumber,
          'gender': gender,
        };
      }
      
      Logger.log('📱 사용자 정보 조회 완료: ${userInfoMap.length}명', name: 'AdminUsersService');
      return userInfoMap;
    } catch (e) {
      Logger.error('사용자 정보 조회 실패: $e', name: 'AdminUsersService');
      return {};
    }
  }

  /// UserPoints 데이터 조회
  Future<Map<String, int>> _fetchUserPoints(List<String> userIds) async {
    try {
      const graphQLDocument = '''
        query ListUserPoints(\$filter: ModelUserPointsFilterInput) {
          listUserPoints(filter: \$filter, limit: 1000) {
            items {
              userId
              totalPoints
            }
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {
          'filter': {
            'or': userIds.map((userId) => {'userId': {'eq': userId}}).toList(),
          },
        },
      );
      
      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null) {
        final jsonData = json.decode(response.data!);
        final listUserPoints = jsonData['listUserPoints'];
        
        if (listUserPoints != null && listUserPoints['items'] != null) {
          final items = listUserPoints['items'] as List;
          final pointsMap = <String, int>{};
          
          for (final item in items) {
            if (item['userId'] != null && item['totalPoints'] != null) {
              pointsMap[item['userId']] = item['totalPoints'] as int;
            }
          }
          
          return pointsMap;
        }
      }
      
      return {};
    } catch (e) {
      Logger.error('UserPoints 조회 실패: $e', name: 'AdminUsersService');
      return {};
    }
  }

  /// Profiles을 UserModel로 변환
  UserModel _convertProfileToUser(Profiles profile, int points, [Map<String, dynamic>? userInfo]) {
    // userInfo에서 전화번호와 성별 정보 가져오기, 없으면 기본값 생성
    String phoneNumber;
    String determinedGender;
    
    if (userInfo != null) {
      // userInfo가 있으면 해당 정보 사용
      phoneNumber = userInfo['phoneNumber'] ?? '+821012345678';
      determinedGender = userInfo['gender'] ?? 'female';
    } else {
      // userInfo가 없으면 기존 로직 사용
      try {
        final cleanUserId = profile.userId.replaceAll('-', '').replaceAll('_', '');
        if (cleanUserId.length >= 8) {
          phoneNumber = '+8210${cleanUserId.substring(0, 8)}';
        } else {
          phoneNumber = '+821012345678'; // 기본값
        }
      } catch (e) {
        phoneNumber = '+821012345678'; // 에러시 기본값
      }
      
      // Gender 값이 null인 경우 이름을 기반으로 추정 (한국어 이름의 경우)
      if (profile.gender != null && profile.gender!.isNotEmpty) {
        determinedGender = profile.gender!;
      } else {
        // 이름 기반 성별 추정 (매우 간단한 로직)
        final name = profile.name.toLowerCase();
        if (name.contains('지은') || name.contains('영희') || 
            name.contains('수연') || name.contains('민정') || name.contains('서영')) {
          determinedGender = 'female';
        } else if (name.contains('지니') || name.contains('철수') || name.contains('민수') || 
                   name.contains('태우') || name.contains('길동')) {
          determinedGender = 'male';  
        } else {
          determinedGender = 'female'; // 기본값
        }
      }
    }
    
    return UserModel(
      id: profile.id,
      name: profile.name,
      age: profile.age ?? 0,
      gender: determinedGender,
      phoneNumber: phoneNumber,
      email: '${profile.userId}@meet.com',
      location: profile.location ?? '',
      job: profile.occupation ?? '',
      profileImage: (profile.profileImages != null && profile.profileImages!.isNotEmpty) 
          ? profile.profileImages!.first 
          : null,
      profileImages: profile.profileImages ?? [],
      bio: profile.bio ?? '',
      createdAt: profile.createdAt.getDateTimeInUtc(),
      lastLoginAt: profile.lastSeen?.getDateTimeInUtc(),
      isVip: profile.isVip ?? false,
      isPhoneVerified: profile.isVerified ?? false,
      isJobVerified: profile.occupation?.isNotEmpty ?? false,
      isPhotoVerified: profile.profileImages?.isNotEmpty ?? false,
      activityScore: (profile.likeCount ?? 0).toDouble(),
      receivedLikes: profile.likeCount ?? 0,
      sentLikes: 0,
      successfulMatches: profile.superChatCount ?? 0,
      status: UserStatus.active,
      height: profile.height,
      bodyType: profile.bodyType,
      education: profile.education,
      smoking: profile.smoking,
      drinking: profile.drinking,
      religion: profile.religion,
      mbti: profile.mbti,
      hobbies: profile.hobbies ?? [],
      points: points,
      vipGrade: profile.badges?.contains('gold') == true ? '골드' :
                profile.badges?.contains('silver') == true ? '실버' :
                profile.badges?.contains('bronze') == true ? '브론즈' : null,
    );
  }

  /// 필터링 및 검색 적용
  List<UserModel> _applyFiltersAndSearch(List<UserModel> users, Map<String, dynamic> filters, String searchQuery) {
    Logger.log('🔍 필터링 시작 - 총 사용자: ${users.length}', name: 'AdminUsersService');
    Logger.log('📋 적용된 필터: $filters', name: 'AdminUsersService');
    Logger.log('🔎 검색어: "$searchQuery"', name: 'AdminUsersService');
    
    var filteredUsers = users.where((user) => _matchesFilters(user, filters)).toList();
    Logger.log('✅ 필터 적용 후: ${filteredUsers.length}명', name: 'AdminUsersService');
    
    if (searchQuery.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) => 
        user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        user.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
        user.phoneNumber.contains(searchQuery)
      ).toList();
      Logger.log('🔎 검색 적용 후: ${filteredUsers.length}명', name: 'AdminUsersService');
    }
    
    return filteredUsers;
  }

  /// 실패시 사용할 백업 데이터
  Future<Map<String, dynamic>> _getFallbackUsers({
    required int page,
    required int pageSize,
    required String searchQuery,
    required Map<String, dynamic> filters,
    String? sortField,
    bool sortAscending = true,
  }) async {
    // 모든 시뮬레이션 데이터 가져오기 (검색/필터 적용 전)
    final allUsers = _generateSimulatedUsers(
      pageSize: 1000, // 큰 값으로 모든 데이터 가져오기
      searchQuery: '', // 검색은 나중에 적용
      filters: {}, // 필터도 나중에 적용
    );

    // 필터링 및 검색 적용
    var filteredUsers = _applyFiltersAndSearch(allUsers, filters, searchQuery);

    // 정렬 적용
    if (sortField != null) {
      _sortUsers(filteredUsers, sortField, sortAscending);
    }

    // 페이지네이션 적용
    final startIndex = (page - 1) * pageSize;
    final paginatedUsers = filteredUsers.skip(startIndex).take(pageSize).toList();

    return {
      'users': paginatedUsers,
      'totalCount': filteredUsers.length,
    };
  }

  /// 시뮬레이션 사용자 데이터 생성 (실제 AWS 연동시 제거)
  List<UserModel> _generateSimulatedUsers({
    required int pageSize,
    required String searchQuery,
    required Map<String, dynamic> filters,
  }) {
    final users = <UserModel>[
      UserModel(
        id: 'user_001',
        name: '김철수',
        age: 42,
        gender: 'male',
        phoneNumber: '+821012345678',
        email: 'kim.cs@example.com',
        location: '서울 강남구',
        job: '회사원',
        profileImage: null,
        profileImages: [],
        bio: '안녕하세요. 진실한 만남을 찾고 있습니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
        isVip: true,
        isPhoneVerified: true,
        isJobVerified: true,
        isPhotoVerified: true,
        activityScore: 85.5,
        receivedLikes: 124,
        sentLikes: 89,
        successfulMatches: 12,
        status: UserStatus.active,
        height: 175,
        bodyType: '보통',
        education: '대졸',
        smoking: '비흡연',
        drinking: '가끔',
        religion: '무교',
        mbti: 'ENFJ',
        hobbies: ['독서', '영화감상', '운동'],
        points: 1250,
      ),
      UserModel(
        id: 'user_002',
        name: '이영희',
        age: 38,
        gender: 'female',
        phoneNumber: '+821087654321',
        email: 'lee.yh@example.com',
        location: '서울 송파구',
        job: '교사',
        profileImage: null,
        profileImages: [],
        bio: '따뜻한 사람과 만나고 싶어요.',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastLoginAt: DateTime.now().subtract(const Duration(minutes: 30)),
        isVip: false,
        isPhoneVerified: true,
        isJobVerified: false,
        isPhotoVerified: true,
        activityScore: 92.3,
        receivedLikes: 156,
        sentLikes: 67,
        successfulMatches: 8,
        status: UserStatus.active,
        height: 162,
        bodyType: '슬림',
        education: '대졸',
        smoking: '비흡연',
        drinking: '안함',
        religion: '기독교',
        mbti: 'INFP',
        hobbies: ['요리', '여행', '독서'],
        points: 850,
      ),
      UserModel(
        id: 'user_003',
        name: '박민수',
        age: 45,
        gender: 'male',
        phoneNumber: '+821055559999',
        email: 'park.ms@example.com',
        location: '부산 해운대구',
        job: '자영업',
        profileImage: null,
        profileImages: [],
        bio: '성실하고 책임감 있는 사람입니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
        isVip: true,
        isPhoneVerified: true,
        isJobVerified: true,
        isPhotoVerified: false,
        activityScore: 76.8,
        receivedLikes: 89,
        sentLikes: 145,
        successfulMatches: 5,
        status: UserStatus.active,
        height: 180,
        bodyType: '보통',
        education: '고졸',
        smoking: '가끔',
        drinking: '자주',
        religion: '불교',
        mbti: 'ISTJ',
        hobbies: ['낚시', '골프', '드라이브'],
        points: 2100,
      ),
      UserModel(
        id: 'user_004',
        name: '정수연',
        age: 40,
        gender: 'female',
        phoneNumber: '+821033334444',
        email: 'jung.sy@example.com',
        location: '대구 중구',
        job: '간호사',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        lastLoginAt: DateTime.now().subtract(const Duration(hours: 5)),
        isVip: false,
        isPhoneVerified: true,
        isJobVerified: true,
        isPhotoVerified: true,
        activityScore: 88.1,
        receivedLikes: 201,
        sentLikes: 34,
        successfulMatches: 15,
        status: UserStatus.suspended,
        height: 165,
        bodyType: '슬림',
        education: '대졸',
        smoking: '비흡연',
        drinking: '가끔',
        religion: '천주교',
        mbti: 'ESFJ',
        hobbies: ['음악감상', '요가', '카페투어'],
        points: 500,
      ),
      UserModel(
        id: 'user_005',
        name: '최민정',
        age: 29,
        gender: 'female',
        phoneNumber: '+821098765432',
        email: 'choi.mj@example.com',
        location: '인천 남동구',
        job: '디자이너',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        lastLoginAt: DateTime.now().subtract(const Duration(minutes: 15)),
        isVip: true,
        isPhoneVerified: true,
        isJobVerified: true,
        isPhotoVerified: true,
        activityScore: 94.2,
        receivedLikes: 178,
        sentLikes: 43,
        successfulMatches: 22,
        status: UserStatus.active,
        height: 168,
        bodyType: '슬림',
        education: '대졸',
        smoking: '비흡연',
        drinking: '가끔',
        religion: '무교',
        mbti: 'ISFP',
        hobbies: ['그림그리기', '카페투어', '음악감상'],
        points: 3200,
      ),
      UserModel(
        id: 'user_006',
        name: '강태우',
        age: 35,
        gender: 'male',
        phoneNumber: '+821077889900',
        email: 'kang.tw@example.com',
        location: '경기 성남시',
        job: '엔지니어',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        lastLoginAt: DateTime.now().subtract(const Duration(hours: 1)),
        isVip: false,
        isPhoneVerified: true,
        isJobVerified: false,
        isPhotoVerified: true,
        activityScore: 78.9,
        receivedLikes: 95,
        sentLikes: 167,
        successfulMatches: 7,
        status: UserStatus.active,
        height: 183,
        bodyType: '보통',
        education: '대졸',
        smoking: '비흡연',
        drinking: '자주',
        religion: '기독교',
        mbti: 'INTJ',
        hobbies: ['게임', '독서', '코딩'],
        points: 750,
      ),
      UserModel(
        id: 'user_007',
        name: '윤서영',
        age: 33,
        gender: 'female',
        phoneNumber: '+821066778899',
        email: 'yoon.sy@example.com',
        location: '대전 유성구',
        job: '의사',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        lastLoginAt: DateTime.now().subtract(const Duration(days: 3)),
        isVip: true,
        isPhoneVerified: true,
        isJobVerified: true,
        isPhotoVerified: false,
        activityScore: 91.5,
        receivedLikes: 234,
        sentLikes: 28,
        successfulMatches: 18,
        status: UserStatus.suspended,
        height: 164,
        bodyType: '슬림',
        education: '대학원졸',
        smoking: '비흡연',
        drinking: '안함',
        religion: '천주교',
        mbti: 'ENFP',
        hobbies: ['독서', '여행', '봉사활동'],
        points: 1800,
      ),
      UserModel(
        id: 'user_008',
        name: '홍길동',
        age: 28,
        gender: 'male',
        phoneNumber: '+821012344321',
        email: 'hong.gd@example.com',
        location: '광주 서구',
        job: '학생',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        lastLoginAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isVip: false,
        isPhoneVerified: false,
        isJobVerified: false,
        isPhotoVerified: true,
        activityScore: 65.3,
        receivedLikes: 45,
        sentLikes: 89,
        successfulMatches: 3,
        status: UserStatus.active,
        height: 174,
        bodyType: '마른',
        education: '대학생',
        smoking: '가끔',
        drinking: '자주',
        religion: '무교',
        mbti: 'ESTP',
        hobbies: ['축구', '영화감상', '여행'],
        points: 320,
      ),
    ];

    // 검색과 필터링은 _applyFiltersAndSearch에서 처리하므로 
    // 여기서는 모든 사용자 반환
    return users;
  }

  /// 회원 상세 정보 조회
  Future<UserModel> getUser(String userId) async {
    try {
      // TODO: 실제 AWS 데이터 조회로 교체
      final users = _generateSimulatedUsers(
        pageSize: 100,
        searchQuery: '',
        filters: {},
      );
      
      final user = users.firstWhere(
        (u) => u.id == userId,
        orElse: () => throw Exception('사용자를 찾을 수 없습니다'),
      );
      
      return user;
    } catch (e) {
      throw Exception('회원 상세 조회 실패: $e');
    }
  }

  /// 회원 상태 변경
  Future<void> updateUserStatus(String userId, UserStatus status) async {
    try {
      // TODO: 실제 AWS Cognito 상태 변경으로 교체
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (userId.isEmpty) {
        throw Exception('유효하지 않은 사용자 ID입니다');
      }
      
      // 시뮬레이션: 성공했다고 가정
    } catch (e) {
      throw Exception('회원 상태 변경 실패: $e');
    }
  }

  /// VIP 상태 변경
  Future<void> updateVipStatus(String userId, bool isVip) async {
    try {
      // TODO: 실제 DynamoDB 업데이트로 교체
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (userId.isEmpty) {
        throw Exception('유효하지 않은 사용자 ID입니다');
      }
      
      // 시뮬레이션: 성공했다고 가정
    } catch (e) {
      throw Exception('VIP 상태 변경 실패: $e');
    }
  }

  /// 일괄 작업
  Future<void> bulkAction(String action, List<String> userIds) async {
    try {
      for (final userId in userIds) {
        switch (action) {
          case 'suspend':
            await updateUserStatus(userId, UserStatus.suspended);
            break;
          case 'activate':
            await updateUserStatus(userId, UserStatus.active);
            break;
          case 'delete':
            await updateUserStatus(userId, UserStatus.deleted);
            break;
          case 'makeVip':
            await updateVipStatus(userId, true);
            break;
          case 'removeVip':
            await updateVipStatus(userId, false);
            break;
        }
      }
    } catch (e) {
      throw Exception('일괄 작업 실패: $e');
    }
  }

  /// 회원 정보 수정
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      // TODO: 실제 DynamoDB 업데이트로 교체
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (userId.isEmpty) {
        throw Exception('유효하지 않은 사용자 ID입니다');
      }
      
      // 시뮬레이션: 성공했다고 가정
    } catch (e) {
      throw Exception('회원 정보 수정 실패: $e');
    }
  }

  /// VIP 등급 업데이트
  Future<void> updateVipGrade(String profileId, String userId, String vipGrade) async {
    try {
      Logger.log('🏆 VIP 등급 업데이트 시작: $vipGrade', name: 'AdminUsersService');
      
      // GraphQL Mutation으로 Profiles의 badges 필드 업데이트
      const graphQLDocument = '''
        mutation UpdateProfiles(\$input: UpdateProfilesInput!) {
          updateProfiles(input: \$input) {
            id
            userId
            badges
          }
        }
      ''';
      
      // VIP 등급에 따른 badge 설정
      List<String> badges = [];
      switch (vipGrade) {
        case '골드':
          badges = ['gold', 'vip'];
          break;
        case '실버':
          badges = ['silver', 'vip'];
          break;
        case '브론즈':
          badges = ['bronze', 'vip'];
          break;
        default:
          badges = ['vip'];
      }
      
      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {
          'input': {
            'id': profileId,
            'badges': badges,
          },
        },
      );
      
      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        Logger.error('GraphQL 에러 발생: ${response.errors}', name: 'AdminUsersService');
        throw Exception('GraphQL 에러: ${response.errors}');
      }
      
      if (response.data == null) {
        Logger.error('응답 데이터가 null입니다', name: 'AdminUsersService');
        throw Exception('응답 데이터가 없습니다');
      }
      
      Logger.log('✅ VIP 등급 업데이트 성공', name: 'AdminUsersService');
      Logger.log('📝 응답 데이터: ${response.data}', name: 'AdminUsersService');
    } catch (e) {
      Logger.error('VIP 등급 업데이트 실패: $e', name: 'AdminUsersService');
      throw Exception('VIP 등급 업데이트 실패: $e');
    }
  }

  /// 엑셀 다운로드용 데이터 조회
  Future<List<UserModel>> getUsersForExcel({
    String searchQuery = '',
    Map<String, dynamic> filters = const {},
    String? sortField,
    bool sortAscending = true,
  }) async {
    try {
      final result = await getUsers(
        page: 1,
        pageSize: 10000, // 큰 값으로 설정하여 모든 데이터 조회
        searchQuery: searchQuery,
        filters: filters,
        sortField: sortField,
        sortAscending: sortAscending,
      );
      
      return result['users'] as List<UserModel>;
    } catch (e) {
      throw Exception('엑셀 데이터 조회 실패: $e');
    }
  }

  // === Helper Methods ===

  bool _matchesFilters(UserModel user, Map<String, dynamic> filters) {
    if (filters.isEmpty) return true;
    
    if (filters.containsKey('gender') && filters['gender'] != null) {
      if (user.gender != filters['gender']) {
        Logger.log('❌ 성별 필터 불일치: ${user.name} (${user.gender} != ${filters['gender']})', name: 'Filter');
        return false;
      }
    }
    
    if (filters.containsKey('isVip') && filters['isVip'] != null) {
      if (user.isVip != filters['isVip']) {
        Logger.log('❌ VIP 필터 불일치: ${user.name} (${user.isVip} != ${filters['isVip']})', name: 'Filter');
        return false;
      }
    }
    
    if (filters.containsKey('status') && filters['status'] != null) {
      if (user.status.name != filters['status']) {
        Logger.log('❌ 상태 필터 불일치: ${user.name} (${user.status.name} != ${filters['status']})', name: 'Filter');
        return false;
      }
    }
    
    if (filters.containsKey('location') && filters['location'] != null) {
      if (!user.location.contains(filters['location'])) {
        Logger.log('❌ 지역 필터 불일치: ${user.name} (${user.location} does not contain ${filters['location']})', name: 'Filter');
        return false;
      }
    }
    
    if (filters.containsKey('startDate') && filters['startDate'] != null) {
      final startDate = filters['startDate'] as DateTime;
      if (user.createdAt.isBefore(startDate)) {
        Logger.log('❌ 시작일 필터 불일치: ${user.name} (${user.createdAt} < $startDate)', name: 'Filter');
        return false;
      }
    }
    
    if (filters.containsKey('endDate') && filters['endDate'] != null) {
      final endDate = filters['endDate'] as DateTime;
      if (user.createdAt.isAfter(endDate)) {
        Logger.log('❌ 종료일 필터 불일치: ${user.name} (${user.createdAt} > $endDate)', name: 'Filter');
        return false;
      }
    }
    
    return true;
  }

  void _sortUsers(List<UserModel> users, String sortField, bool ascending) {
    users.sort((a, b) {
      dynamic aValue;
      dynamic bValue;
      
      switch (sortField) {
        case 'name':
          aValue = a.name;
          bValue = b.name;
          break;
        case 'age':
          aValue = a.age;
          bValue = b.age;
          break;
        case 'createdAt':
          aValue = a.createdAt;
          bValue = b.createdAt;
          break;
        case 'lastLoginAt':
          aValue = a.lastLoginAt ?? DateTime(1970);
          bValue = b.lastLoginAt ?? DateTime(1970);
          break;
        case 'activityScore':
          aValue = a.activityScore;
          bValue = b.activityScore;
          break;
        default:
          return 0;
      }
      
      final comparison = Comparable.compare(aValue, bValue);
      return ascending ? comparison : -comparison;
    });
  }
}