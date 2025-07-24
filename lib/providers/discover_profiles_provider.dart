import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/profile_model.dart';
import '../services/aws_profile_service.dart';
import '../services/aws_likes_service.dart';
import '../services/location_service.dart';
import '../utils/logger.dart';
import 'enhanced_auth_provider.dart';
import 'current_user_profile_provider.dart';

/// 프로필 필터 설정
class ProfileFilter {
  final String? gender;
  final int? minAge;
  final int? maxAge;
  final double? maxDistance;
  final String? location;
  final bool onlyVerified;
  final bool onlyOnline;

  const ProfileFilter({
    this.gender,
    this.minAge,
    this.maxAge,
    this.maxDistance,
    this.location,
    this.onlyVerified = false,
    this.onlyOnline = false,
  });

  ProfileFilter copyWith({
    String? gender,
    int? minAge,
    int? maxAge,
    double? maxDistance,
    String? location,
    bool? onlyVerified,
    bool? onlyOnline,
  }) {
    return ProfileFilter(
      gender: gender ?? this.gender,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      maxDistance: maxDistance ?? this.maxDistance,
      location: location ?? this.location,
      onlyVerified: onlyVerified ?? this.onlyVerified,
      onlyOnline: onlyOnline ?? this.onlyOnline,
    );
  }
}

/// 프로필 탐색 상태
class DiscoverProfilesState {
  final List<ProfileModel> profiles;
  final List<String> viewedProfileIds;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final ProfileFilter filter;
  final String? nextToken;
  final bool hasMore;
  final Position? currentLocation;

  const DiscoverProfilesState({
    this.profiles = const [],
    this.viewedProfileIds = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.filter = const ProfileFilter(),
    this.nextToken,
    this.hasMore = true,
    this.currentLocation,
  });

