import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../models/auth_result.dart' as AppAuthResult;
import './kakao_login_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 카카오 로그인과 AWS Cognito를 연동하는 서비스
class AWSKakaoAuthService {
  static final AWSKakaoAuthService _instance = AWSKakaoAuthService._internal();
  factory AWSKakaoAuthService() => _instance;
  AWSKakaoAuthService._internal();

  final KakaoLoginService _kakaoService = KakaoLoginService();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // 저장 키
  static const String _kakaoUserIdKey = 'kakao_cognito_user_id';
  static const String _cognitoUserIdKey = 'cognito_user_id';
  static const String _cognitoUsernameKey = 'cognito_username';

  /// 카카오 로그인 후 Cognito 연동
  Future<AppAuthResult.AuthResult> signInWithKakao() async {
    try {
      print('=== 카카오 - Cognito 연동 로그인 시작 ===');
      
      // 0. 기존 Cognito 세션이 있으면 먼저 로그아웃
      try {
        await Amplify.Auth.getCurrentUser();
        print('기존 Cognito 세션 발견, 로그아웃 후 카카오 로그인 진행');
        await Amplify.Auth.signOut();
      } catch (e) {
        print('기존 세션 없음 또는 이미 로그아웃됨');
      }
      
      // 1. 카카오 로그인 먼저 수행
      final kakaoResult = await _kakaoService.signIn();
      
      if (!kakaoResult.success) {
        return kakaoResult;
      }
      
      // 2. 카카오 사용자 정보 추출
      final kakaoUserId = kakaoResult.metadata?['kakao_user_id'] ?? '';
      final nickname = kakaoResult.metadata?['nickname'] ?? '';
      final email = kakaoResult.metadata?['email'];
      final profileImage = kakaoResult.metadata?['profile_image'];
      
      if (kakaoUserId.isEmpty) {
        return AppAuthResult.AuthResult.failure(error: '카카오 사용자 정보를 가져올 수 없습니다.');
      }
      
      print('카카오 사용자 정보: ID=$kakaoUserId, 닉네임=$nickname');
      
      // 3. 기존에 연동된 Cognito 사용자 확인
      final existingCognitoUsername = await _getLinkedCognitoUser(kakaoUserId);
      
      if (existingCognitoUsername != null) {
        // 3-1. 기존 사용자로 로그인 시도
        print('기존 연동 사용자 발견: $existingCognitoUsername');
        
        try {
          final result = await _signInExistingUser(existingCognitoUsername, kakaoUserId, kakaoResult);
          if (result.success) {
            return result;
          }
        } catch (e) {
          print('기존 사용자 로그인 실패, 연동 정보 삭제 후 재시도: $e');
          // 기존 연동 정보가 잘못되었을 수 있으므로 삭제
          await _clearLinkedUser(kakaoUserId);
        }
      }
      
      // 3-2. 새 사용자 생성 또는 연동
      print('새 사용자 생성 또는 기존 연동 정보 복구');
      return await _createOrLinkUser(kakaoUserId, nickname, email, profileImage, kakaoResult);
      
    } catch (e) {
      print('카카오-Cognito 연동 로그인 실패: $e');
      
      // 카카오 로그인 실패 시 기존 Cognito 세션 정리
      try {
        await Amplify.Auth.getCurrentUser();
        print('기존 Cognito 세션 발견, 로그아웃 처리');
        await Amplify.Auth.signOut();
      } catch (signOutError) {
        print('기존 세션 없음 또는 로그아웃 실패: $signOutError');
      }
      
      return AppAuthResult.AuthResult.failure(error: '카카오 로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 기존 연동된 Cognito 사용자 확인
  Future<String?> _getLinkedCognitoUser(String kakaoUserId) async {
    try {
      final key = '${_kakaoUserIdKey}_$kakaoUserId';
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('연동 사용자 확인 실패: $e');
      return null;
    }
  }

  /// 잘못된 연동 정보 삭제
  Future<void> _clearLinkedUser(String kakaoUserId) async {
    try {
      final key = '${_kakaoUserIdKey}_$kakaoUserId';
      await _secureStorage.delete(key: key);
      await _secureStorage.delete(key: _cognitoUsernameKey);
      await _secureStorage.delete(key: _cognitoUserIdKey);
      print('연동 정보 삭제 완료: $kakaoUserId');
    } catch (e) {
      print('연동 정보 삭제 실패: $e');
    }
  }

  /// 기존 카카오 사용자명 패턴 찾기
  Future<String?> _findExistingKakaoUser(String kakaoUserId) async {
    try {
      // 가능한 username 패턴들을 시도해보기
      final patterns = [
        'kakao_${kakaoUserId}_629317',  // 로그에서 보이는 기존 패턴
        'kakao_${kakaoUserId}_',        // 접두사만으로 검색
      ];
      
      for (final pattern in patterns) {
        try {
          // 패턴 매칭으로 기존 사용자 로그인 시도
          final tempPassword = 'Kakao#${kakaoUserId}2024!';
          final result = await Amplify.Auth.signIn(
            username: pattern,
            password: tempPassword,
          );
          
          if (result.isSignedIn) {
            // 로그인 성공 시 바로 로그아웃하고 username 반환
            await Amplify.Auth.signOut();
            print('기존 사용자 패턴 발견: $pattern');
            return pattern;
          }
        } catch (e) {
          // 이 패턴은 실패, 다음 패턴 시도
          continue;
        }
      }
      
      return null;
    } catch (e) {
      print('기존 카카오 사용자 검색 실패: $e');
      return null;
    }
  }

  /// 카카오 사용자와 Cognito 사용자 연동 저장
  Future<void> _saveUserLink(String kakaoUserId, String cognitoUsername, String cognitoUserId) async {
    try {
      // 카카오 ID -> Cognito username 매핑
      await _secureStorage.write(
        key: '${_kakaoUserIdKey}_$kakaoUserId',
        value: cognitoUsername,
      );
      
      // Cognito 정보 저장
      await _secureStorage.write(key: _cognitoUsernameKey, value: cognitoUsername);
      await _secureStorage.write(key: _cognitoUserIdKey, value: cognitoUserId);
      
      print('사용자 연동 정보 저장 완료');
    } catch (e) {
      print('사용자 연동 정보 저장 실패: $e');
    }
  }

  /// 기존 사용자로 로그인
  Future<AppAuthResult.AuthResult> _signInExistingUser(
    String cognitoUsername, 
    String kakaoUserId,
    AppAuthResult.AuthResult kakaoResult
  ) async {
    try {
      print('기존 사용자 비밀번호 로그인 시도: $cognitoUsername');
      
      // CUSTOM_AUTH가 비활성화되어 있으므로 바로 비밀번호 로그인 시도
      return await _tryPasswordlessSignIn(cognitoUsername, kakaoUserId, kakaoResult);
    } catch (e) {
      print('기존 사용자 로그인 실패: $e');
      // 실패 시 새 사용자 생성 시도
      return await _createOrLinkUser(
        kakaoUserId, 
        kakaoResult.metadata?['nickname'] ?? '',
        kakaoResult.metadata?['email'],
        kakaoResult.metadata?['profile_image'],
        kakaoResult
      );
    }
  }

  /// 비밀번호 없이 로그인 시도
  Future<AppAuthResult.AuthResult> _tryPasswordlessSignIn(
    String cognitoUsername,
    String kakaoUserId,
    AppAuthResult.AuthResult kakaoResult
  ) async {
    try {
      // 임시 비밀번호 생성 (카카오 ID 기반)
      final tempPassword = 'Kakao#${kakaoUserId}2024!';
      
      final result = await Amplify.Auth.signIn(
        username: cognitoUsername,
        password: tempPassword,
      );
      
      if (result.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        
        return AppAuthResult.AuthResult.success(
          user: user,
          loginMethod: 'KAKAO',
          accessToken: kakaoResult.accessToken,
          refreshToken: kakaoResult.refreshToken,
          metadata: kakaoResult.metadata,
        );
      }
      
      throw Exception('비밀번호 로그인 실패');
    } catch (e) {
      print('비밀번호 없는 로그인 실패: $e');
      throw e;
    }
  }

  /// 새 사용자 생성 또는 기존 사용자 연동
  Future<AppAuthResult.AuthResult> _createOrLinkUser(
    String kakaoUserId,
    String nickname,
    String? email,
    String? profileImage,
    AppAuthResult.AuthResult kakaoResult
  ) async {
    try {
      // 먼저 기존에 동일한 카카오 ID로 만들어진 사용자가 있는지 확인
      final existingUsername = await _findExistingKakaoUser(kakaoUserId);
      
      if (existingUsername != null) {
        print('기존 카카오 사용자 발견, 연동 정보 복구: $existingUsername');
        // 기존 사용자 로그인 시도
        try {
          final result = await _signInExistingUser(existingUsername, kakaoUserId, kakaoResult);
          if (result.success) {
            // 연동 정보 다시 저장
            final user = await Amplify.Auth.getCurrentUser();
            await _saveUserLink(kakaoUserId, existingUsername, user.userId);
            return result;
          }
        } catch (e) {
          print('기존 사용자 로그인 재시도 실패: $e');
        }
      }
      
      // 새 사용자 생성
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final username = 'kakao_${kakaoUserId}_${timestamp.substring(timestamp.length - 6)}';
      
      // 임시 이메일 생성 (이메일이 없는 경우)
      final userEmail = email ?? 'kakao_${kakaoUserId}@kakao.local';
      
      // 임시 전화번호 생성 (필수 속성)
      final tempPhoneNumber = '+821012345${kakaoUserId.substring(kakaoUserId.length - 3)}';
      
      // 임시 비밀번호 생성
      final tempPassword = 'Kakao#${kakaoUserId}2024!';
      
      print('새 Cognito 사용자 생성: $username');
      
      // Cognito 사용자 생성 (필수 속성 포함)
      final signUpResult = await Amplify.Auth.signUp(
        username: username,
        password: tempPassword,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: userEmail,
            AuthUserAttributeKey.name: nickname,
            AuthUserAttributeKey.preferredUsername: nickname,
            AuthUserAttributeKey.phoneNumber: tempPhoneNumber,
            // 카카오 ID는 username에 포함되어 있으므로 별도 저장 불필요
          },
        ),
      );
      
      if (signUpResult.isSignUpComplete) {
        // 자동 로그인
        final signInResult = await Amplify.Auth.signIn(
          username: username,
          password: tempPassword,
        );
        
        if (signInResult.isSignedIn) {
          final user = await Amplify.Auth.getCurrentUser();
          
          // 연동 정보 저장
          await _saveUserLink(kakaoUserId, username, user.userId);
          
          return AppAuthResult.AuthResult.success(
            user: user,
            loginMethod: 'KAKAO',
            accessToken: kakaoResult.accessToken,
            refreshToken: kakaoResult.refreshToken,
            metadata: {
              ...?kakaoResult.metadata,
              'is_new_user': true,
            },
          );
        }
      }
      
      throw Exception('사용자 생성 후 로그인 실패');
      
    } catch (e) {
      print('새 사용자 생성 실패: $e');
      
      // UsernameExistsException 처리
      if (e.toString().contains('UsernameExistsException')) {
        // 이미 존재하는 사용자 - 다시 시도
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final newUsername = 'kakao_${kakaoUserId}_${timestamp}';
        
        return await _createOrLinkUser(
          kakaoUserId,
          nickname,
          email,
          profileImage,
          kakaoResult
        );
      }
      
      return AppAuthResult.AuthResult.failure(error: '사용자 생성 중 오류가 발생했습니다: $e');
    }
  }
  
  /// 연동 해제
  Future<void> unlinkKakaoUser() async {
    try {
      // 카카오 로그아웃
      await _kakaoService.signOut();
      
      // 연동 정보 삭제
      final cognitoUsername = await _secureStorage.read(key: _cognitoUsernameKey);
      if (cognitoUsername != null) {
        await _secureStorage.deleteAll();
      }
      
      print('카카오 연동 해제 완료');
    } catch (e) {
      print('카카오 연동 해제 실패: $e');
    }
  }
}