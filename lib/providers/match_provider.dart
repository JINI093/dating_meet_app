import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/profile_model.dart';
import '../models/match_model.dart';
import '../models/like_model.dart';
import '../models/superchat_model.dart';
import '../services/aws_profile_service.dart';
import '../services/aws_likes_service.dart';
import '../services/enhanced_superchat_service.dart';
import '../services/aws_match_service.dart';
import '../services/location_service.dart';
import '../utils/logger.dart';
import 'notification_provider.dart';
import 'matches_provider.dart';
import 'likes_provider.dart';
import 'enhanced_auth_provider.dart';
import 'discover_profiles_provider.dart';
import '../services/contact_service.dart';

// Match Result Model
class MatchResult {
  final bool isMatch;
  final String message;
  final ProfileModel? matchedProfile;
  final DateTime? matchedAt;
  final MatchModel? matchModel; // Added to store complete match data

  const MatchResult({
    required this.isMatch,
    required this.message,
    this.matchedProfile,
    this.matchedAt,
    this.matchModel,
  });

  factory MatchResult.success({
    required ProfileModel profile,
    required String message,
    MatchModel? matchModel,
  }) {
    return MatchResult(
      isMatch: true,
      message: message,
      matchedProfile: profile,
      matchedAt: DateTime.now(),
      matchModel: matchModel,
    );
  }

  factory MatchResult.pass() {
    return const MatchResult(
      isMatch: false,
      message: '다음 프로필로 넘어갑니다.',
    );
  }

  factory MatchResult.like() {
    return const MatchResult(
      isMatch: false,
      message: '좋아요를 보냈습니다.',
    );
  }

  factory MatchResult.superChat() {
    return const MatchResult(
      isMatch: false,
      message: '슈퍼챗을 보냈습니다.',
    );
  }
}

// Match State
class MatchState {
  final List<ProfileModel> profiles;
  final int currentIndex;
  final bool isLoading;
  final String? error;
  final Map<String, String> filters;

  const MatchState({
    required this.profiles,
    required this.currentIndex,
    required this.isLoading,
    this.error,
    required this.filters,
  });

  MatchState copyWith({
    List<ProfileModel>? profiles,
    int? currentIndex,
    bool? isLoading,
    String? error,
    Map<String, String>? filters,
  }) {
    return MatchState(
      profiles: profiles ?? this.profiles,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filters: filters ?? this.filters,
    );
  }

  ProfileModel? get currentProfile {
    if (currentIndex >= 0 && currentIndex < profiles.length) {
      return profiles[currentIndex];
    }
    return null;
  }

  List<ProfileModel> get remainingProfiles {
    if (currentIndex >= profiles.length) return [];
    return profiles.sublist(currentIndex);
  }

  bool get hasMoreProfiles => currentIndex < profiles.length;
}

// Match Provider
class MatchNotifier extends StateNotifier<MatchState> {
  final Ref ref;
  final AWSProfileService _profileService = AWSProfileService();
  final AWSLikesService _likesService = AWSLikesService();
  final AWSMatchService _matchService = AWSMatchService();
  final EnhancedSuperchatService _superchatService = EnhancedSuperchatService();
  
  MatchNotifier(this.ref) : super(const MatchState(
    profiles: [],
    currentIndex: 0,
    isLoading: false,
    filters: {},
  )) {
    _initialize();
  }

