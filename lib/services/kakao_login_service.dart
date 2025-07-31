import 'dart:async';
import 'dart:io';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_result.dart' as AppAuthResult;

class KakaoLoginService {
  static final KakaoLoginService _instance = KakaoLoginService._internal();
  factory KakaoLoginService() => _instance;
  KakaoLoginService._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _accessTokenKey = 'kakao_access_token';
  static const String _refreshTokenKey = 'kakao_refresh_token';
  static const String _userIdKey = 'kakao_user_id';
  static const String _emailKey = 'kakao_email';

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      // 카카오 SDK는 main.dart에서 이미 초기화되었다고 가정
      print('✅ KakaoLoginService 초기화 완료');
    } catch (e) {
      print('❌ KakaoLoginService 초기화 실패: $e');
      rethrow;
    }
  }

  /// 카카오 로그인 가능 여부 확인
  Future<bool> checkKakaoTalkInstalled() async {
    try {
      return await isKakaoTalkInstalled();
    } catch (e) {
      print('카카오톡 설치 확인 실패: $e');
      return false;
    }
  }

  /// 카카오 로그인
  Future<AppAuthResult.AuthResult> signIn() async {
    try {
      print('=== 카카오 로그인 시작 ===');

      OAuthToken? token;
      
      // 기존 로그인 상태 확인 및 정리
      await _clearStoredTokens();

      if (Platform.isAndroid || Platform.isIOS) {
        // 카카오톡 앱이 설치되어 있는지 확인
        final isInstalled = await checkKakaoTalkInstalled();
        print('카카오톡 설치 여부: $isInstalled');

        if (isInstalled) {
          try {
            // 카카오톡으로 로그인
            print('카카오톡 앱으로 로그인 시도...');
            token = await UserApi.instance.loginWithKakaoTalk();
            print('✅ 카카오톡 앱 로그인 성공');
          } catch (e) {
            print('⚠️ 카카오톡 앱 로그인 실패, 웹 로그인으로 전환: $e');
            // 카카오톡 로그인 실패 시 웹 로그인으로 fallback
            token = await UserApi.instance.loginWithKakaoAccount();
            print('✅ 카카오 웹 로그인 성공');
          }
        } else {
          // 카카오톡이 설치되지 않은 경우 웹 로그인
          print('카카오 웹 로그인 시도...');
          token = await UserApi.instance.loginWithKakaoAccount();
          print('✅ 카카오 웹 로그인 성공');
        }
      } else {
        // 웹 플랫폼의 경우
        print('웹 플랫폼: 카카오 웹 로그인 시도...');
        token = await UserApi.instance.loginWithKakaoAccount();
        print('✅ 카카오 웹 로그인 성공');
      }

      if (token == null) {
        return AppAuthResult.AuthResult.failure(error: '카카오 로그인 토큰 획득 실패');
      }

      print('Access Token: ${token.accessToken.substring(0, 20)}...');
      print('Refresh Token: ${token.refreshToken?.substring(0, 20) ?? 'null'}...');

      // 사용자 정보 조회
      final user = await UserApi.instance.me();
      print('카카오 사용자 정보 조회 성공');
      print('사용자 ID: ${user.id}');
      print('닉네임: ${user.kakaoAccount?.profile?.nickname}');
      print('이메일: ${user.kakaoAccount?.email}');

      // 토큰 및 사용자 정보 저장
      await _saveTokens(token);
      await _saveUserInfo(user);

      return AppAuthResult.AuthResult.success(
        user: null, // Kakao User를 AuthUser로 변환 필요 시 별도 구현
        loginMethod: 'KAKAO',
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        additionalData: {
          'kakao_user_id': user.id.toString(),
          'nickname': user.kakaoAccount?.profile?.nickname,
          'email': user.kakaoAccount?.email,
          'profile_image': user.kakaoAccount?.profile?.profileImageUrl,
        },
      );

    } catch (e) {
      return _handleKakaoError(e, '카카오 로그인');
    }
  }

  /// 카카오 로그아웃
  Future<void> signOut() async {
    try {
      print('카카오 로그아웃 시작...');
      
      // 카카오 SDK 로그아웃
      await UserApi.instance.logout();
      
      // 로컬 저장소 정리
      await _clearStoredTokens();
      
      print('✅ 카카오 로그아웃 완료');
    } catch (e) {
      print('❌ 카카오 로그아웃 실패: $e');
      // 로컬 토큰은 삭제
      await _clearStoredTokens();
      rethrow;
    }
  }

  /// 카카오 연결 해제 (앱 연결 끊기)
  Future<void> unlink() async {
    try {
      print('카카오 연결 해제 시작...');
      
      // 카카오 연결 해제
      await UserApi.instance.unlink();
      
      // 로컬 저장소 정리
      await _clearStoredTokens();
      
      print('✅ 카카오 연결 해제 완료');
    } catch (e) {
      print('❌ 카카오 연결 해제 실패: $e');
      // 로컬 토큰은 삭제
      await _clearStoredTokens();
      rethrow;
    }
  }

  /// 현재 사용자 정보 조회
  Future<AppAuthResult.AuthResult?> getCurrentUser() async {
    try {
      print('카카오 현재 사용자 조회 시작...');
      
      // 저장된 토큰 확인
      final accessToken = await _getStoredToken(_accessTokenKey);
      if (accessToken == null) {
        print('저장된 카카오 액세스 토큰 없음');
        return null;
      }

      // 토큰 유효성 확인
      try {
        await UserApi.instance.accessTokenInfo();
      } catch (e) {
        print('카카오 토큰 만료 또는 무효: $e');
        await _clearStoredTokens();
        return null;
      }

      // 사용자 정보 조회
      final user = await UserApi.instance.me();
      
      final storedEmail = await _getStoredValue(_emailKey);
      print('현재 카카오 사용자: ${user.id}, 이메일: $storedEmail');

      return AppAuthResult.AuthResult.success(
        user: null,
        loginMethod: 'KAKAO',
        accessToken: accessToken,
        refreshToken: await _getStoredToken(_refreshTokenKey),
        additionalData: {
          'kakao_user_id': user.id.toString(),
          'nickname': user.kakaoAccount?.profile?.nickname,
          'email': user.kakaoAccount?.email,
          'profile_image': user.kakaoAccount?.profile?.profileImageUrl,
        },
      );
    } catch (e) {
      print('❌ 카카오 현재 사용자 조회 실패: $e');
      return null;
    }
  }

  /// 토큰 갱신
  Future<AppAuthResult.AuthResult> refreshTokens() async {
    try {
      print('카카오 토큰 갱신 시작...');
      
      final refreshToken = await _getStoredToken(_refreshTokenKey);
      if (refreshToken == null) {
        return AppAuthResult.AuthResult.failure(error: '리프레시 토큰이 없습니다. 다시 로그인해주세요.');
      }

      // 토큰 갱신 (카카오 SDK가 자동으로 처리)
      final tokenInfo = await UserApi.instance.accessTokenInfo();
      print('토큰 갱신 완료: ${tokenInfo.id}');

      return AppAuthResult.AuthResult.success(
        user: null,
        loginMethod: 'KAKAO_TOKEN_REFRESH',
        accessToken: await _getStoredToken(_accessTokenKey),
        refreshToken: refreshToken,
      );
    } catch (e) {
      await _clearStoredTokens();
      return _handleKakaoError(e, '카카오 토큰 갱신');
    }
  }

  /// 자동 로그인 가능 여부 확인
  Future<bool> canAutoLogin() async {
    try {
      final accessToken = await _getStoredToken(_accessTokenKey);
      if (accessToken == null) return false;
      
      // 토큰 유효성 확인
      await UserApi.instance.accessTokenInfo();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Private 헬퍼 메서드들

  /// 토큰 저장
  Future<void> _saveTokens(OAuthToken token) async {
    try {
      await _secureStorage.write(
        key: _accessTokenKey,
        value: token.accessToken,
      );
      
      if (token.refreshToken != null) {
        await _secureStorage.write(
          key: _refreshTokenKey,
          value: token.refreshToken!,
        );
      }
      
      print('✅ 카카오 토큰 저장 완료');
    } catch (e) {
      print('⚠️ 카카오 토큰 저장 실패: $e');
    }
  }

  /// 사용자 정보 저장
  Future<void> _saveUserInfo(User user) async {
    try {
      await _secureStorage.write(
        key: _userIdKey, 
        value: user.id.toString(),
      );
      
      if (user.kakaoAccount?.email != null) {
        await _secureStorage.write(
          key: _emailKey, 
          value: user.kakaoAccount!.email!,
        );
      }
      
      print('✅ 카카오 사용자 정보 저장 완료');
    } catch (e) {
      print('⚠️ 카카오 사용자 정보 저장 실패: $e');
    }
  }

  /// 저장된 토큰 조회
  Future<String?> _getStoredToken(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('⚠️ 카카오 토큰 조회 실패: $e');
      return null;
    }
  }

  /// 저장된 값 조회
  Future<String?> _getStoredValue(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('⚠️ 카카오 값 조회 실패: $e');
      return null;
    }
  }

  /// 저장된 토큰 및 정보 삭제
  Future<void> _clearStoredTokens() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _emailKey);
      print('✅ 카카오 로컬 데이터 정리 완료');
    } catch (e) {
      print('⚠️ 카카오 토큰 삭제 실패: $e');
    }
  }

  /// 카카오 에러 처리
  AppAuthResult.AuthResult _handleKakaoError(dynamic error, String operation) {
    String errorMessage;
    
    print('카카오 에러 발생: $operation');
    print('에러 타입: ${error.runtimeType}');
    print('에러 메시지: $error');
    
    if (error is KakaoException) {
      print('KakaoException 상세: ${error.message}');
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('user_canceled') || errorString.contains('cancelled')) {
        errorMessage = '사용자가 로그인을 취소했습니다.';
      } else if (errorString.contains('network')) {
        errorMessage = '네트워크 연결을 확인해주세요.';
      } else if (errorString.contains('server')) {
        errorMessage = '카카오 서버 오류입니다. 잠시 후 다시 시도해주세요.';
      } else if (errorString.contains('token')) {
        errorMessage = '토큰이 유효하지 않습니다. 다시 로그인해주세요.';
      } else if (errorString.contains('invalid')) {
        errorMessage = '잘못된 요청입니다.';
      } else {
        errorMessage = error.message ?? '카카오 로그인 중 오류가 발생했습니다.';
      }
    } else {
      errorMessage = '$operation 중 오류가 발생했습니다: ${error.toString()}';
    }

    print('❌ $operation 실패: $errorMessage');
    return AppAuthResult.AuthResult.failure(error: errorMessage);
  }
}