  DiscoverProfilesState copyWith({
    List<ProfileModel>? profiles,
    List<String>? viewedProfileIds,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    ProfileFilter? filter,
    String? nextToken,
    bool? hasMore,
    Position? currentLocation,
  }) {
    return DiscoverProfilesState(
      profiles: profiles ?? this.profiles,
      viewedProfileIds: viewedProfileIds ?? this.viewedProfileIds,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      filter: filter ?? this.filter,
      nextToken: nextToken,
      hasMore: hasMore ?? this.hasMore,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}

/// 프로필 탐색 관리
class DiscoverProfilesNotifier extends StateNotifier<DiscoverProfilesState> {
  final Ref ref;
  final AWSProfileService _profileService = AWSProfileService();
  final AWSLikesService _likesService = AWSLikesService();
  final LocationService _locationService = LocationService();
  StreamSubscription? _profileCreateSubscription;
  StreamSubscription? _profileUpdateSubscription;
  
  // 이미 평가한 프로필 ID 캐시
  Set<String> _evaluatedProfileIds = <String>{};
  
  DiscoverProfilesNotifier(this.ref) : super(const DiscoverProfilesState()) {
    // 실시간 프로필 업데이트 구독 시작
    _initializeRealtimeSubscriptions();
    
    // 이미 평가한 프로필 로드
    _loadEvaluatedProfiles();
  }
  
  @override
  void dispose() {
    _profileCreateSubscription?.cancel();
    _profileUpdateSubscription?.cancel();
    super.dispose();
  }

  /// 초기 로드
  Future<void> loadProfiles({bool forceRefresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      profiles: forceRefresh ? [] : state.profiles,
      viewedProfileIds: forceRefresh ? [] : state.viewedProfileIds,
      nextToken: forceRefresh ? null : state.nextToken,
      hasMore: forceRefresh ? true : state.hasMore,
    );

    try {
      // 1. 현재 사용자 확인
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final currentUserId = authState.currentUser!.user!.userId;

      // 2. 현재 사용자의 프로필 정보 가져오기 (성별 확인)
      final currentUserProfile = ref.read(currentProfileProvider);
      String? oppositeGender;
      
      Logger.log('=== 프로필 로딩 디버깅 ===', name: 'DiscoverProfilesProvider');
      Logger.log('현재 사용자 ID: $currentUserId', name: 'DiscoverProfilesProvider');
      Logger.log('내 프로필 존재 여부: ${currentUserProfile != null}', name: 'DiscoverProfilesProvider');
      Logger.log('내 프로필 성별: ${currentUserProfile?.gender}', name: 'DiscoverProfilesProvider');
      Logger.log('인증 상태: ${authState.isSignedIn}', name: 'DiscoverProfilesProvider');
      Logger.log('사용자 이메일: ${authState.currentUser?.user?.username}', name: 'DiscoverProfilesProvider');
      
      if (currentUserProfile?.gender != null && currentUserProfile!.gender!.isNotEmpty) {
        // 현재 사용자가 남성이면 여성 프로필만, 여성이면 남성 프로필만 조회
        oppositeGender = currentUserProfile.gender == '남성' ? '여성' : '남성';
        Logger.log('타겟 성별: $oppositeGender', name: 'DiscoverProfilesProvider');
      } else {
        // 성별 정보가 없으면 프로필 완성을 유도하고 일단 모든 성별 조회
        Logger.log('⚠️ 성별 정보가 없어 모든 성별 조회', name: 'DiscoverProfilesProvider');
        Logger.log('💡 사용자에게 프로필 완성을 권장해야 합니다', name: 'DiscoverProfilesProvider');
        oppositeGender = null; // null로 설정하여 모든 성별 조회
      }

      // 3. 현재 위치 가져오기 (옵션)
      Position? location;
      if (state.filter.maxDistance != null) {
        try {
          location = await _locationService.getCurrentLocation();
          state = state.copyWith(currentLocation: location);
        } catch (e) {
          Logger.log('위치 정보를 가져올 수 없습니다.', name: 'DiscoverProfilesProvider');
        }
      }

      // 4. 프로필 목록 조회 (성별 필터 활성화)
      Logger.log('✅ 성별 필터 활성화 - 이성 프로필만 조회: $oppositeGender', name: 'DiscoverProfilesProvider');
      final profiles = await _profileService.getDiscoverProfiles(
        currentUserId: currentUserId,
        gender: oppositeGender,  // 이성 프로필만 조회
        minAge: state.filter.minAge,
        maxAge: state.filter.maxAge,
        maxDistance: state.filter.maxDistance,
        location: state.filter.location,
        limit: 20,
        nextToken: forceRefresh ? null : state.nextToken,
      );
      
      Logger.log('가져온 프로필 수: ${profiles.length}', name: 'DiscoverProfilesProvider');
      
      // 가져온 프로필의 성별 정보 정규화
      final normalizedProfiles = _normalizeProfileGenders(profiles);
      Logger.log('성별 정규화 후 프로필 수: ${normalizedProfiles.length}', name: 'DiscoverProfilesProvider');
      
      // AWS에서 데이터가 없으면 디버깅 정보 출력
      if (normalizedProfiles.isEmpty) {
        Logger.log('⚠️ AWS에서 프로필을 가져오지 못함', name: 'DiscoverProfilesProvider');
        Logger.log('필터 조건:', name: 'DiscoverProfilesProvider');
        Logger.log('  - 성별: ${oppositeGender ?? state.filter.gender}', name: 'DiscoverProfilesProvider');
        Logger.log('  - 나이: ${state.filter.minAge}-${state.filter.maxAge}', name: 'DiscoverProfilesProvider');
        Logger.log('  - 위치: ${state.filter.location}', name: 'DiscoverProfilesProvider');
        Logger.log('  - 거리: ${state.filter.maxDistance}km', name: 'DiscoverProfilesProvider');
        
        Logger.log('❌ 정규화 후에도 프로필 없음 - AWS 연결 문제 추정', name: 'DiscoverProfilesProvider');
      } else {
        Logger.log('✅ AWS에서 프로필 ${normalizedProfiles.length}개 성공적으로 로드', name: 'DiscoverProfilesProvider');
        // 각 프로필의 기본 정보 로그
        for (final profile in normalizedProfiles.take(3)) {
          Logger.log('  - ${profile.name} (${profile.age}세, ${profile.gender ?? '성별미상'})', 
                     name: 'DiscoverProfilesProvider');
        }
        if (normalizedProfiles.length > 3) {
          Logger.log('  - 외 ${normalizedProfiles.length - 3}명 더...', name: 'DiscoverProfilesProvider');
        }
      }

      // 4. 필터 적용
      final filteredProfiles = _applyLocalFilters(normalizedProfiles);

      // 5. 이미 본 프로필 및 평가한 프로필 제외
      final availableProfiles = filteredProfiles
          .where((p) => !state.viewedProfileIds.contains(p.id) && 
                       !_evaluatedProfileIds.contains(p.id))
          .toList();
      
      // 6. 지능형 매칭 점수로 정렬
      final sortedProfiles = _sortByMatchingScore(availableProfiles);

      state = state.copyWith(
        profiles: forceRefresh ? sortedProfiles : [...state.profiles, ...sortedProfiles],
        isLoading: false,
        hasMore: normalizedProfiles.length >= 20,
      );
    } catch (e) {
      Logger.error('프로필 로드 오류', error: e, name: 'DiscoverProfilesProvider');
      state = state.copyWith(
        isLoading: false,
        error: '프로필을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 추가 프로필 로드
  Future<void> loadMoreProfiles() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final currentUserId = authState.currentUser!.user!.userId;

      // 현재 사용자의 프로필 정보 가져오기 (성별 확인)
      final currentUserProfile = ref.read(currentProfileProvider);
      String? oppositeGender;
      
      if (currentUserProfile?.gender != null) {
        // 현재 사용자가 남성이면 여성 프로필만, 여성이면 남성 프로필만 조회
        oppositeGender = currentUserProfile!.gender == '남성' ? '여성' : '남성';
      }

      final profiles = await _profileService.getDiscoverProfiles(
        currentUserId: currentUserId,
        gender: oppositeGender ?? state.filter.gender,  // 이성 필터 적용
        minAge: state.filter.minAge,
        maxAge: state.filter.maxAge,
        maxDistance: state.filter.maxDistance,
        location: state.filter.location,
        limit: 20,
        nextToken: state.nextToken,
      );

      final filteredProfiles = _applyLocalFilters(profiles);
      final availableProfiles = filteredProfiles
          .where((p) => !state.viewedProfileIds.contains(p.id) && 
                       !_evaluatedProfileIds.contains(p.id))
          .toList();
      
      // 지능형 매칭 점수로 정렬
      final sortedProfiles = _sortByMatchingScore(availableProfiles);

      state = state.copyWith(
        profiles: [...state.profiles, ...sortedProfiles],
        isLoadingMore: false,
        hasMore: profiles.length >= 20,
      );
    } catch (e) {
      Logger.error('추가 프로필 로드 오류', error: e, name: 'DiscoverProfilesProvider');
      state = state.copyWith(
        isLoadingMore: false,
        error: '추가 프로필을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 필터 업데이트
  void updateFilter(ProfileFilter filter) {
    state = state.copyWith(filter: filter);
    loadProfiles(forceRefresh: true);
  }

  /// 성별 필터 설정
  void setGenderFilter(String? gender) {
    final newFilter = state.filter.copyWith(gender: gender);
    updateFilter(newFilter);
  }

  /// 나이 범위 필터 설정
  void setAgeRangeFilter(int? minAge, int? maxAge) {
    final newFilter = state.filter.copyWith(
      minAge: minAge,
      maxAge: maxAge,
    );
    updateFilter(newFilter);
  }

  /// 거리 필터 설정
  void setDistanceFilter(double? maxDistance) {
    final newFilter = state.filter.copyWith(maxDistance: maxDistance);
    updateFilter(newFilter);
  }

  /// 위치 필터 설정
  void setLocationFilter(String? location) {
    final newFilter = state.filter.copyWith(location: location);
    updateFilter(newFilter);
  }

  /// 인증 여부 필터 설정
  void setVerifiedFilter(bool onlyVerified) {
    final newFilter = state.filter.copyWith(onlyVerified: onlyVerified);
    updateFilter(newFilter);
  }

  /// 온라인 여부 필터 설정
  void setOnlineFilter(bool onlyOnline) {
    final newFilter = state.filter.copyWith(onlyOnline: onlyOnline);
    updateFilter(newFilter);
  }

  /// 프로필 본 것으로 표시
  void markProfileAsViewed(String profileId) {
    if (!state.viewedProfileIds.contains(profileId)) {
      state = state.copyWith(
        viewedProfileIds: [...state.viewedProfileIds, profileId],
      );

      // 프로필 조회수 증가
      _profileService.incrementProfileView(profileId).catchError((e) {
        Logger.error('프로필 조회수 증가 오류', error: e, name: 'DiscoverProfilesProvider');
      });
    }
  }

  /// 현재 표시할 프로필 가져오기
  ProfileModel? getCurrentProfile() {
    final availableProfiles = state.profiles
        .where((p) => !state.viewedProfileIds.contains(p.id) && 
                     !_evaluatedProfileIds.contains(p.id))
        .toList();
    
    if (availableProfiles.isEmpty) {
      // 매칭 풀 자동 보충 체크
      _checkAndReplenishPool();
      return null;
    }
    return availableProfiles.first;
  }

  /// 다음 프로필로 이동
  void moveToNextProfile() {
    final current = getCurrentProfile();
    if (current != null) {
      markProfileAsViewed(current.id);
    }

    // 남은 프로필이 적으면 추가 로드
    final remainingCount = state.profiles
        .where((p) => !state.viewedProfileIds.contains(p.id))
        .length;
    
    if (remainingCount < 5 && state.hasMore && !state.isLoadingMore) {
      loadMoreProfiles();
    }
  }

  /// 로컬 필터 적용
  List<ProfileModel> _applyLocalFilters(List<ProfileModel> profiles) {
    final currentUserProfile = ref.read(currentProfileProvider);
    
    return profiles.where((profile) {
      // 성별 필터 (클라이언트 사이드에서 처리)
      if (currentUserProfile?.gender != null && currentUserProfile!.gender!.isNotEmpty) {
        final oppositeGender = currentUserProfile.gender == '남성' ? '여성' : '남성';
        
        // 프로필의 성별이 있고, 이성이 아니면 제외
        if (profile.gender != null && profile.gender!.isNotEmpty) {
          if (profile.gender != oppositeGender) {
            Logger.log('성별 필터링: ${profile.name} (${profile.gender}) 제외', name: 'DiscoverProfilesProvider');
            return false;
          }
        } else {
          // 성별 정보가 없는 프로필은 일단 포함 (추후 사용자가 판단)
          Logger.log('성별 미상: ${profile.name} - 포함시킴', name: 'DiscoverProfilesProvider');
        }
      }
      
      // 인증 필터
      if (state.filter.onlyVerified && !profile.isVerified) {
        return false;
      }

      // 온라인 필터
      if (state.filter.onlyOnline && !profile.isOnline) {
        return false;
      }

      // 거리 필터 (위치 정보가 있는 경우)
      if (state.filter.maxDistance != null && 
          state.currentLocation != null && 
          profile.distance != null) {
        if (profile.distance! > state.filter.maxDistance!) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// 프로필 새로고침
  Future<void> refreshProfiles() async {
    await loadProfiles(forceRefresh: true);
  }
  
  /// 프로필 성별 정보 정규화
  List<ProfileModel> _normalizeProfileGenders(List<ProfileModel> profiles) {
    return profiles.map((profile) {
      String? normalizedGender = _normalizeGender(profile.gender);
      
      if (normalizedGender != profile.gender) {
        Logger.log('성별 정규화: ${profile.name} "${profile.gender}" → "$normalizedGender"', 
                   name: 'DiscoverProfilesProvider');
        
        // ProfileModel의 copyWith를 사용하여 성별 정보 업데이트
        return profile.copyWith(gender: normalizedGender);
      }
      
      return profile;
    }).toList();
  }
  
  /// 성별 정보 정규화 헬퍼 메서드
  String? _normalizeGender(String? gender) {
    if (gender == null || gender.trim().isEmpty) {
      return null; // 빈 문자열이나 null은 null로 처리
    }
    
    final trimmedGender = gender.trim().toLowerCase();
    
    // 다양한 성별 표현을 표준화
    switch (trimmedGender) {
      case 'm':
      case 'male':
      case '남':
      case '남자':
      case '남성':
        return '남성';
      case 'f':
      case 'female':
      case '여':
      case '여자':
      case '여성':
        return '여성';
      default:
        Logger.log('알 수 없는 성별 형식: "$gender"', name: 'DiscoverProfilesProvider');
        return null; // 알 수 없는 형식은 null로 처리
    }
  }
  
  /// 이미 평가한 프로필 목록 로드
  Future<void> _loadEvaluatedProfiles() async {
    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        return;
      }

      final currentUserId = authState.currentUser!.user!.userId;
      
      // 보낸 좋아요/패스 목록 조회
      final sentLikes = await _likesService.getSentLikes(userId: currentUserId);
      
      // 평가한 프로필 ID 추출
      _evaluatedProfileIds = sentLikes.map((like) => like.toProfileId).toSet();
      
      Logger.log('이미 평가한 프로필 ${_evaluatedProfileIds.length}개 로드', 
                 name: 'DiscoverProfilesProvider');
    } catch (e) {
      Logger.error('평가한 프로필 로드 오류', error: e, name: 'DiscoverProfilesProvider');
    }
  }
  
  /// 프로필 평가 후 매칭 풀 업데이트
  void markProfileAsEvaluated(String profileId) {
    _evaluatedProfileIds.add(profileId);
    markProfileAsViewed(profileId);
    
    // 남은 프로필 수 확인
    final remainingCount = getRemainingProfilesCount();
    
    // 매칭 풀이 부족하면 자동 갱신
    if (remainingCount < 3 && state.hasMore) {
      loadMoreProfiles();
    } else if (remainingCount == 0 && !state.hasMore) {
      // 모든 프로필을 소진했으면 풀 확장 시도
      _expandMatchingPool();
    }
  }
  
  /// 남은 프로필 수 계산
  int getRemainingProfilesCount() {
    return state.profiles
        .where((p) => !state.viewedProfileIds.contains(p.id) && 
                     !_evaluatedProfileIds.contains(p.id))
        .length;
  }
  
  /// 매칭 풀 확장 (필터 조건 완화)
  Future<void> _expandMatchingPool() async {
    try {
      Logger.log('매칭 풀 확장 시작', name: 'DiscoverProfilesProvider');
      
      // 1. 거리 필터 확장
      if (state.filter.maxDistance != null && state.filter.maxDistance! < 100) {
        final expandedFilter = state.filter.copyWith(
          maxDistance: (state.filter.maxDistance! * 1.5).clamp(0, 100),
        );
        updateFilter(expandedFilter);
        Logger.log('거리 필터 확장: ${expandedFilter.maxDistance}km', 
                   name: 'DiscoverProfilesProvider');
        return;
      }
      
      // 2. 나이 범위 확장
      if (state.filter.minAge != null || state.filter.maxAge != null) {
        final expandedMinAge = state.filter.minAge != null 
            ? (state.filter.minAge! - 2).clamp(18, 100)
            : null;
        final expandedMaxAge = state.filter.maxAge != null 
            ? (state.filter.maxAge! + 2).clamp(18, 100)
            : null;
            
        final expandedFilter = state.filter.copyWith(
          minAge: expandedMinAge,
          maxAge: expandedMaxAge,
        );
        updateFilter(expandedFilter);
        Logger.log('나이 범위 확장: $expandedMinAge-$expandedMaxAge', 
                   name: 'DiscoverProfilesProvider');
        return;
      }
      
      // 3. 온라인 필터 해제
      if (state.filter.onlyOnline) {
        final expandedFilter = state.filter.copyWith(onlyOnline: false);
        updateFilter(expandedFilter);
        Logger.log('온라인 필터 해제', name: 'DiscoverProfilesProvider');
        return;
      }
      
      // 4. 인증 필터 해제
      if (state.filter.onlyVerified) {
        final expandedFilter = state.filter.copyWith(onlyVerified: false);
        updateFilter(expandedFilter);
        Logger.log('인증 필터 해제', name: 'DiscoverProfilesProvider');
        return;
      }
      
      Logger.log('더 이상 확장할 수 있는 필터 조건이 없습니다.', 
                 name: 'DiscoverProfilesProvider');
    } catch (e) {
      Logger.error('매칭 풀 확장 오류', error: e, name: 'DiscoverProfilesProvider');
    }
  }
  
  /// 매칭 풀 상태 체크 및 자동 보충
  void _checkAndReplenishPool() {
    final remainingCount = getRemainingProfilesCount();
    
    if (remainingCount < 5) {
      Logger.log('매칭 풀 자동 보충 필요 (남은 프로필: $remainingCount개)', 
                 name: 'DiscoverProfilesProvider');
      
      if (state.hasMore) {
        loadMoreProfiles();
      } else {
        _expandMatchingPool();
      }
    }
  }
  
  /// 실시간 프로필 업데이트 구독 초기화
  void _initializeRealtimeSubscriptions() {
    // 새로운 프로필 생성 구독
    _subscribeToNewProfiles();
    
    // 프로필 업데이트 구독
    _subscribeToProfileUpdates();
  }
  
  /// 새로운 프로필 생성 이벤트 구독
  void _subscribeToNewProfiles() {
    try {
      const graphQLDocument = '''
        subscription OnCreateProfile {
          onCreateProfile {
            id
            userId
            name
            age
            gender
            location
            images
            bio
            interests
            occupation
            education
            height
            religion
            drinkingStatus
            smokingStatus
            lookingFor
            hasChildren
            wantsChildren
            isVerified
            verificationBadge
            lastSeen
            isOnline
            profileViews
            createdAt
            updatedAt
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(document: graphQLDocument);
      final operation = Amplify.API.subscribe(request);
      
      _profileCreateSubscription = operation.listen(
        (event) {
          if (event.data != null) {
            _handleNewProfile(event.data!);
          }
        },
        onError: (error) {
          Logger.error('프로필 생성 구독 오류', error: error, name: 'DiscoverProfilesProvider');
        },
      );
    } catch (e) {
      Logger.error('프로필 생성 구독 설정 오류', error: e, name: 'DiscoverProfilesProvider');
    }
  }
  
  /// 프로필 업데이트 이벤트 구독
  void _subscribeToProfileUpdates() {
    try {
      const graphQLDocument = '''
        subscription OnUpdateProfile {
          onUpdateProfile {
            id
            userId
            name
            age
            gender
            location
            images
            bio
            interests
            occupation
            education
            height
            religion
            drinkingStatus
            smokingStatus
            lookingFor
            hasChildren
            wantsChildren
            isVerified
            verificationBadge
            lastSeen
            isOnline
            profileViews
            createdAt
            updatedAt
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(document: graphQLDocument);
      final operation = Amplify.API.subscribe(request);
      
      _profileUpdateSubscription = operation.listen(
        (event) {
          if (event.data != null) {
            _handleProfileUpdate(event.data!);
          }
        },
        onError: (error) {
          Logger.error('프로필 업데이트 구독 오류', error: error, name: 'DiscoverProfilesProvider');
        },
      );
    } catch (e) {
      Logger.error('프로필 업데이트 구독 설정 오류', error: e, name: 'DiscoverProfilesProvider');
    }
  }
  
  /// 새로운 프로필 처리
  void _handleNewProfile(String data) {
    try {
      final profileData = _parseGraphQLResponse(data);
      if (profileData == null) return;
      
      final newProfile = ProfileModel.fromJson(profileData);
      
      // 현재 사용자의 성별 확인
      final currentUserProfile = ref.read(currentProfileProvider);
      if (currentUserProfile?.gender == null) return;
      
      // 이성만 필터링
      final isOppositeGender = (currentUserProfile!.gender == '남성' && newProfile.gender == '여성') ||
                               (currentUserProfile.gender == '여성' && newProfile.gender == '남성');
      
      if (!isOppositeGender) return;
      
      // 필터 조건 확인
      if (!_matchesFilter(newProfile)) return;
      
      // 이미 본 프로필이 아닌 경우에만 추가
      if (!state.viewedProfileIds.contains(newProfile.id)) {
        state = state.copyWith(
          profiles: [newProfile, ...state.profiles],
        );
        
        // 새로운 프로필 로그 추가
        Logger.log('새로운 이성 프로필 추가됨: ${newProfile.name}', name: 'DiscoverProfilesProvider');
        
        Logger.log('새로운 프로필 추가: ${newProfile.name}', name: 'DiscoverProfilesProvider');
      }
    } catch (e) {
      Logger.error('새 프로필 처리 오류', error: e, name: 'DiscoverProfilesProvider');
    }
  }
  
  /// 프로필 업데이트 처리
  void _handleProfileUpdate(String data) {
    try {
      final profileData = _parseGraphQLResponse(data);
      if (profileData == null) return;
      
      final updatedProfile = ProfileModel.fromJson(profileData);
      
      // 기존 프로필 목록에서 업데이트
      final updatedProfiles = state.profiles.map((profile) {
        if (profile.id == updatedProfile.id) {
          return updatedProfile;
        }
        return profile;
      }).toList();
      
      state = state.copyWith(profiles: updatedProfiles);
      
      Logger.log('프로필 업데이트: ${updatedProfile.name}', name: 'DiscoverProfilesProvider');
    } catch (e) {
      Logger.error('프로필 업데이트 처리 오류', error: e, name: 'DiscoverProfilesProvider');
    }
  }
  
  /// GraphQL 응답 파싱
  Map<String, dynamic>? _parseGraphQLResponse(String data) {
    try {
      // GraphQL 응답 JSON 파싱
      final jsonData = json.decode(data);
      
      // onCreateProfile 또는 onUpdateProfile 이벤트에서 프로필 데이터 추출
      if (jsonData['onCreateProfile'] != null) {
        return jsonData['onCreateProfile'] as Map<String, dynamic>;
      } else if (jsonData['onUpdateProfile'] != null) {
        return jsonData['onUpdateProfile'] as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      Logger.error('GraphQL 응답 파싱 오류', error: e, name: 'DiscoverProfilesProvider');
      return null;
    }
  }
  
  /// 필터 조건 매칭 확인
  bool _matchesFilter(ProfileModel profile) {
    // 나이 필터
    if (state.filter.minAge != null && profile.age < state.filter.minAge!) {
      return false;
    }
    if (state.filter.maxAge != null && profile.age > state.filter.maxAge!) {
      return false;
    }
    
    // 위치 필터
    if (state.filter.location != null && profile.location != state.filter.location) {
      return false;
    }
    
    // 인증 필터
    if (state.filter.onlyVerified && !profile.isVerified) {
      return false;
    }
    
    // 온라인 필터
    if (state.filter.onlyOnline && !profile.isOnline) {
      return false;
    }
    
    return true;
  }
  
  /// 지능형 매칭 점수 계산
  double _calculateMatchingScore(ProfileModel profile) {
    double score = 0.0;
    final currentUserProfile = ref.read(currentProfileProvider);
    
    if (currentUserProfile == null) return score;
    
    // 1. 연령 호환성 (최대 20점)
    final ageDiff = (currentUserProfile.age - profile.age).abs();
    if (ageDiff <= 2) {
      score += 20;
    } else if (ageDiff <= 5) {
      score += 15;
    } else if (ageDiff <= 10) {
      score += 10;
    } else if (ageDiff <= 15) {
      score += 5;
    }
    
    // 2. 거리 기반 점수 (최대 20점)
    if (profile.distance != null) {
      if (profile.distance! <= 5) {
        score += 20;
      } else if (profile.distance! <= 10) {
        score += 15;
      } else if (profile.distance! <= 25) {
        score += 10;
      } else if (profile.distance! <= 50) {
        score += 5;
      }
    }
    
    // 3. 온라인 상태 (최대 15점)
    if (profile.isOnline) {
      score += 15;
    } else if (profile.lastSeen != null) {
      final lastSeenDate = profile.lastSeen;
      if (lastSeenDate != null) {
        final hoursSinceLastSeen = DateTime.now().difference(lastSeenDate).inHours;
        if (hoursSinceLastSeen <= 24) {
          score += 10;
        } else if (hoursSinceLastSeen <= 72) {
          score += 5;
        }
      }
    }
    
    // 4. 취미 매칭 (최대 20점)
    if (profile.hobbies.isNotEmpty && currentUserProfile.hobbies.isNotEmpty) {
      final commonHobbies = profile.hobbies
          .toSet()
          .intersection(currentUserProfile.hobbies.toSet())
          .length;
      score += (commonHobbies * 4).clamp(0, 20);
    }
    
    // 5. 프로필 완성도 (최대 15점)
    double completeness = 0;
    if (profile.bio != null && profile.bio!.isNotEmpty) completeness += 3;
    if (profile.occupation != null && profile.occupation!.isNotEmpty) completeness += 3;
    if (profile.education != null && profile.education!.isNotEmpty) completeness += 3;
    if (profile.profileImages.length >= 3) completeness += 3;
    if (profile.isVerified) completeness += 3;
    score += completeness;
    
    // 6. MBTI 호환성 (최대 10점)
    if (profile.mbti != null && currentUserProfile.mbti != null) {
      if (profile.mbti == currentUserProfile.mbti) {
        score += 10;
      } else if (profile.mbti != null && currentUserProfile.mbti != null) {
        // MBTI 호환성 간단 로직 (같은 기질이면 5점)
        final profileType = profile.mbti!.substring(0, 2);
        final userType = currentUserProfile.mbti!.substring(0, 2);
        if (profileType == userType) {
          score += 5;
        }
      }
    }
    
    return score;
  }
  
  /// 프로필 목록을 매칭 점수로 정렬
  List<ProfileModel> _sortByMatchingScore(List<ProfileModel> profiles) {
    // 각 프로필에 대해 매칭 점수 계산
    final profilesWithScores = profiles.map((profile) {
      return {
        'profile': profile,
        'score': _calculateMatchingScore(profile),
      };
    }).toList();
    
    // 점수 기준으로 내림차순 정렬
    profilesWithScores.sort((a, b) {
      final scoreA = a['score'] as double;
      final scoreB = b['score'] as double;
      return scoreB.compareTo(scoreA);
    });
    
    // 정렬된 프로필 목록 반환
    return profilesWithScores
        .map((item) => item['profile'] as ProfileModel)
        .toList();
  }

  /// 상태 초기화
  void reset() {
    state = const DiscoverProfilesState();
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
  
}

/// 프로필 탐색 프로바이더
final discoverProfilesProvider = StateNotifierProvider<DiscoverProfilesNotifier, DiscoverProfilesState>(
  (ref) => DiscoverProfilesNotifier(ref),
);

/// 현재 표시할 프로필 프로바이더
final currentDiscoverProfileProvider = Provider<ProfileModel?>((ref) {
  return ref.read(discoverProfilesProvider.notifier).getCurrentProfile();
});

/// 남은 프로필 수 프로바이더
final remainingProfilesCountProvider = Provider<int>((ref) {
  return ref.read(discoverProfilesProvider.notifier).getRemainingProfilesCount();
});