import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:amplify_auth_cognito/amplify_auth_cognito.dart' hide AuthResult; // Unnecessary import
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // Removed - not using Firebase
// import 'package:flutter_naver_login/flutter_naver_login.dart'; // 임시 비활성화
import 'package:shared_preferences/shared_preferences.dart';
import '../config/aws_auth_config.dart';
import '../utils/point_exchange_validator.dart';
import '../models/auth_result.dart';

class MultiAuthService {
  // 싱글톤 패턴
  static final MultiAuthService _instance = MultiAuthService._internal();
  factory MultiAuthService() => _instance;
  MultiAuthService._internal();

  // 소셜 로그인 인스턴스들
  late GoogleSignIn _googleSignIn;

  // 초기화
  Future<void> initialize() async {
    // Google Sign-In 초기화
    _googleSignIn = GoogleSignIn(
      clientId: AWSAuthConfig.googleClientId,
      scopes: ['email', 'profile'],
    );

    // AWS Cognito 초기화 (전화번호 인증용)
    // Cognito SMS 설정은 AWS 콘솔에서 구성

    // 카카오 SDK 초기화 (나중에 필요시 추가)
    // KakaoSdk.init(nativeAppKey: AWSAuthConfig.kakaoNativeAppKey);

    // 네이버 로그인 초기화 (임시 비활성화)
    // await FlutterNaverLogin.initSdk(
    //   clientId: AWSAuthConfig.naverClientId,
    //   clientSecret: AWSAuthConfig.naverClientSecret,
    //   clientName: "소개팅앱",
    // );
  }

