import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../models/auth_result.dart' as AppAuthResult;
import './naver_login_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 네이버 로그인과 AWS Cognito를 연동하는 서비스
class AWSNaverAuthService {
  static final AWSNaverAuthService _instance = AWSNaverAuthService._internal();
  factory AWSNaverAuthService() => _instance;
  AWSNaverAuthService._internal();

  final NaverLoginService _naverService = NaverLoginService();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // 저장 키
  static const String _naverUserIdKey = 'naver_cognito_user_id';
  static const String _cognitoUserIdKey = 'cognito_user_id';
  static const String _cognitoUsernameKey = 'cognito_username';

  /// 네이버 로그인 후 Cognito 연동
  Future<AppAuthResult.AuthResult> signInWithNaver() async {
    try {
      print('=== 네이버 - Cognito 연동 로그인 시작 ===');
      
      // 1. 네이버 로그인 먼저 수행
      final naverResult = await _naverService.signIn();
      
      if (!naverResult.success) {
        return naverResult;
      }
      
      // 2. 네이버 사용자 정보 추출
      final naverUserId = naverResult.metadata?['naver_user_id'] ?? '';
      final nickname = naverResult.metadata?['nickname'] ?? '';
      final email = naverResult.metadata?['email'];
      final profileImage = naverResult.metadata?['profile_image'];
      final name = naverResult.metadata?['name'];
      final mobile = naverResult.metadata?['mobile'];
      
      if (naverUserId.isEmpty) {
        return AppAuthResult.AuthResult.failure(error: '네이버 사용자 정보를 가져올 수 없습니다.');
      }
      
      print('네이버 사용자 정보: ID=$naverUserId, 닉네임=$nickname');
      
      // 3. 기존에 연동된 Cognito 사용자 확인
      final existingCognitoUsername = await _getLinkedCognitoUser(naverUserId);
      
      if (existingCognitoUsername != null) {
        // 3-1. 기존 사용자로 로그인 시도
        print('기존 연동 사용자 발견: $existingCognitoUsername');
        return await _signInExistingUser(existingCognitoUsername, naverUserId, naverResult);
      } else {
        // 3-2. 새 사용자 생성 또는 연동
        print('새 사용자 생성 필요');
        return await _createOrLinkUser(naverUserId, nickname, name, email, mobile, profileImage, naverResult);
      }
      
    } catch (e) {
      print('네이버-Cognito 연동 로그인 실패: $e');
      return AppAuthResult.AuthResult.failure(error: '네이버 로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 기존 연동된 Cognito 사용자 확인
  Future<String?> _getLinkedCognitoUser(String naverUserId) async {
    try {
      final key = '${_naverUserIdKey}_$naverUserId';
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('연동 사용자 확인 실패: $e');
      return null;
    }
  }

  /// 네이버 사용자와 Cognito 사용자 연동 저장
  Future<void> _saveUserLink(String naverUserId, String cognitoUsername, String cognitoUserId) async {
    try {
      // 네이버 ID -> Cognito username 매핑
      await _secureStorage.write(
        key: '${_naverUserIdKey}_$naverUserId',
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
    String naverUserId,
    AppAuthResult.AuthResult naverResult
  ) async {
    try {
      // 비밀번호 없이 로그인 시도
      return await _tryPasswordlessSignIn(cognitoUsername, naverUserId, naverResult);
    } catch (e) {
      print('기존 사용자 로그인 실패: $e');
      // 실패 시 새 사용자 생성 시도
      return await _createOrLinkUser(
        naverUserId, 
        naverResult.metadata?['nickname'] ?? '',
        naverResult.metadata?['name'] ?? '',
        naverResult.metadata?['email'],
        naverResult.metadata?['mobile'],
        naverResult.metadata?['profile_image'],
        naverResult
      );
    }
  }

  /// 비밀번호 없이 로그인 시도
  Future<AppAuthResult.AuthResult> _tryPasswordlessSignIn(
    String cognitoUsername,
    String naverUserId,
    AppAuthResult.AuthResult naverResult
  ) async {
    try {
      // 임시 비밀번호 생성 (네이버 ID 기반)
      final tempPassword = 'Naver#${naverUserId}2024!';
      
      final result = await Amplify.Auth.signIn(
        username: cognitoUsername,
        password: tempPassword,
      );
      
      if (result.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        
        return AppAuthResult.AuthResult.success(
          user: user,
          loginMethod: 'NAVER',
          accessToken: naverResult.accessToken,
          refreshToken: naverResult.refreshToken,
          metadata: naverResult.metadata,
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
    String naverUserId,
    String nickname,
    String? name,
    String? email,
    String? mobile,
    String? profileImage,
    AppAuthResult.AuthResult naverResult
  ) async {
    try {
      // 고유한 username 생성
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final username = 'naver_${naverUserId}_${timestamp.substring(timestamp.length - 6)}';
      
      // 이메일 처리 (네이버는 선택적으로 이메일 제공)
      final userEmail = email ?? 'naver_${naverUserId}@naver.local';
      
      // 이름 처리
      final userName = name ?? nickname;
      
      // 임시 비밀번호 생성
      final tempPassword = 'Naver#${naverUserId}2024!';
      
      print('새 Cognito 사용자 생성: $username');
      
      // 사용자 속성 구성 (custom naver_id 제거)
      final userAttributes = <AuthUserAttributeKey, String>{
        AuthUserAttributeKey.email: userEmail,
        AuthUserAttributeKey.name: userName,
        AuthUserAttributeKey.preferredUsername: nickname,
        // 네이버 ID는 username 패턴에 포함되므로 별도 custom attribute 불필요
      };
      
      // 전화번호 처리 (Cognito에서 필수이므로 항상 제공)
      final phoneNumber = (mobile != null && mobile.isNotEmpty) 
          ? _normalizePhoneNumber(mobile)
          : '+821012345678'; // 기본 플레이스홀더 전화번호
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
          await _saveUserLink(naverUserId, username, user.userId);
          
          return AppAuthResult.AuthResult.success(
            user: user,
            loginMethod: 'NAVER',
            accessToken: naverResult.accessToken,
            refreshToken: naverResult.refreshToken,
            metadata: {
              ...?naverResult.metadata,
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
          naverUserId,
          nickname,
          name,
          email,
          mobile,
          profileImage,
          naverResult
        );
      }
      
      return AppAuthResult.AuthResult.failure(error: '사용자 생성 중 오류가 발생했습니다: $e');
    }
  }
  
  /// 전화번호 정규화 (한국 번호를 +82 형식으로 변환)
  String _normalizePhoneNumber(String phoneNumber) {
    // 숫자만 추출
    String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // 한국 번호 형식 처리
    if (digits.startsWith('010') || digits.startsWith('011') || 
        digits.startsWith('016') || digits.startsWith('017') || 
        digits.startsWith('018') || digits.startsWith('019')) {
      // 010-1234-5678 → +821012345678
      return '+82${digits.substring(1)}';
    } else if (digits.startsWith('82')) {
      // 이미 82로 시작하는 경우
      return '+$digits';
    } else {
      // 기본적으로 +82 추가
      return '+82$digits';
    }
  }
  
  /// 연동 해제
  Future<void> unlinkNaverUser() async {
    try {
      // 네이버 로그아웃
      await _naverService.signOut();
      
      // 연동 정보 삭제
      final cognitoUsername = await _secureStorage.read(key: _cognitoUsernameKey);
      if (cognitoUsername != null) {
        await _secureStorage.deleteAll();
      }
      
      print('네이버 연동 해제 완료');
    } catch (e) {
      print('네이버 연동 해제 실패: $e');
    }
  }
}