import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/auth_result.dart' as AppAuthResult;
import './google_login_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 구글 로그인과 AWS Cognito를 연동하는 서비스
class AWSGoogleAuthService {
  static final AWSGoogleAuthService _instance = AWSGoogleAuthService._internal();
  factory AWSGoogleAuthService() => _instance;
  AWSGoogleAuthService._internal();

  final GoogleLoginService _googleService = GoogleLoginService();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // 저장 키
  static const String _googleUserIdKey = 'google_cognito_user_id';
  static const String _cognitoUserIdKey = 'cognito_user_id';
  static const String _cognitoUsernameKey = 'cognito_username';

  /// 구글 로그인 후 Cognito 연동
  Future<AppAuthResult.AuthResult> signInWithGoogle() async {
    try {
      print('=== 구글 - Cognito 연동 로그인 시작 ===');
      
      // 1. 구글 로그인 먼저 수행
      final googleResult = await _googleService.signIn();
      
      if (!googleResult.success) {
        return googleResult;
      }
      
      // 2. 구글 사용자 정보 추출
      final googleUserId = googleResult.metadata?['google_user_id'] ?? '';
      final displayName = googleResult.metadata?['displayName'] ?? '';
      final email = googleResult.metadata?['email'];
      final photoUrl = googleResult.metadata?['photoUrl'];
      final name = googleResult.metadata?['name'];
      
      if (googleUserId.isEmpty) {
        return AppAuthResult.AuthResult.failure(error: '구글 사용자 정보를 가져올 수 없습니다.');
      }
      
      print('구글 사용자 정보: ID=$googleUserId, 이름=$displayName');
      
      // 3. 기존에 연동된 Cognito 사용자 확인
      final existingCognitoUsername = await _getLinkedCognitoUser(googleUserId);
      
      if (existingCognitoUsername != null) {
        // 3-1. 기존 사용자로 로그인 시도
        print('기존 연동 사용자 발견: $existingCognitoUsername');
        return await _signInExistingUser(existingCognitoUsername, googleUserId, googleResult);
      } else {
        // 3-2. 새 사용자 생성 또는 연동
        print('새 사용자 생성 필요');
        return await _createOrLinkUser(googleUserId, displayName, name, email, photoUrl, googleResult);
      }
      
    } catch (e) {
      print('구글-Cognito 연동 로그인 실패: $e');
      return AppAuthResult.AuthResult.failure(error: '구글 로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 기존 연동된 Cognito 사용자 확인
  Future<String?> _getLinkedCognitoUser(String googleUserId) async {
    try {
      final key = '${_googleUserIdKey}_$googleUserId';
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('연동 사용자 확인 실패: $e');
      return null;
    }
  }

  /// 구글 사용자와 Cognito 사용자 연동 저장
  Future<void> _saveUserLink(String googleUserId, String cognitoUsername, String cognitoUserId) async {
    try {
      // 구글 ID -> Cognito username 매핑
      await _secureStorage.write(
        key: '${_googleUserIdKey}_$googleUserId',
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
    String googleUserId,
    AppAuthResult.AuthResult googleResult
  ) async {
    try {
      // 비밀번호 없이 로그인 시도
      return await _tryPasswordlessSignIn(cognitoUsername, googleUserId, googleResult);
    } catch (e) {
      print('기존 사용자 로그인 실패: $e');
      // 실패 시 새 사용자 생성 시도
      return await _createOrLinkUser(
        googleUserId, 
        googleResult.metadata?['displayName'] ?? '',
        googleResult.metadata?['name'] ?? '',
        googleResult.metadata?['email'],
        googleResult.metadata?['photoUrl'],
        googleResult
      );
    }
  }

  /// 비밀번호 없이 로그인 시도
  Future<AppAuthResult.AuthResult> _tryPasswordlessSignIn(
    String cognitoUsername,
    String googleUserId,
    AppAuthResult.AuthResult googleResult
  ) async {
    try {
      // 임시 비밀번호 생성 (구글 ID 기반)
      final tempPassword = 'Google#${googleUserId}2024!';
      
      final result = await Amplify.Auth.signIn(
        username: cognitoUsername,
        password: tempPassword,
      );
      
      if (result.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        
        return AppAuthResult.AuthResult.success(
          user: user,
          loginMethod: 'GOOGLE',
          accessToken: googleResult.accessToken,
          refreshToken: googleResult.refreshToken,
          metadata: googleResult.metadata,
        );
      }
      
      throw Exception('비밀번호 로그인 실패');
    } catch (e) {
      print('비밀번호 없는 로그인 실패: $e');
      rethrow;
    }
  }

  /// 새 사용자 생성 또는 연동
  Future<AppAuthResult.AuthResult> _createOrLinkUser(
    String googleUserId,
    String displayName,
    String? name,
    String? email,
    String? photoUrl,
    AppAuthResult.AuthResult googleResult
  ) async {
    try {
      // 고유한 username 생성
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final username = 'google_${googleUserId}_${timestamp.substring(timestamp.length - 6)}';
      
      // 이메일 처리 (구글은 보통 이메일 제공)
      final userEmail = email ?? 'google_${googleUserId}@gmail.com';
      
      // 이름 처리
      final userName = name ?? displayName;
      
      // 임시 비밀번호 생성
      final tempPassword = 'Google#${googleUserId}2024!';
      
      print('새 Cognito 사용자 생성: $username');
      
      // 사용자 속성 구성 (custom google_id 제거)
      final userAttributes = <AuthUserAttributeKey, String>{
        AuthUserAttributeKey.email: userEmail,
        AuthUserAttributeKey.name: userName,
        AuthUserAttributeKey.preferredUsername: displayName,
        // 구글 ID는 username 패턴에 포함되므로 별도 custom attribute 불필요
      };
      
      // 전화번호 처리 (Cognito에서 필수이므로 항상 제공)
      final phoneNumber = '+821012345678'; // 기본 플레이스홀더 전화번호
      userAttributes[AuthUserAttributeKey.phoneNumber] = phoneNumber;
      
      // Cognito 사용자 생성
      final signUpResult = await Amplify.Auth.signUp(
        username: username,
        password: tempPassword,
        options: SignUpOptions(
          userAttributes: userAttributes,
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
          await _saveUserLink(googleUserId, username, user.userId);
          
          return AppAuthResult.AuthResult.success(
            user: user,
            loginMethod: 'GOOGLE',
            accessToken: googleResult.accessToken,
            refreshToken: googleResult.refreshToken,
            metadata: {
              ...?googleResult.metadata,
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
        
        return await _createOrLinkUser(
          googleUserId,
          displayName,
          name,
          email,
          photoUrl,
          googleResult
        );
      }
      
      return AppAuthResult.AuthResult.failure(error: '사용자 생성 중 오류가 발생했습니다: $e');
    }
  }
  
  /// 연동 해제
  Future<void> unlinkGoogleUser() async {
    try {
      // 구글 로그아웃
      await _googleService.signOut();
      
      // 연동 정보 삭제
      final cognitoUsername = await _secureStorage.read(key: _cognitoUsernameKey);
      if (cognitoUsername != null) {
        await _secureStorage.deleteAll();
      }
      
      print('구글 연동 해제 완료');
    } catch (e) {
      print('구글 연동 해제 실패: $e');
    }
  }
}