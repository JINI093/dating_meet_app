import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_model.dart';
import '../services/aws_profile_service.dart';
import '../utils/logger.dart';
import 'enhanced_auth_provider.dart';

/// 현재 사용자 프로필 상태
class CurrentUserProfileState {
  final ProfileModel? profile;
  final bool isLoading;
  final String? error;
  final bool isProfileCreated;

  const CurrentUserProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.isProfileCreated = false,
  });

  CurrentUserProfileState copyWith({
    ProfileModel? profile,
    bool? isLoading,
    String? error,
    bool? isProfileCreated,
  }) {
    return CurrentUserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isProfileCreated: isProfileCreated ?? this.isProfileCreated,
    );
  }
}

/// 현재 사용자 프로필 관리
class CurrentUserProfileNotifier extends StateNotifier<CurrentUserProfileState> {
  final Ref ref;
  final AWSProfileService _profileService = AWSProfileService();
  
  CurrentUserProfileNotifier(this.ref) : super(const CurrentUserProfileState());

  /// 프로필 초기화 및 로드
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. 프로필 서비스 초기화
      await _profileService.initialize();

      // 2. 현재 사용자 확인
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        state = state.copyWith(
          isLoading: false,
          isProfileCreated: false,
        );
        return;
      }

      final userId = authState.currentUser!.user!.userId;

      // 3. 프로필 존재 여부 확인
      final prefs = await SharedPreferences.getInstance();
      final profileCreated = prefs.getBool('profile_created') ?? false;
      final profileId = prefs.getString('profile_id');

      if (profileCreated && profileId != null) {
        // 4. 프로필 로드
        await loadProfile();
      } else {
        // 5. 서버에서 프로필 확인
        Logger.log('=== CurrentUserProfile 초기화 디버깅 ===', name: 'CurrentUserProfileProvider');
        Logger.log('사용자 ID: $userId', name: 'CurrentUserProfileProvider');
        
        final profile = await _profileService.getProfileByUserId(userId);
        
        Logger.log('프로필 존재: ${profile != null}', name: 'CurrentUserProfileProvider');
        
        if (profile != null) {
          Logger.log('프로필 이름: ${profile.name}', name: 'CurrentUserProfileProvider');
          Logger.log('프로필 성별: "${profile.gender}"', name: 'CurrentUserProfileProvider');
          Logger.log('프로필 성별 null 여부: ${profile.gender == null}', name: 'CurrentUserProfileProvider');
          Logger.log('프로필 성별 비어있음: ${profile.gender?.isEmpty ?? true}', name: 'CurrentUserProfileProvider');
          
          // 프로필이 존재하면 로컬에 저장
          await prefs.setBool('profile_created', true);
          await prefs.setString('profile_id', profile.id);
          
          state = state.copyWith(
            profile: profile,
            isProfileCreated: true,
            isLoading: false,
          );
        } else {
          Logger.log('프로필 없음 - 생성 필요', name: 'CurrentUserProfileProvider');
          state = state.copyWith(
            isProfileCreated: false,
            isLoading: false,
          );
        }
      }
    } catch (e) {
      Logger.error('프로필 초기화 오류', error: e, name: 'CurrentUserProfileProvider');
      state = state.copyWith(
        isLoading: false,
        error: '프로필을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 프로필 로드
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authState = ref.read(enhancedAuthProvider);
      if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final userId = authState.currentUser!.user!.userId;
      
      Logger.log('=== CurrentUserProfile loadProfile 디버깅 ===', name: 'CurrentUserProfileProvider');
      Logger.log('사용자 ID: $userId', name: 'CurrentUserProfileProvider');
      
      final profile = await _profileService.getProfileByUserId(userId);
      
      Logger.log('로드된 프로필 존재: ${profile != null}', name: 'CurrentUserProfileProvider');

      if (profile != null) {
        Logger.log('로드된 프로필 이름: ${profile.name}', name: 'CurrentUserProfileProvider');
        Logger.log('로드된 프로필 성별: "${profile.gender}"', name: 'CurrentUserProfileProvider');
        Logger.log('로드된 프로필 성별 타입: ${profile.gender.runtimeType}', name: 'CurrentUserProfileProvider');
        
        // DynamoDB에서 정상적으로 성별 데이터를 가져왔는지 확인
        if (profile.name == "시아" && profile.gender == "여성") {
          Logger.log('✅ DynamoDB 데이터 정상 로드 - 실제 사용자 데이터', name: 'CurrentUserProfileProvider');
        } else if (profile.name.startsWith("Test User")) {
          Logger.log('⚠️ REST API 테스트 데이터 로드 - DynamoDB 데이터 무시됨', name: 'CurrentUserProfileProvider');
        }
        
        state = state.copyWith(
          profile: profile,
          isProfileCreated: true,
          isLoading: false,
        );

        // 온라인 상태 업데이트
        await _profileService.updateOnlineStatus(profile.id, true);
      } else {
        Logger.log('프로필 로드 실패', name: 'CurrentUserProfileProvider');
        state = state.copyWith(
          profile: null,
          isProfileCreated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      Logger.error('프로필 로드 오류', error: e, name: 'CurrentUserProfileProvider');
      state = state.copyWith(
        isLoading: false,
        error: '프로필을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 프로필 새로고침
  Future<void> refreshProfile() async {
    if (state.profile != null) {
      await loadProfile();
    }
  }

  /// 프로필 생성 완료 처리
  void setProfileCreated(ProfileModel profile) {
    state = state.copyWith(
      profile: profile,
      isProfileCreated: true,
    );
  }

  /// 프로필 업데이트
  Future<bool> updateProfile({
    String? name,
    int? age,
    String? location,
    List<File>? newProfileImages,
    List<String>? existingImageUrls,
    String? bio,
    String? occupation,
    String? education,
    int? height,
    String? bodyType,
    String? smoking,
    String? drinking,
    String? religion,
    String? mbti,
    List<String>? hobbies,
    Map<String, dynamic>? additionalData,
  }) async {
    if (state.profile == null) {
      state = state.copyWith(error: '프로필이 없습니다.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedProfile = await _profileService.updateProfile(
        profileId: state.profile!.id,
        name: name,
        age: age,
        location: location,
        newProfileImages: newProfileImages,
        existingImageUrls: existingImageUrls,
        bio: bio,
        occupation: occupation,
        education: education,
        height: height,
        bodyType: bodyType,
        smoking: smoking,
        drinking: drinking,
        religion: religion,
        mbti: mbti,
        hobbies: hobbies,
        additionalData: additionalData,
      );

      if (updatedProfile != null) {
        state = state.copyWith(
          profile: updatedProfile,
          isLoading: false,
        );
        return true;
      } else {
        throw Exception('프로필 업데이트에 실패했습니다.');
      }
    } catch (e) {
      Logger.error('프로필 업데이트 오류', error: e, name: 'CurrentUserProfileProvider');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().contains('Exception:') 
            ? e.toString().replaceAll('Exception:', '').trim()
            : '프로필 업데이트에 실패했습니다.',
      );
      return false;
    }
  }

  /// 프로필 이미지 삭제
  Future<bool> deleteProfileImage(String imageUrl) async {
    if (state.profile == null) return false;

    try {
      await _profileService.deleteProfileImage(imageUrl);
      
      // 로컬 상태 업데이트
      final updatedImages = state.profile!.profileImages
          .where((img) => img != imageUrl)
          .toList();
      
      final updatedProfile = state.profile!.copyWith(
        profileImages: updatedImages,
      );
      
      state = state.copyWith(profile: updatedProfile);
      return true;
    } catch (e) {
      Logger.error('프로필 이미지 삭제 오류', error: e, name: 'CurrentUserProfileProvider');
      return false;
    }
  }

  /// 온라인 상태 업데이트
  Future<void> updateOnlineStatus(bool isOnline) async {
    if (state.profile == null) return;

    try {
      await _profileService.updateOnlineStatus(state.profile!.id, isOnline);
      
      final updatedProfile = state.profile!.copyWith(
        isOnline: isOnline,
        lastSeen: DateTime.now(),
      );
      
      state = state.copyWith(profile: updatedProfile);
    } catch (e) {
      Logger.error('온라인 상태 업데이트 오류', error: e, name: 'CurrentUserProfileProvider');
    }
  }

  /// 프로필 초기화
  void reset() {
    state = const CurrentUserProfileState();
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 현재 사용자 프로필 프로바이더
final currentUserProfileProvider = StateNotifierProvider<CurrentUserProfileNotifier, CurrentUserProfileState>(
  (ref) => CurrentUserProfileNotifier(ref),
);

/// 프로필 생성 여부 프로바이더
final isProfileCreatedProvider = Provider<bool>((ref) {
  final profileState = ref.watch(currentUserProfileProvider);
  return profileState.isProfileCreated;
});

/// 현재 프로필 프로바이더
final currentProfileProvider = Provider<ProfileModel?>((ref) {
  final profileState = ref.watch(currentUserProfileProvider);
  return profileState.profile;
});

/// 프로필 완성도 프로바이더
final profileCompletionProvider = Provider<double>((ref) {
  final profile = ref.watch(currentProfileProvider);
  return profile?.profileCompletionRate ?? 0.0;
});