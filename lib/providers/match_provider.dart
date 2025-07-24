import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../models/match_model.dart';
import '../models/like_model.dart';
import '../services/aws_profile_service.dart';
import '../services/aws_likes_service.dart';
import '../services/aws_match_service.dart';
import '../services/aws_superchat_service.dart';
import 'notification_provider.dart';
import 'matches_provider.dart';
import 'likes_provider.dart';
import 'enhanced_auth_provider.dart';

// Match Result Model
class MatchResult {
  final bool isMatch;
  final String message;
  final ProfileModel? matchedProfile;
  final DateTime? matchedAt;

  const MatchResult({
    required this.isMatch,
    required this.message,
    this.matchedProfile,
    this.matchedAt,
  });

  factory MatchResult.success({
    required ProfileModel profile,
    required String message,
  }) {
    return MatchResult(
      isMatch: true,
      message: message,
      matchedProfile: profile,
      matchedAt: DateTime.now(),
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
  final AWSSuperchatService _superchatService = AWSSuperchatService();
  
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
        
        // 처음 3개 프로필의 상세 정보 출력
        for (int i = 0; i < discoveredProfiles.length && i < 3; i++) {
          final profile = discoveredProfiles[i];
          print('실제 프로필 ${i + 1}: ${profile.name} (${profile.gender}) - ${profile.age}세, ${profile.location}');
        }
        
        finalProfiles = discoveredProfiles;
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
      
      state = state.copyWith(
        profiles: sortedProfiles,
        currentIndex: 0,
        isLoading: false,
        error: null,
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
      
      // Send like via AWS service
      final sentLike = await _likesService.sendLike(
        fromUserId: fromUserId,
        toProfileId: currentProfile.id,
      );
      
      if (sentLike != null) {
        if (sentLike.isMatched) {
          // Match occurred
          final matchId = 'match_${DateTime.now().millisecondsSinceEpoch}';
          
          // Add notification
          ref.read(notificationProvider.notifier).addMatchNotification(
            matchId: matchId,
            profileId: currentProfile.id,
            profileName: currentProfile.name,
            profileImageUrl: currentProfile.profileImages.first,
          );
          
          // Add to matches provider
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
          
          _moveToNextProfile();
          return MatchResult.success(
            profile: currentProfile,
            message: '${currentProfile.name}님과 매칭되었습니다! 🎉',
          );
        } else {
          // Like sent successfully, add to local state
          final likeWithProfile = sentLike.copyWith(profile: currentProfile);
          final currentSentLikes = ref.read(likesProvider).sentLikes;
          ref.read(likesProvider.notifier).state = ref.read(likesProvider).copyWith(
            sentLikes: [...currentSentLikes, likeWithProfile],
          );
          
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
      
      // Send super chat via AWS service
      final sentSuperChat = await _superchatService.sendSuperchat(
        fromUserId: fromUserId,
        toProfileId: currentProfile.id,
        message: message,
        pointsUsed: 100, // Default super chat cost
      );
      
      if (sentSuperChat != null) {
        // Super chat sent successfully, create LikeModel for local state
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
        
        // Add to sent likes
        final currentSentLikes = ref.read(likesProvider).sentLikes;
        ref.read(likesProvider.notifier).state = ref.read(likesProvider).copyWith(
          sentLikes: [...currentSentLikes, superChatAsLike],
        );
        
        // Send notification for super chat received
        ref.read(notificationProvider.notifier).addSuperChatNotification(
          chatId: sentSuperChat.id,
          profileId: currentProfile.id,
          profileName: currentProfile.name,
          profileImageUrl: currentProfile.profileImages.first,
          message: message,
        );
        
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
      final moreProfiles = await _profileService.getDiscoverProfiles(
        currentUserId: currentUserId,
        limit: 20,
      );
      
      final allProfiles = [...state.profiles, ...moreProfiles];
      
      state = state.copyWith(
        profiles: allProfiles,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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