import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import '../services/aws_profile_service.dart';
import '../utils/logger.dart';
import 'enhanced_auth_provider.dart';

// User State
class UserState {
  final ProfileModel? currentUser;
  final bool isLoading;
  final String? error;
  final String? vipTier;

  const UserState({
    this.currentUser,
    required this.isLoading,
    this.error,
    this.vipTier,
  });

  UserState copyWith({
    ProfileModel? currentUser,
    bool? isLoading,
    String? error,
    String? vipTier,
  }) {
    return UserState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      vipTier: vipTier ?? this.vipTier,
    );
  }

  bool get isLoggedIn => currentUser != null;
  bool get hasError => error != null;
}

// User Provider
class UserNotifier extends StateNotifier<UserState> {
  final Ref _ref;
  final AWSProfileService _profileService = AWSProfileService();

  UserNotifier(this._ref) : super(const UserState(isLoading: false));

  // Initialize current user
  Future<void> initializeUser() async {
    state = state.copyWith(isLoading: true);
    
    try {
      Logger.log('=== 사용자 프로필 로드 디버깅 시작 ===', name: 'UserProvider');
      
      // Get current user from auth provider
      final authState = _ref.read(enhancedAuthProvider);
      Logger.log('인증 상태: ${authState.isSignedIn}', name: 'UserProvider');
      
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        Logger.log('❌ 사용자 인증 실패', name: 'UserProvider');
        state = state.copyWith(isLoading: false, error: '로그인이 필요합니다.');
        return;
      }
      
      final userId = authState.currentUser!.user!.userId;
      final username = authState.currentUser!.user!.username;
      Logger.log('✅ 인증된 사용자 - userId: $userId, username: $username', name: 'UserProvider');
      
      // Load user profile from AWS
      Logger.log('프로필 로드 시도: userId=$userId', name: 'UserProvider');
      
      ProfileModel? currentUser;
      try {
        Logger.log('📞 AWS ProfileService.getProfile() 호출 시작', name: 'UserProvider');
        
        // DynamoDB에서 프로필 조회 (우선순위 1)
        currentUser = await _profileService.getProfile(userId).timeout(
          const Duration(seconds: 10), // DynamoDB 조회를 위해 타임아웃 증가
          onTimeout: () {
            Logger.log('⏰ DynamoDB 프로필 로드 타임아웃 (10초)', name: 'UserProvider');
            return null;
          },
        );
        
        Logger.log('🔍 getProfile() 반환 결과:', name: 'UserProvider');
        if (currentUser != null) {
          Logger.log('   반환된 프로필 ID: ${currentUser.id}', name: 'UserProvider');
          Logger.log('   반환된 프로필 이름: ${currentUser.name}', name: 'UserProvider');
          Logger.log('   반환된 프로필 나이: ${currentUser.age}', name: 'UserProvider');
          Logger.log('   반환된 프로필 성별: ${currentUser.gender}', name: 'UserProvider');
          Logger.log('   반환된 프로필 직업: ${currentUser.occupation}', name: 'UserProvider');

        } else {
          Logger.log('   반환된 프로필: null', name: 'UserProvider');
        }
        
      } catch (e) {
        Logger.error('❌ DynamoDB 프로필 로드 오류: $e', name: 'UserProvider');
        currentUser = null;
      }
      
      if (currentUser != null) {
        Logger.log('✅ DynamoDB에서 프로필 로드 성공!', name: 'UserProvider');
        Logger.log('   이름: ${currentUser.name}', name: 'UserProvider');
        Logger.log('   나이: ${currentUser.age}세', name: 'UserProvider');
        Logger.log('   성별: ${currentUser.gender}', name: 'UserProvider');
        Logger.log('   직업: ${currentUser.occupation}', name: 'UserProvider');
        Logger.log('   위치: ${currentUser.location}', name: 'UserProvider');
        Logger.log('   프로필 이미지 수: ${currentUser.profileImages.length}', name: 'UserProvider');
        Logger.log('   좋아요 수: ${currentUser.likeCount}', name: 'UserProvider');
        Logger.log('   슈퍼챗 수: ${currentUser.superChatCount}', name: 'UserProvider');
        Logger.log('   VIP 여부: ${currentUser.isVip}', name: 'UserProvider');
        Logger.log('   인증 여부: ${currentUser.isVerified}', name: 'UserProvider');

        final prefs = await SharedPreferences.getInstance();
        prefs.setString("profile_image", currentUser.primaryImage);

        if (currentUser.profileImages.isNotEmpty) {
          Logger.log('   첫 번째 이미지: ${currentUser.profileImages.first}', name: 'UserProvider');
        }
      } else {
        Logger.log('⚠️  DynamoDB에 프로필 없음 - 기본 프로필로 표시', name: 'UserProvider');
      }
      
      // AWS에서 프로필을 찾지 못한 경우 기본 프로필 생성
      final finalUser = currentUser ?? _createBasicProfile(userId, authState.currentUser!.user!.username);
      
      Logger.log('🎯 최종 사용자 프로필:', name: 'UserProvider');
      Logger.log('   ID: ${finalUser.id}', name: 'UserProvider');
      Logger.log('   이름: ${finalUser.name}', name: 'UserProvider');
      Logger.log('   나이: ${finalUser.age}', name: 'UserProvider');
      Logger.log('   성별: ${finalUser.gender}', name: 'UserProvider');
      Logger.log('   직업: ${finalUser.occupation}', name: 'UserProvider');
      Logger.log('   위치: ${finalUser.location}', name: 'UserProvider');
      
      state = state.copyWith(
        currentUser: finalUser,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      Logger.error('사용자 프로필 로드 실패: $e', name: 'UserProvider');
      state = state.copyWith(
        isLoading: false,
        error: '프로필을 불러올 수 없습니다: ${e.toString()}',
      );
    }
  }
  
