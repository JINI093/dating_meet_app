import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_result.dart' as AppAuthResult;

class GoogleLoginService {
  static final GoogleLoginService _instance = GoogleLoginService._internal();
  factory GoogleLoginService() => _instance;
  GoogleLoginService._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _accessTokenKey = 'google_access_token';
  static const String _refreshTokenKey = 'google_refresh_token';
  static const String _userIdKey = 'google_user_id';
  static const String _emailKey = 'google_email';

  late GoogleSignIn _googleSignIn;
  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        // Google Sign-In 초기화
        _googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'profile',
            'openid',
          ],
        );
        _isInitialized = true;
      }
      print('✅ GoogleLoginService 초기화 완료');
    } catch (e) {
      print('❌ GoogleLoginService 초기화 실패: $e');
      rethrow;
    }
  }

  /// 구글 로그인
  Future<AppAuthResult.AuthResult> signIn() async {
    try {
      print('=== 구글 로그인 시작 ===');

      // 기존 로그인 상태 확인 및 정리
      await _clearStoredTokens();

      // 구글 로그인 실행
      print('구글 로그인 시도...');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return AppAuthResult.AuthResult.failure(
          error: '사용자가 구글 로그인을 취소했습니다.',
        );
      }

      print('✅ 구글 로그인 성공');
      
      try {
        // 사용자 정보 조회
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final userInfo = await _getUserInfo(googleUser, googleAuth);
        
        if (userInfo != null) {
          await _saveUserInfo(userInfo);
          
          final result = AppAuthResult.AuthResult.success(
            user: null,
            loginMethod: 'GOOGLE',
            accessToken: userInfo['access_token'],
            refreshToken: userInfo['refresh_token'],
            metadata: {
              'google_user_id': userInfo['id'],
              'email': userInfo['email'],
              'name': userInfo['name'],
              'displayName': userInfo['displayName'],
              'photoUrl': userInfo['photoUrl'],
              'serverAuthCode': userInfo['serverAuthCode'],
            },
          );
          
          return result;
        } else {
          return AppAuthResult.AuthResult.failure(
            error: '사용자 정보를 가져올 수 없습니다.',
          );
        }
      } catch (e) {
        return AppAuthResult.AuthResult.failure(
          error: '사용자 정보 조회 실패: $e',
        );
      }

    } catch (e) {
      return _handleGoogleError(e, '구글 로그인');
    }
  }

  /// 사용자 정보 조회
  Future<Map<String, dynamic>?> _getUserInfo(
    GoogleSignInAccount googleUser,
    GoogleSignInAuthentication googleAuth,
  ) async {
    try {
      print('구글 사용자 정보 조회 중...');
      
      return {
        'id': googleUser.id,
        'email': googleUser.email,
        'name': googleUser.displayName ?? 'Google User',
        'displayName': googleUser.displayName ?? 'Google User',
        'photoUrl': googleUser.photoUrl ?? '',
        'serverAuthCode': googleUser.serverAuthCode ?? '',
        'access_token': googleAuth.accessToken ?? 'google_access_token_${DateTime.now().millisecondsSinceEpoch}',
        'refresh_token': googleAuth.idToken ?? 'google_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      };
    } catch (e) {
      print('구글 사용자 정보 조회 실패: $e');
      return null;
    }
  }

  /// 구글 로그아웃
  Future<void> signOut() async {
    try {
      print('구글 로그아웃 시작...');
      
      // 구글 SDK 로그아웃
      await _googleSignIn.signOut();
      
      // 로컬 저장소 정리
      await _clearStoredTokens();
      
      print('✅ 구글 로그아웃 완료');
    } catch (e) {
      print('❌ 구글 로그아웃 실패: $e');
      // 로컬 토큰은 삭제
      await _clearStoredTokens();
      rethrow;
    }
  }

  /// 구글 연결 해제 (앱 연결 끊기)
  Future<void> disconnect() async {
    try {
      print('구글 연결 해제 시작...');
      
      // 구글 계정 연결 해제
      await _googleSignIn.disconnect();
      
      // 로컬 저장소 정리
      await _clearStoredTokens();
      
      print('✅ 구글 연결 해제 완료');
    } catch (e) {
      print('❌ 구글 연결 해제 실패: $e');
      // 로컬 토큰은 삭제
      await _clearStoredTokens();
      rethrow;
    }
  }

  /// 현재 사용자 정보 조회
  Future<AppAuthResult.AuthResult?> getCurrentUser() async {
    try {
      print('구글 현재 사용자 조회 시작...');
      
      // 저장된 토큰 확인
      final accessToken = await _getStoredToken(_accessTokenKey);
      if (accessToken == null) {
        print('저장된 구글 액세스 토큰 없음');
        return null;
      }

      // 토큰 유효성 확인 (간단히 저장된 정보로 확인)
      final userId = await _getStoredValue(_userIdKey);
      final email = await _getStoredValue(_emailKey);
      
      if (userId == null || userId.isEmpty) {
        print('저장된 구글 사용자 정보 없음');
        await _clearStoredTokens();
        return null;
      }

      print('현재 구글 사용자: $userId, 이메일: $email');

      return AppAuthResult.AuthResult.success(
        user: null,
        loginMethod: 'GOOGLE',
        accessToken: accessToken,
        refreshToken: await _getStoredToken(_refreshTokenKey),
        metadata: {
          'google_user_id': userId,
          'email': email,
        },
      );
    } catch (e) {
      print('❌ 구글 현재 사용자 조회 실패: $e');
      return null;
    }
  }

  /// 토큰 갱신
  Future<AppAuthResult.AuthResult> refreshTokens() async {
    try {
      print('구글 토큰 갱신 시작...');
      
      // Google Sign-In 자동 토큰 갱신 시도
      final GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
      
      if (currentUser != null) {
        final GoogleSignInAuthentication refreshedAuth = await currentUser.authentication;
        
        // 새로운 토큰 저장
        await _secureStorage.write(key: _accessTokenKey, value: refreshedAuth.accessToken);
        if (refreshedAuth.idToken != null) {
          await _secureStorage.write(key: _refreshTokenKey, value: refreshedAuth.idToken);
        }
        
        print('구글 토큰 갱신 완료');
        
        return AppAuthResult.AuthResult.success(
          user: null,
          loginMethod: 'GOOGLE_TOKEN_REFRESH',
          accessToken: refreshedAuth.accessToken,
          refreshToken: refreshedAuth.idToken,
        );
      } else {
        await _clearStoredTokens();
        return AppAuthResult.AuthResult.failure(error: '토큰 갱신에 실패했습니다. 다시 로그인해주세요.');
      }
    } catch (e) {
      await _clearStoredTokens();
      return _handleGoogleError(e, '구글 토큰 갱신');
    }
  }

  /// 자동 로그인 가능 여부 확인
  Future<bool> canAutoLogin() async {
    try {
      final accessToken = await _getStoredToken(_accessTokenKey);
      final userId = await _getStoredValue(_userIdKey);
      return accessToken != null && userId != null && userId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Private 헬퍼 메서드들

  /// 사용자 정보 저장
  Future<void> _saveUserInfo(Map<String, dynamic> userInfo) async {
    try {
      if (userInfo['access_token'] != null) {
        await _secureStorage.write(
          key: _accessTokenKey,
          value: userInfo['access_token'],
        );
      }
      
      if (userInfo['refresh_token'] != null) {
        await _secureStorage.write(
          key: _refreshTokenKey,
          value: userInfo['refresh_token'],
        );
      }
      
      if (userInfo['id'] != null) {
        await _secureStorage.write(
          key: _userIdKey, 
          value: userInfo['id'],
        );
      }
      
      if (userInfo['email'] != null) {
        await _secureStorage.write(
          key: _emailKey, 
          value: userInfo['email'],
        );
      }
      
      print('✅ 구글 사용자 정보 저장 완료');
    } catch (e) {
      print('⚠️ 구글 사용자 정보 저장 실패: $e');
    }
  }

  /// 저장된 토큰 조회
  Future<String?> _getStoredToken(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('⚠️ 구글 토큰 조회 실패: $e');
      return null;
    }
  }

  /// 저장된 값 조회
  Future<String?> _getStoredValue(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('⚠️ 구글 값 조회 실패: $e');
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
      print('✅ 구글 로컬 데이터 정리 완료');
    } catch (e) {
      print('⚠️ 구글 토큰 삭제 실패: $e');
    }
  }

  /// 구글 에러 처리
  AppAuthResult.AuthResult _handleGoogleError(dynamic error, String operation) {
    String errorMessage;
    
    print('구글 에러 발생: $operation');
    print('에러 타입: ${error.runtimeType}');
    print('에러 메시지: $error');
    
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('sign_in_canceled') || errorString.contains('cancelled')) {
      errorMessage = '사용자가 로그인을 취소했습니다.';
    } else if (errorString.contains('network')) {
      errorMessage = '네트워크 연결을 확인해주세요.';
    } else if (errorString.contains('sign_in_failed')) {
      errorMessage = '구글 로그인에 실패했습니다. 다시 시도해주세요.';
    } else if (errorString.contains('token')) {
      errorMessage = '토큰이 유효하지 않습니다. 다시 로그인해주세요.';
    } else if (errorString.contains('invalid')) {
      errorMessage = '잘못된 요청입니다.';
    } else {
      errorMessage = '$operation 중 오류가 발생했습니다: ${error.toString()}';
    }

    print('❌ $operation 실패: $errorMessage');
    return AppAuthResult.AuthResult.failure(error: errorMessage);
  }
}