  // 1. 일반 로그인 (아이디/비밀번호)
  Future<AuthResult> signInWithCredentials(String username, String password) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );

      if (result.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        return AuthResult.success(
          user: user,
          loginMethod: 'COGNITO',
        );
      } else {
        return AuthResult.failure(error: '로그인에 실패했습니다.');
      }
    } catch (e) {
      return AuthResult.failure(error: '로그인 오류: $e');
    }
  }

  // 2. 구글 로그인
  Future<AuthResult> signInWithGoogle() async {
    try {
      // 1단계: Google 로그인
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.failure(error: '구글 로그인이 취소되었습니다.');
      }

      // final GoogleSignInAuthentication googleAuth = await googleUser.authentication; // Unused variable

      // 2단계: Cognito Identity Provider로 로그인
      final result = await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.google,
      );

      if (result.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();

        // 3단계: 사용자 정보 저장/업데이트
        await _syncUserInfo(
          userId: user.userId,
          provider: 'Google',
          email: googleUser.email,
          name: googleUser.displayName,
          profileUrl: googleUser.photoUrl,
        );

        return AuthResult.success(
          user: user,
          loginMethod: 'Google',
        );
      }

      return AuthResult.failure(error: '구글 로그인에 실패했습니다.');
    } catch (e) {
      return AuthResult.failure(error: '구글 로그인 오류: $e');
    }
  }

  // 3. 카카오 로그인 (임시 비활성화)
  Future<AuthResult> signInWithKakao() async {
    try {
      // 카카오 SDK 종속성 제거로 인한 임시 구현
      // 실제 구현에서는 카카오 SDK 추가 후 사용
      return AuthResult.failure(error: '카카오 로그인은 현재 지원하지 않습니다.');
    } catch (e) {
      return AuthResult.failure(error: '카카오 로그인 오류: $e');
    }
  }

  // 4. 네이버 로그인 (임시 비활성화)
  Future<AuthResult> signInWithNaver() async {
    try {
      // 네이버 로그인 임시 비활성화
      return AuthResult.failure(error: '네이버 로그인은 현재 지원하지 않습니다.');
      
      // 1단계: 네이버 로그인
      // final NaverLoginResult result = await FlutterNaverLogin.logIn();

      // if (result.status == NaverLoginStatus.loggedIn) {
      //   final account = result.account;

      //   // 2단계: Cognito로 페더레이션 로그인
      //   final authResult = await _federateWithCognito(
      //     provider: 'Naver',
      //     token: result.accessToken.accessToken,
      //     userInfo: {
      //       'id': account.id,
      //       'email': account.email,
      //       'name': account.name,
      //       'profileUrl': account.profileImage,
      //     },
      //   );

      //   return authResult;
      // }

      // return AuthResult.failure(error: '네이버 로그인에 실패했습니다.');
    } catch (e) {
      return AuthResult.failure(error: '네이버 로그인 오류: $e');
    }
  }

  // 5. 전화번호 로그인 (AWS Cognito 사용)
  Future<AuthResult> signInWithPhoneNumber(String phoneNumber) async {
    try {
      // 전화번호 형식 검증
      if (!PointExchangeValidator.isValidPhoneNumber(phoneNumber)) {
        return AuthResult.failure(error: '올바른 전화번호 형식이 아닙니다.');
      }

      // AWS Cognito를 사용한 전화번호 인증
      // SMS 인증 플로우 시작
      final result = await Amplify.Auth.signIn(
        username: phoneNumber,
      );

      if (result.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        return AuthResult.success(
          user: user,
          loginMethod: 'PHONE',
        );
      } else {
        // SMS 코드 전송이 필요한 경우
        return AuthResult.failure(error: 'SMS 코드 전송이 필요합니다.');
      }
    } catch (e) {
      return AuthResult.failure(error: '전화번호 인증 오류: $e');
    }
  }

  // 6. SMS 인증 코드 확인 (AWS Cognito 사용)
  Future<AuthResult> verifyPhoneCode(String verificationId, String smsCode) async {
    try {
      // AWS Cognito를 사용한 SMS 코드 확인
      // 실제 구현에서는 confirmSignIn 메서드 사용
      final result = await Amplify.Auth.confirmSignIn(
        confirmationValue: smsCode,
      );

      if (result.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        return AuthResult.success(
          user: user,
          loginMethod: 'PHONE',
        );
      } else {
        return AuthResult.failure(error: '인증 코드 확인에 실패했습니다.');
      }
    } catch (e) {
      return AuthResult.failure(error: '인증 코드 확인 오류: $e');
    }
  }

  // 전화번호 인증 완료 처리 (AWS Cognito 전용)
  Future<AuthResult> _completePhoneAuth(String phoneNumber) async {
    try {
      // AWS Cognito를 사용한 전화번호 인증 완료
      final user = await Amplify.Auth.getCurrentUser();
      
      if (user != null) {
        // 사용자 정보 동기화
        await _syncUserInfo(
          userId: user.userId,
          provider: 'PHONE',
          phoneNumber: phoneNumber,
        );

        return AuthResult.success(
          user: user,
          loginMethod: 'PHONE',
        );
      }

      return AuthResult.failure(error: '전화번호 인증에 실패했습니다.');
    } catch (e) {
      return AuthResult.failure(error: '전화번호 인증 완료 오류: $e');
    }
  }

  // Cognito 페더레이션 로그인 처리
  Future<AuthResult> _federateWithCognito({
    required String provider,
    required String token,
    required Map<String, dynamic> userInfo,
  }) async {
    try {
      // Identity Pool을 통한 페더레이션 로그인 구현
      // 실제로는 AWS SDK를 사용해서 Identity Pool에 토큰을 제출하고
      // 임시 자격 증명을 받아와야 함

      // 임시 구현 - 실제로는 더 복잡한 로직 필요
      final userId = '${provider.toLowerCase()}_${userInfo['id'] ?? userInfo['uid']}';

      await _syncUserInfo(
        userId: userId,
        provider: provider,
        email: userInfo['email'],
        name: userInfo['name'],
        profileUrl: userInfo['profileUrl'],
        phoneNumber: userInfo['phoneNumber'],
      );

      return AuthResult.success(
        loginMethod: provider,
      );
    } catch (e) {
      return AuthResult.failure(error: '페더레이션 로그인 오류: $e');
    }
  }

  // 사용자 정보 동기화
  Future<void> _syncUserInfo({
    required String userId,
    required String provider,
    String? email,
    String? name,
    String? profileUrl,
    String? phoneNumber,
  }) async {
    try {
      // DynamoDB나 다른 저장소에 사용자 정보 저장/업데이트
      // 실제 구현에서는 AWS API나 GraphQL을 사용

      final userInfo = {
        'userId': userId,
        'provider': provider,
        'email': email,
        'name': name,
        'profileUrl': profileUrl,
        'phoneNumber': phoneNumber,
        'lastLoginAt': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 로컬 저장소에도 캐시
      await _saveUserInfoLocally(userInfo);
    } catch (e) {
      // print('사용자 정보 동기화 오류: $e'); // TODO: Use proper logging
    }
  }

  // 로컬 사용자 정보 저장
  Future<void> _saveUserInfoLocally(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', userInfo.toString());
    await prefs.setString('last_login_provider', userInfo['provider']);
    await prefs.setString('last_login_at', userInfo['lastLoginAt']);
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // Amplify 로그아웃
      await Amplify.Auth.signOut();

      // 각 소셜 로그인 로그아웃
      await _googleSignIn.signOut();
      // await UserApi.instance.logout(); // 카카오 SDK 제거로 인한 임시 비활성화
      // await FlutterNaverLogin.logOut(); // 네이버 로그인 임시 비활성화

      // 로컬 데이터 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_info');
      await prefs.remove('last_login_provider');
      await prefs.remove('last_login_at');
    } catch (e) {
      // print('로그아웃 오류: $e'); // TODO: Use proper logging
    }
  }

  // 현재 로그인 상태 확인
  Future<AuthResult?> getCurrentUser() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();

        // 로컬에서 사용자 정보 조회
        final userInfo = await _getUserInfoFromLocal(user.userId);

        return AuthResult.success(
          user: user,
          loginMethod: userInfo['provider'],
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 로컬에서 사용자 정보 조회
  Future<Map<String, dynamic>> _getUserInfoFromLocal(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoStr = prefs.getString('user_info');
    if (userInfoStr != null) {
      // 간단한 파싱 (실제로는 JSON 사용 권장)
      return {'provider': prefs.getString('last_login_provider') ?? 'Unknown'};
    }
    return {};
  }

  // 자동 로그인 체크
  Future<bool> checkAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginAt = prefs.getString('last_login_at');
      
      if (lastLoginAt != null) {
        final lastLogin = DateTime.parse(lastLoginAt);
        final now = DateTime.now();
        final difference = now.difference(lastLogin);
        
        // 30일 이내 로그인 시 자동 로그인 시도
        if (difference.inDays < 30) {
          final currentUser = await getCurrentUser();
          return currentUser != null;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 소셜 로그인 에러 처리
  String _handleSocialLoginError(dynamic error) {
    if (error.toString().contains('network')) {
      return '네트워크 연결을 확인해주세요.';
    } else if (error.toString().contains('cancelled')) {
      return '로그인이 취소되었습니다.';
    } else if (error.toString().contains('invalid')) {
      return '잘못된 인증 정보입니다.';
    } else {
      return '로그인 중 오류가 발생했습니다.';
    }
  }
}

// AuthResult 클래스는 models/auth_result.dart 파일에서 import됨