  /// Create basic profile when AWS profile is not available
  ProfileModel _createBasicProfile(String userId, String username) {
    Logger.log('기본 프로필 생성: userId=$userId, username=$username', name: 'UserProvider');
    return ProfileModel(
      id: userId,
      name: username,
      age: 25, // Default age
      location: '서울', // Default location
      profileImages: [], // Empty images list
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      bio: '안녕하세요!',
      occupation: '미설정', // 직업 기본값 추가
      education: '미설정', // 학력 기본값 추가
      height: 170, // 키 기본값 추가
      bodyType: '보통', // 체형 기본값 추가
      smoking: '미설정',
      drinking: '미설정',
      religion: '미설정',
      mbti: '미설정',
      hobbies: [], // 취미 기본값
      badges: [], // 배지 기본값
      isVip: false,
      isPremium: false,
      isVerified: false,
      isOnline: true,
      likeCount: 0, // 좋아요 수 기본값
      superChatCount: 0, // 슈퍼챗 수 기본값
    );
  }

  // Update user profile
  Future<bool> updateProfile(ProfileModel updatedProfile) async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Update profile in AWS
      final profileService = AWSProfileService();
      await profileService.updateProfile(
        profileId: updatedProfile.id,
        additionalData: updatedProfile.toJson(),
      );
      
      final updatedUser = updatedProfile.copyWith(
        updatedAt: DateTime.now(),
      );
      
      state = state.copyWith(
        currentUser: updatedUser,
        isLoading: false,
        error: null,
      );
      