  // Initialize services and load profiles
  Future<void> _initialize() async {
    try {
      await _profileService.initialize();
      await _likesService.initialize();
      await _matchService.initialize();
      await _superchatService.initialize();
      await _loadInitialProfiles();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load initial profiles
  Future<void> _loadInitialProfiles() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Get current user info
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final currentUserId = authState.currentUser!.user!.userId;
      // 내 프로필에서 성별 조회
      final myProfile = await _profileService.getProfile(currentUserId);
      print('=== 프로필 로딩 디버깅 ===');
      print('현재 사용자 ID: $currentUserId');
      print('내 프로필 존재 여부: ${myProfile != null}');
      print('내 프로필 성별: ${myProfile?.gender}');
      
      String? targetGender;
      if (myProfile != null && myProfile.gender != null) {
        if (myProfile.gender == '남성' || myProfile.gender == 'M') {
          targetGender = '여성';
        } else if (myProfile.gender == '여성' || myProfile.gender == 'F') {
          targetGender = '남성';
        }
      } else {
        // 성별 정보가 없으면 기본값으로 여성 프로필을 표시
        print('성별 정보가 없어 기본값(여성) 사용');
        targetGender = '여성';
      }
      
      print('타겟 성별: $targetGender');
      
      // 실제 API에서 프로필을 가져오지 못한 경우에만 샘플 생성
      
      // Get discover profiles from AWS
      final discoveredProfiles = await _profileService.getDiscoverProfiles(
        currentUserId: currentUserId,
        gender: targetGender,
        limit: 20,
      );
      
      print('가져온 프로필 수: ${discoveredProfiles.length}');
      
      List<ProfileModel> finalProfiles;
      
      if (discoveredProfiles.isNotEmpty) {
        print('✅ AWS에서 실제 프로필 로드 성공!');
        print('첫 번째 프로필: ${discoveredProfiles.first.name} (${discoveredProfiles.first.gender})');
        
        // 이미 평가한 프로필과 매칭된 프로필 필터링
        final filteredProfiles = await _filterEvaluatedProfiles(discoveredProfiles, currentUserId);
        
        // 필터링 결과 로그
        print('전체 프로필: ${discoveredProfiles.length}개 → 필터링 후: ${filteredProfiles.length}개');
        
        // 처음 3개 프로필의 상세 정보 출력
        for (int i = 0; i < filteredProfiles.length && i < 3; i++) {
          final profile = filteredProfiles[i];
          print('실제 프로필 ${i + 1}: ${profile.name} (${profile.gender}) - ${profile.age}세, ${profile.location}');
        }
        
        finalProfiles = filteredProfiles;
      } else {
        print('⚠️  AWS에서 프로필을 가져오지 못함. 샘플 데이터 생성');
        
        // AWS에서 데이터가 없을 때만 샘플 데이터 생성
        finalProfiles = List.generate(6, (index) {
          return ProfileModel(
            id: 'sample_$index',
            name: targetGender == '여성' 
                ? ['지수', '민지', '하영', '수민', '예진', '서연'][index % 6] 
                : ['민호', '준영', '성민', '지훈', '태현', '승우'][index % 6],
            age: 25 + (index % 8),
            gender: targetGender,
            location: ['서울 강남구', '서울 송파구', '서울 서초구', '서울 마포구'][index % 4],
            profileImages: [
              'https://picsum.photos/seed/sample$index/400/600',
              'https://picsum.photos/seed/sample${index}b/400/600',
            ],
            bio: '안녕하세요! 진지한 만남을 찾고 있습니다.',
            occupation: ['회사원', '전문직', '자영업', '프리랜서'][index % 4],
            createdAt: DateTime.now().subtract(Duration(days: index)),
            updatedAt: DateTime.now(),
            isVip: index < 2,
            isPremium: index < 3,
            isVerified: true,
            likeCount: 10 + (index * 5),
            superChatCount: index * 2,
          );
        });
        
        print('📝 샘플 데이터 생성: ${finalProfiles.length}개');
      }
      
      final sortedProfiles = _applySorting(finalProfiles, 'super_chat');
      
      // 프로필이 없으면 매칭 종료 메시지 설정
      String? errorMessage;
      if (sortedProfiles.isEmpty) {
        errorMessage = '오늘의 매칭이 모두 끝났습니다.';
      }
      
      state = state.copyWith(
        profiles: sortedProfiles,
        currentIndex: 0,
        isLoading: false,
        error: errorMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Apply filters
  Future<void> applyFilters(Map<String, dynamic> filters) async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Get current user info
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final currentUserId = authState.currentUser!.user!.userId;
      print('👤 현재 사용자 ID: $currentUserId');
      
      // 내 프로필에서 성별 조회
      final myProfile = await _profileService.getProfile(currentUserId);
      String? targetGender = filters['gender'] as String?;
      
      // 필터에서 성별이 지정되지 않은 경우 이성을 자동으로 설정
      if (targetGender == null && myProfile != null && myProfile.gender != null) {
        print('👥 내 성별: ${myProfile.gender}');
        if (myProfile.gender == '남성' || myProfile.gender == 'M' || myProfile.gender == 'male') {
          targetGender = '여성';
        } else if (myProfile.gender == '여성' || myProfile.gender == 'F' || myProfile.gender == 'female') {
          targetGender = '남성';
        }
        print('🎯 타겟 성별: $targetGender');
      }
      // Handle multiple regions if provided
      List<String>? regions = filters['regions'] as List<String>?;
      String? location = filters['region'] as String?;
      
      // If multiple regions are selected, use the first one for now
      // In the future, we can enhance this to query multiple regions
      if (regions != null && regions.isNotEmpty) {
        location = regions.first;
      }
      
      // Get distance and position info for GPS-based filtering
      double? maxDistance;
      final distanceValue = filters['distance'];
      if (distanceValue is double) {
        maxDistance = distanceValue;
      } else if (distanceValue is String) {
        maxDistance = double.tryParse(distanceValue);
      } else if (distanceValue != null) {
        maxDistance = distanceValue as double?;
      }
      Position? userPosition = filters['userPosition'] as Position?;
      bool isLocationEnabled = filters['isLocationEnabled'] as bool? ?? false;
      
      print('📍 GPS 필터링 설정:');
      print('   거리 제한: ${maxDistance}km');
      print('   위치 활성화: $isLocationEnabled');
      print('   사용자 위치: ${userPosition?.latitude}, ${userPosition?.longitude}');
      
      // Apply filters to AWS query
      var filteredProfiles = await _profileService.getDiscoverProfiles(
        currentUserId: currentUserId,
        gender: targetGender,
        minAge: filters['minAge'] as int?,
        maxAge: filters['maxAge'] as int?,
        maxDistance: maxDistance,
        location: location,
        limit: 20,
      );
      
      // If regions are selected, apply additional client-side filtering
      if (regions != null && regions.isNotEmpty) {
        final originalCount = filteredProfiles.length;
        print('🏠 지역 필터 적용 전: $originalCount명');
        print('🎯 선택된 지역: $regions');
        
        filteredProfiles = filteredProfiles.where((profile) {
          final profileLocation = profile.location.trim();
          bool matched = regions.any((region) {
            final filterRegion = region.trim();
            
            // 완전 일치 검사
            if (profileLocation == filterRegion) {
              print('✅ 완전 일치: $profileLocation = $filterRegion');
              return true;
            }
            
            // 부분 일치 검사 (지역명이 포함되어 있는지)
            if (profileLocation.contains(filterRegion)) {
              print('✅ 부분 일치: $profileLocation contains $filterRegion');
              return true;
            }
            
            // 시/도 단위 매칭 (예: "서울"로 검색하면 "서울 강남구"도 매칭)
            final regionParts = filterRegion.split(' ');
            if (regionParts.isNotEmpty) {
              final province = regionParts[0];
              if (profileLocation.startsWith(province)) {
                print('✅ 시/도 매칭: $profileLocation starts with $province');
                return true;
              }
            }
            
            // 구/군 단위 매칭 (예: "강남구"로 검색하면 "서울 강남구"도 매칭)
            if (regionParts.length > 1) {
              final district = regionParts[1];
              if (profileLocation.contains(district)) {
                print('✅ 구/군 매칭: $profileLocation contains $district');
                return true;
              }
            }
            
            return false;
          });
          
          if (!matched) {
            print('❌ 매칭 실패: $profileLocation (필터: $regions)');
          }
          
          return matched;
        }).toList();
        
        print('🏠 지역 필터 적용 후: ${filteredProfiles.length}명');
      }
      
      // 자기 자신 제외 및 성별 필터링 강화
      filteredProfiles = filteredProfiles.where((profile) {
        // 1. 자기 자신 제외
        if (profile.id == currentUserId) {
          print('🚫 자기 자신 제외: ${profile.name}');
          return false;
        }
        
        // 2. 성별 필터링 (타겟 성별이 설정된 경우)
        if (targetGender != null && profile.gender != null) {
          final profileGender = profile.gender!.trim();
          bool genderMatch = false;
          
          if (targetGender == '여성') {
            genderMatch = profileGender == '여성' || profileGender == 'F' || profileGender == 'female';
          } else if (targetGender == '남성') {
            genderMatch = profileGender == '남성' || profileGender == 'M' || profileGender == 'male';
          }
          
          if (!genderMatch) {
            print('🚫 성별 불일치: ${profile.name} (${profile.gender}) - 타겟: $targetGender');
            return false;
          } else {
            print('✅ 성별 일치: ${profile.name} (${profile.gender})');
          }
        }
        
        return true;
      }).toList();
      
      print('👥 최종 필터링 후: ${filteredProfiles.length}명');
      
      // GPS 기반 거리 필터링 (위치 정보가 있는 경우)
      if (isLocationEnabled && userPosition != null && maxDistance != null) {
        print('📍 GPS 거리 필터링 시작...');
        final locationService = LocationService();
        
        filteredProfiles = filteredProfiles.where((profile) {
          // 프로필에 위치 정보가 있는지 확인
          if (profile.location.isEmpty) {
            print('❌ 위치 정보 없음: ${profile.name}');
            return false;
          }
          
          // TODO: 프로필의 위치를 좌표로 변환하는 로직 추가 필요
          // 현재는 거리 필터를 통과시킴 (향후 개선 필요)
          print('✅ GPS 필터 통과: ${profile.name} (${profile.location})');
          return true;
        }).toList();
        
        print('📍 GPS 거리 필터링 후: ${filteredProfiles.length}명');
      }
      
      // Apply sorting
      if (filters.containsKey('popularity') && filters['popularity'] != null) {
        final sortType = filters['popularity'] as String;
        filteredProfiles = _applySorting(filteredProfiles, sortType);
      }
      
      state = state.copyWith(
        profiles: filteredProfiles,
        currentIndex: 0,
        isLoading: false,
        filters: Map<String, String>.from(filters.map((k, v) => MapEntry(k, v.toString()))),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Apply sorting logic
  List<ProfileModel> _applySorting(List<ProfileModel> profiles, String sortType) {
    final List<ProfileModel> sorted = [...profiles];
    
    switch (sortType) {
      case 'super_chat':
        sorted.sort((a, b) => b.superChatCount.compareTo(a.superChatCount));
        break;
      case 'popularity':
        sorted.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
      case 'recent':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'online':
        sorted.sort((a, b) {
          if (a.isOnline && !b.isOnline) return -1;
          if (!a.isOnline && b.isOnline) return 1;
          return 0;
        });
        break;
      default:
        // Default sorting by super chat count
        sorted.sort((a, b) => b.superChatCount.compareTo(a.superChatCount));
    }
    
    return sorted;
  }

  // Handle like action
  Future<MatchResult?> likeProfile() async {
    final currentProfile = state.currentProfile;
    if (currentProfile == null) return null;
    
    try {
      // Get current user info
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final fromUserId = authState.currentUser!.user!.userId;
      
      // 이미 좋아요를 누른 프로필인지 확인
      final sentLikesState = ref.read(likesProvider);
      final alreadyLiked = sentLikesState.sentLikes.any((like) => 
        like.toProfileId == currentProfile.id && like.likeType != LikeType.pass
      );
      
      if (alreadyLiked) {
        // 이미 좋아요를 누른 상대
        return MatchResult(
          isMatch: false,
          message: '이미 좋아요를 누른 상대입니다',
        );
      }
      
      // 서버사이드 좋아요 전송 (향상된 검증 및 매칭 처리)
      final sentLike = await _likesService.sendLike(
        fromUserId: fromUserId,
        toProfileId: currentProfile.id,
      );
      
      if (sentLike != null) {
        if (sentLike.isMatched) {
          // 서버에서 자동으로 매칭 처리됨
          final matchId = sentLike.matchId ?? 'match_${DateTime.now().millisecondsSinceEpoch}';
          
          Logger.log('🎉 매칭 화면에서 매칭 성공!', name: 'MatchProvider');
          Logger.log('   프로필: ${currentProfile.name}', name: 'MatchProvider');
          Logger.log('   매치 ID: $matchId', name: 'MatchProvider');
          
          // 알림 추가
          ref.read(notificationProvider.notifier).addMatchNotification(
            matchId: matchId,
            profileId: currentProfile.id,
            profileName: currentProfile.name,
            profileImageUrl: currentProfile.profileImages.isNotEmpty 
                ? currentProfile.profileImages.first 
                : '',
          );
          
          // 매칭 목록에 추가
          final newMatch = MatchModel(
            id: matchId,
            profile: currentProfile,
            matchedAt: DateTime.now(),
            status: MatchStatus.active,
            lastMessage: null,
            lastMessageTime: null,
            hasUnreadMessages: false,
            unreadCount: 0,
          );
          
          ref.read(matchesProvider.notifier).addNewMatch(newMatch);
          
          // 평가한 프로필로 마킹하여 다시 나타나지 않도록 함
          ref.read(discoverProfilesProvider.notifier).markProfileAsEvaluated(currentProfile.id);
          
          _moveToNextProfile();
          return MatchResult.success(
            profile: currentProfile,
            message: '🎉 ${currentProfile.name}님과 매칭되었습니다!',
            matchModel: newMatch,
          );
        } else {
          // 좋아요 전송 성공 (매칭은 아님)
          final likeWithProfile = sentLike.copyWith(profile: currentProfile);
          final currentSentLikes = ref.read(likesProvider).sentLikes;
          ref.read(likesProvider.notifier).state = ref.read(likesProvider).copyWith(
            sentLikes: [...currentSentLikes, likeWithProfile],
          );
          
          // 평가한 프로필로 마킹하여 다시 나타나지 않도록 함
          ref.read(discoverProfilesProvider.notifier).markProfileAsEvaluated(currentProfile.id);
          
          _moveToNextProfile();
          return MatchResult.like();
        }
      } else {
        throw Exception('좋아요 전송에 실패했습니다.');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Handle pass action
  Future<MatchResult?> passProfile() async {
    final currentProfile = state.currentProfile;
    if (currentProfile == null) return null;
    
    try {
      // Get current user info
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final fromUserId = authState.currentUser!.user!.userId;
      
      // Send pass via AWS service
      final passResult = await _likesService.sendPass(
        fromUserId: fromUserId,
        toProfileId: currentProfile.id,
      );
      
      if (passResult != null) {
        // 평가한 프로필로 마킹하여 다시 나타나지 않도록 함
        ref.read(discoverProfilesProvider.notifier).markProfileAsEvaluated(currentProfile.id);
        
        _moveToNextProfile();
        return MatchResult.pass();
      } else {
        throw Exception('패스 처리에 실패했습니다.');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Handle super chat action
  Future<MatchResult?> superChatProfile(String message) async {
    final currentProfile = state.currentProfile;
    if (currentProfile == null) return null;
    
    try {
      // Get current user info
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final fromUserId = authState.currentUser!.user!.userId;
      
      // 서버사이드 슈퍼챗 전송 (원자적 포인트 차감 포함)
      final sentSuperChat = await _superchatService.sendSuperchat(
        fromUserId: fromUserId,
        toProfileId: currentProfile.id,
        message: message,
        pointsUsed: 100, // 기본 슈퍼챗 비용
      );
      
      if (sentSuperChat != null) {
        // 슈퍼챗 전송 성공, 좋아요 목록에 표시용으로 변환
        final superChatAsLike = LikeModel(
          id: sentSuperChat.id,
          fromUserId: fromUserId,
          toProfileId: currentProfile.id,
          likeType: LikeType.superChat,
          message: message,
          isMatched: false,
          createdAt: sentSuperChat.createdAt,
          updatedAt: sentSuperChat.updatedAt,
          profile: currentProfile,
          isRead: false,
        );
        
        // 전송한 좋아요 목록에 추가
        final currentSentLikes = ref.read(likesProvider).sentLikes;
        ref.read(likesProvider.notifier).state = ref.read(likesProvider).copyWith(
          sentLikes: [...currentSentLikes, superChatAsLike],
        );
        
        // 슈퍼챗 수신 알림 (서버에서 자동 처리되지만 로컬 상태 동기화)
        ref.read(notificationProvider.notifier).addSuperChatNotification(
          chatId: sentSuperChat.id,
          profileId: currentProfile.id,
          profileName: currentProfile.name,
          profileImageUrl: currentProfile.profileImages.isNotEmpty 
              ? currentProfile.profileImages.first 
              : '',
          message: message,
        );
        
        // 평가한 프로필로 마킹하여 다시 나타나지 않도록 함
        ref.read(discoverProfilesProvider.notifier).markProfileAsEvaluated(currentProfile.id);
        
        _moveToNextProfile();
        return MatchResult.superChat();
      } else {
        throw Exception('슈퍼챗 전송에 실패했습니다.');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Move to next profile
  void _moveToNextProfile() {
    if (state.currentIndex < state.profiles.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    } else {
      // Load more profiles when reaching the end
      _loadMoreProfiles();
    }
  }

  // Load more profiles
  Future<void> _loadMoreProfiles() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Get current user info
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      final currentUserId = authState.currentUser!.user!.userId;
      
      // Get more profiles from AWS
      final rawProfiles = await _profileService.getDiscoverProfiles(
        currentUserId: currentUserId,
        limit: 20,
      );
      
      // 이미 평가한 프로필과 매칭된 프로필 필터링
      final moreProfiles = await _filterEvaluatedProfiles(rawProfiles, currentUserId);
      
      final allProfiles = [...state.profiles, ...moreProfiles];
      
      // 추가로 로드된 프로필이 없으면 매칭 종료 메시지 설정
      String? errorMessage;
      if (moreProfiles.isEmpty) {
        errorMessage = '오늘의 매칭이 모두 끝났습니다.';
      }
      
      state = state.copyWith(
        profiles: allProfiles,
        isLoading: false,
        error: errorMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 이미 평가한 프로필과 매칭된 프로필 필터링 (연락처 차단 포함)
  Future<List<ProfileModel>> _filterEvaluatedProfiles(List<ProfileModel> profiles, String currentUserId) async {
    try {
      // 보낸 좋아요/패스 목록 조회
      final sentLikes = await _likesService.getSentLikes(userId: currentUserId);
      final evaluatedProfileIds = sentLikes.map((like) => like.toProfileId).toSet();
      
      // 매칭된 프로필 ID 조회
      final matches = await _matchService.getUserMatches(userId: currentUserId);
      final matchedProfileIds = matches.map((match) => match.profile.id).toSet();
      
      // 제외할 프로필 ID 통합
      final excludedProfileIds = {...evaluatedProfileIds, ...matchedProfileIds};
      
      // 연락처 차단 필터링 추가
      final contactService = ContactService();
      final filteredByContactBlocking = <ProfileModel>[];
      
      for (final profile in profiles) {
        // 이미 평가하거나 매칭된 프로필 제외
        if (excludedProfileIds.contains(profile.id)) {
          continue;
        }
        
        // 연락처 차단 확인
        if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) {
          final isBlocked = await contactService.isContactBlocked(profile.phoneNumber!);
          if (isBlocked) {
            Logger.log('차단된 연락처로 인해 프로필 제외: ${profile.name} (${profile.phoneNumber})', 
                name: 'MatchProvider');
            continue;
          }
        }
        
        filteredByContactBlocking.add(profile);
      }
      
      Logger.log('프로필 필터링 완료: 원본 ${profiles.length}개 → 최종 ${filteredByContactBlocking.length}개', 
          name: 'MatchProvider');
      Logger.log('제외된 프로필: 평가 ${evaluatedProfileIds.length}개, 매칭 ${matchedProfileIds.length}개, 연락처차단 ${profiles.length - excludedProfileIds.length - filteredByContactBlocking.length}개', 
          name: 'MatchProvider');
      
      return filteredByContactBlocking;
    } catch (e) {
      Logger.error('프로필 필터링 오류: $e', name: 'MatchProvider');
      // 오류 발생 시 기본 필터링만 수행
      final excludedProfileIds = <String>{};
      try {
        final sentLikes = await _likesService.getSentLikes(userId: currentUserId);
        final evaluatedProfileIds = sentLikes.map((like) => like.toProfileId).toSet();
        final matches = await _matchService.getUserMatches(userId: currentUserId);
        final matchedProfileIds = matches.map((match) => match.profile.id).toSet();
        excludedProfileIds.addAll({...evaluatedProfileIds, ...matchedProfileIds});
      } catch (e2) {
        Logger.error('기본 필터링도 실패: $e2', name: 'MatchProvider');
      }
      
      return profiles
          .where((profile) => !excludedProfileIds.contains(profile.id))
          .toList();
    }
  }

  // Refresh profiles
  Future<void> refreshProfiles() async {
    await _loadInitialProfiles();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset to first profile
  void resetToFirst() {
    state = state.copyWith(currentIndex: 0);
  }

  // Set current index to specific value (for syncing with external components)
  void setCurrentIndex(int index) {
    if (index >= 0 && index < state.profiles.length) {
      state = state.copyWith(currentIndex: index);
    }
  }
}

// Provider instance
final matchProvider = StateNotifierProvider<MatchNotifier, MatchState>((ref) {
  return MatchNotifier(ref);
});

// Helper providers
final currentProfileProvider = Provider<ProfileModel?>((ref) {
  return ref.watch(matchProvider).currentProfile;
});

final hasMoreProfilesProvider = Provider<bool>((ref) {
  return ref.watch(matchProvider).hasMoreProfiles;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(matchProvider).isLoading;
});