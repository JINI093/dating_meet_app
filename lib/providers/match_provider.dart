import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../models/match_model.dart';
import '../models/like_model.dart';
import '../models/superchat_model.dart';
import '../services/aws_profile_service.dart';
import '../services/aws_likes_service.dart';
import '../services/enhanced_superchat_service.dart';
import '../services/aws_match_service.dart';
import '../utils/logger.dart';
import 'notification_provider.dart';
import 'matches_provider.dart';
import 'likes_provider.dart';
import 'enhanced_auth_provider.dart';
import 'discover_profiles_provider.dart';

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
      // 내 프로필에서 성별 조회
      final myProfile = await _profileService.getProfile(currentUserId);
      String? targetGender = filters['gender'] as String?;
      if (targetGender == null && myProfile != null && myProfile.gender != null) {
        if (myProfile.gender == '남성' || myProfile.gender == 'M') {
          targetGender = '여성';
        } else if (myProfile.gender == '여성' || myProfile.gender == 'F') {
          targetGender = '남성';
        }
      }
      // Apply filters to AWS query
      var filteredProfiles = await _profileService.getDiscoverProfiles(
        currentUserId: currentUserId,
        gender: targetGender,
        minAge: filters['minAge'] as int?,
        maxAge: filters['maxAge'] as int?,
        maxDistance: filters['distance'] as double?,
        location: filters['region'] as String?,
        limit: 20,
      );
      
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

  /// 이미 평가한 프로필과 매칭된 프로필 필터링
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
      
      print('제외할 프로필 ID: ${excludedProfileIds.length}개 (평가: ${evaluatedProfileIds.length}개, 매칭: ${matchedProfileIds.length}개)');
      
      // 필터링 수행
      final filteredProfiles = profiles
          .where((profile) => !excludedProfileIds.contains(profile.id))
          .toList();
      
      return filteredProfiles;
    } catch (e) {
      print('프로필 필터링 오류: $e');
      // 오류 발생 시 원래 프로필 목록 반환
      return profiles;
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