      return true;
    } catch (e) {
      Logger.error('프로필 업데이트 실패: $e', name: 'UserProvider');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// VIP 상태 업데이트
  Future<void> updateVipStatus({
    required bool isVip,
    DateTime? vipStartDate,
    DateTime? vipEndDate,
    String? vipTier,
  }) async {
    if (state.currentUser == null) return;
    
    try {
      Logger.log('VIP 상태 업데이트: isVip=$isVip, tier=$vipTier', name: 'UserProvider');
      
      // Create updated profile with VIP info
      final updatedProfile = state.currentUser!.copyWith(
        isVip: isVip,
        isPremium: isVip && vipTier == 'GOLD',
        updatedAt: DateTime.now(),
      );
      
      // Update AWS profile
      final profileService = AWSProfileService();
      await profileService.updateProfile(
        profileId: updatedProfile.id,
        additionalData: {
          'isVip': isVip,
          'isPremium': isVip && vipTier == 'GOLD',
          'vipStartDate': vipStartDate?.toIso8601String(),
          'vipEndDate': vipEndDate?.toIso8601String(),
          'vipTier': vipTier,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Update local state
      state = state.copyWith(
        currentUser: updatedProfile,
        vipTier: vipTier,
        error: null,
      );
      
      Logger.log('VIP 상태 업데이트 완료', name: 'UserProvider');
    } catch (e) {
      Logger.error('VIP 상태 업데이트 실패: $e', name: 'UserProvider');
      state = state.copyWith(error: 'VIP 상태 업데이트 실패: ${e.toString()}');
    }
  }

  /// VIP 상태 확인
  bool get isVip {
    return state.currentUser?.isVip == true;
  }

  /// VIP 만료일 확인 (추후 프로필에 해당 필드 추가 시 사용)
  DateTime? get vipExpirationDate {
    // TODO: ProfileModel에 vipEndDate 필드 추가 후 구현
    return null;
  }

  // Update profile photos
  Future<bool> updateProfilePhotos(List<String> newPhotos) async {
    if (state.currentUser == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      final updatedUser = state.currentUser!.copyWith(
        profileImages: newPhotos,
        updatedAt: DateTime.now(),
      );
      
      state = state.copyWith(
        currentUser: updatedUser,
        isLoading: false,
        error: null,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '에러 발생: ${e.toString()}',
      );
      return false;
    }
  }

  // Delete profile photo
  Future<bool> deleteProfilePhoto(String photoUrl) async {
    if (state.currentUser == null) return false;
    
    final currentPhotos = List<String>.from(state.currentUser!.profileImages);
    if (currentPhotos.length <= 1) {
      state = state.copyWith(error: '프로필 사진은 최소 1개 이상이어야 합니다.');
      return false;
    }
    
    state = state.copyWith(isLoading: true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      currentPhotos.remove(photoUrl);
      
      final updatedUser = state.currentUser!.copyWith(
        profileImages: currentPhotos,
        updatedAt: DateTime.now(),
      );
      
      state = state.copyWith(
        currentUser: updatedUser,
        isLoading: false,
        error: null,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '에러 발생: ${e.toString()}',
      );
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Logout
  void logout() {
    state = const UserState(isLoading: false);
  }

  // Private helper methods
  ProfileModel _createCurrentUserMock() {
    final now = DateTime.now();
    return ProfileModel(
      id: 'current_user',
      name: '홍길동',
      age: 32,
      location: '서울',
      profileImages: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      ],
      bio: '안녕하세요! 홍길동입니다.',
      occupation: 'IT 개발자',
      education: '대학교 컴퓨터 공학과',
      height: 175,
      bodyType: '보통',
      smoking: '금연',
      drinking: '일정 수준',
      religion: '기독교',
      mbti: 'ENFP',
      hobbies: ['독서', '영화', '음악', '여행'],
      badges: ['초보자'],
      isVip: true,
      isPremium: false,
      isVerified: true,
      isOnline: true,
      lastSeen: now,
      likeCount: 123,
      superChatCount: 45,
      createdAt: now.subtract(const Duration(days: 180)),
      updatedAt: now,
    );
  }

  /// DynamoDB에서 프로필 로드
  Future<void> loadProfileFromDynamoDB(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final profileService = AWSProfileService();
      final profile = await profileService.getProfile(userId);
      
      if (profile != null) {
        state = state.copyWith(
          currentUser: profile,
          isLoading: false,
        );
        Logger.log('DynamoDB에서 프로필 로드 완료: ${profile.name}', name: 'UserProvider');
      } else {
        // DynamoDB에 프로필이 없으면 기본 프로필 생성
        final authState = _ref.read(enhancedAuthProvider);
        final username = authState.currentUser?.user?.username ?? 'Unknown User';
        final basicProfile = _createBasicProfile(userId, username);
        state = state.copyWith(
          currentUser: basicProfile,
          isLoading: false,
        );
        Logger.log('기본 프로필 생성: $userId, username: $username', name: 'UserProvider');
      }
      
    } catch (e) {
      Logger.error('프로필 로드 실패: $e', name: 'UserProvider');
      state = state.copyWith(
        isLoading: false,
        error: '프로필을 로드할 수 없습니다: ${e.toString()}',
      );
    }
  }

  /// 프로필 새로고침 (DynamoDB에서 최신 데이터 가져오기)
  Future<void> refreshProfile() async {
    if (state.currentUser?.id != null) {
      await loadProfileFromDynamoDB(state.currentUser!.id);
    }
  }
}

// Provider instances
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});

// Helper providers
final currentUserProvider = Provider<ProfileModel?>((ref) {
  return ref.watch(userProvider).currentUser;
});

final isUserLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isLoading;
});

final userErrorProvider = Provider<String?>((ref) {
  return ref.watch(userProvider).error;
});