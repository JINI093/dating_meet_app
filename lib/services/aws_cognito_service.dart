import 'dart:async';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_result.dart' as AppAuthResult;
import '../config/aws_auth_config.dart';
import '../utils/auth_validators.dart';

/// AWS Cognito 인증 서비스
/// 실제 AWS Cognito와 연동하여 사용자 인증을 처리합니다.
class AWSCognitoService {
  static final AWSCognitoService _instance = AWSCognitoService._internal();
  factory AWSCognitoService() => _instance;
  AWSCognitoService._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    // iOptions: IOSOptions(
    //   accessibility: KeychainItemAccessibility.firstUnlockThisDevice,
    // ),
  );

  // 토큰 저장 키
  static const String _accessTokenKey = 'cognito_access_token';
  static const String _refreshTokenKey = 'cognito_refresh_token';
  static const String _idTokenKey = 'cognito_id_token';
  static const String _userIdKey = 'cognito_user_id';
  static const String _emailKey = 'cognito_email';

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      // Amplify가 이미 초기화되었는지 확인
      if (!Amplify.isConfigured) {
        throw Exception('Amplify가 초기화되지 않았습니다. main.dart에서 먼저 초기화해주세요.');
      }
      
      // 현재 세션 확인
      await _checkCurrentSession();
      
      print('✅ AWSCognitoService 초기화 완료');
    } catch (e) {
      print('❌ AWSCognitoService 초기화 실패: $e');
      rethrow;
    }
  }

  /// 현재 세션 확인
  Future<void> _checkCurrentSession() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        print('✅ 기존 세션 발견');
        await _saveTokensFromSession(session);
      }
    } catch (e) {
      print('⚠️ 세션 확인 실패: $e');
    }
  }

  /// 회원가입
  Future<AppAuthResult.AuthResult> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      print('AWS Cognito 회원가입 시작: $email');
      
      // 임시로 클라이언트 검증 비활성화 (디버깅용)
      print('입력값 검증 건너뛰기 (디버깅 모드)');
      print('이메일: $email');
      print('비밀번호 길이: ${password.length}');
      print('이름: $name');
      
      // 이메일 중복 확인
      final isDuplicate = await _checkEmailExists(email);
      if (isDuplicate) {
        print('중복 이메일 감지: $email');
        return AppAuthResult.AuthResult.failure(error: '이미 사용 중인 이메일입니다.');
      }

      print('AWS 회원가입 시도...');

      // Email alias가 설정된 경우 고유한 username 생성 필요
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final emailPrefix = email.split('@')[0].replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      final username = '${emailPrefix}_${timestamp.substring(timestamp.length - 6)}';
      print('생성된 username: $username');
      
      // 이메일 형식 검증 및 수정
      String validEmail = email;
      if (!email.contains('@')) {
        // 이메일 형식이 아닌 경우 기본 도메인 추가
        validEmail = '$email@example.com';
        print('이메일 형식 수정: $email → $validEmail');
      }
      
      // UserAttributes 맵 구성
      final userAttributes = <AuthUserAttributeKey, String>{
        AuthUserAttributeKey.email: validEmail,
        AuthUserAttributeKey.name: name,
        // preferredUsername 제거 - 이메일을 username으로 사용
      };
      
      print('=== AWS Cognito 회원가입 속성 ===');
      print('email: $validEmail');
      print('name: $name');
      print('===============================');
      
      // 전화번호가 있는 경우 추가
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // 전화번호 형식 정규화 (한국 번호를 +82 형식으로 변환)
        String normalizedPhone = _normalizePhoneNumber(phoneNumber);
        userAttributes[AuthUserAttributeKey.phoneNumber] = normalizedPhone;
        print('정규화된 전화번호: $normalizedPhone');
      }
      
      // Email alias 설정된 경우 고유 username 사용
      final result = await Amplify.Auth.signUp(
        username: username,  // 생성된 고유 username 사용
        password: password,
        options: SignUpOptions(
          userAttributes: userAttributes,
        ),
      );

      print('AWS Cognito signUp 결과: isSignUpComplete=${result.isSignUpComplete}');
      print('nextStep: ${result.nextStep}');
      
      // 생성된 username을 저장 (로그인 시 사용)
      await _secureStorage.write(key: 'username_$email', value: username);
      if (validEmail != email) {
        await _secureStorage.write(key: 'username_$validEmail', value: username);
      }
      
      if (result.isSignUpComplete) {
        // 즉시 가입 완료된 경우
        print('회원가입 즉시 완료, 자동 로그인 시도...');
        return await signIn(email: email, password: password);
      } else {
        // 이메일 검증이 필요한 경우
        print('이메일 인증이 필요합니다.');
        return AppAuthResult.AuthResult(
          success: false,
          error: '이메일 인증이 필요합니다. 이메일을 확인하고 인증 코드를 입력해주세요.',
          requiresConfirmation: true,
          user: null,
        );
      }
    } catch (e) {
      return _handleAuthError(e, '회원가입');
    }
  }

  /// 이메일 인증 확인
  Future<AppAuthResult.AuthResult> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );

      if (result.isSignUpComplete) {
        return AppAuthResult.AuthResult.success(
          user: null, // Will be set after actual sign-in
          loginMethod: 'EMAIL_VERIFICATION',
        );
      } else {
        return AppAuthResult.AuthResult.failure(error: '인증 코드 확인에 실패했습니다.');
      }
    } catch (e) {
      return _handleAuthError(e, '이메일 인증');
    }
  }

  /// 로그인
  Future<AppAuthResult.AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('=== AWS Cognito 로그인 시작 ===');
      print('이메일: $email');
      print('비밀번호 길이: ${password.length}');
      
      // 입력값 검증 (임시로 비활성화하여 AWS Cognito에서 직접 검증하도록 함)
      // final emailValidation = AuthValidators.validateEmail(email);
      // if (!emailValidation.isValid) {
      //   print('이메일 검증 실패: ${emailValidation.message}');
      //   return AppAuthResult.AuthResult.failure(error: emailValidation.message);
      // }

      if (password.isEmpty) {
        print('비밀번호가 비어있음');
        return AppAuthResult.AuthResult.failure(error: '비밀번호를 입력해주세요.');
      }

      // 기존 로그인 상태 확인 및 로그아웃
      try {
        final currentSession = await Amplify.Auth.fetchAuthSession();
        if (currentSession.isSignedIn) {
          print('기존 사용자가 로그인되어 있음. 로그아웃 후 재로그인...');
          await Amplify.Auth.signOut();
          await _clearStoredTokens();
        }
      } catch (e) {
        print('기존 세션 확인 중 오류: $e');
      }

      print('AWS Cognito signIn 호출 시작...');
      
      // AWS Cognito 로그인
      // email alias가 설정된 경우, 이메일로 직접 로그인 가능
      // 하지만 username이 이메일 형식이면 안되므로, 저장된 username 확인
      String loginUsername = email;
      
      // 저장된 username 확인 (회원가입 시 저장한 값)
      final savedUsername = await _secureStorage.read(key: 'username_$email');
      print('=== LOGIN DEBUG INFO ===');
      print('입력된 이메일: $email');
      print('저장소 키: username_$email');
      print('저장된 사용자명: $savedUsername');
      
      // 저장된 username이 있으면 사용, 없으면 이메일로 시도
      if (savedUsername != null) {
        print('저장된 username 사용: $savedUsername');
        loginUsername = savedUsername;
      } else {
        print('이메일로 직접 로그인 시도 (email alias)');
        loginUsername = email;
      }
      
      print('실제 로그인 시도할 사용자명: $loginUsername');
      
      SignInResult? result;
      
      try {
        print('🔍 로그인 시도 - 플랫폼: ${Platform.isAndroid ? "Android" : "iOS"}');
        print('   사용자명: $loginUsername');
        print('   비밀번호 길이: ${password.length}');
        
        result = await Amplify.Auth.signIn(
          username: loginUsername,
          password: password,
        );
      } catch (e) {
        print('❌ 로그인 실패 - 플랫폼: ${Platform.isAndroid ? "Android" : "iOS"}');
        print('   에러: $e');
        // 이메일 로그인 실패시 에러 출력 후 재throw
        print('❌ 이메일 로그인 실패');
        print('💡 이메일 alias가 제대로 설정되었는지 확인하세요');
        rethrow;
      }
      
      if (result != null) {
        print('AWS Cognito signIn 결과: isSignedIn=${result.isSignedIn}, nextStep=${result.nextStep.signInStep}');
      }

      if (result?.isSignedIn == true) {
        // 로그인 성공
        final user = await Amplify.Auth.getCurrentUser();
        final session = await Amplify.Auth.fetchAuthSession();
        
        // 토큰 저장
        await _saveTokensFromSession(session);
        await _saveUserInfo(user, email);

        return AppAuthResult.AuthResult.success(
          user: user,
          loginMethod: 'COGNITO',
          accessToken: await _getStoredToken(_accessTokenKey),
          refreshToken: await _getStoredToken(_refreshTokenKey),
        );
      } else if (result?.nextStep.signInStep == AuthSignInStep.confirmSignUp) {
        // 이메일 인증이 필요한 경우
        print('이메일 인증이 필요합니다.');
        return AppAuthResult.AuthResult(
          success: false,
          error: '이메일 인증이 필요합니다. 이메일을 확인하고 인증 코드를 입력해주세요.',
          requiresConfirmation: true,
          user: null,
        );
      } else {
        // 기타 추가 인증이 필요한 경우 (MFA 등)
        print('기타 인증 단계: ${result?.nextStep.signInStep}');
        return AppAuthResult.AuthResult.failure(error: '추가 인증이 필요합니다: ${result?.nextStep.signInStep}');
      }
    } catch (e) {
      return _handleAuthError(e, '로그인');
    }
  }

  /// 전화번호 로그인 시작
  Future<AppAuthResult.AuthResult> signInWithPhoneNumber(String phoneNumber) async {
    try {
      // 전화번호 형식 검증
      final phoneValidation = AuthValidators.validatePhoneNumber(phoneNumber, '+82');
      if (!phoneValidation.isValid) {
        return AppAuthResult.AuthResult.failure(error: phoneValidation.message);
      }

      // Cognito에서 전화번호 인증 시작
      final result = await Amplify.Auth.signIn(
        username: phoneNumber,
        options: const SignInOptions(
          pluginOptions: CognitoSignInPluginOptions(
            authFlowType: AuthenticationFlowType.customAuthWithSrp,
          ),
        ),
      );

      if (result.nextStep.signInStep == AuthSignInStep.confirmSignInWithCustomChallenge) {
        return AppAuthResult.AuthResult(
          success: false,
          error: 'SMS 인증코드가 전송되었습니다.',
          requiresConfirmation: true,
          user: null, // Will be set after SMS confirmation
        );
      } else {
        return AppAuthResult.AuthResult.failure(error: '전화번호 인증을 시작할 수 없습니다.');
      }
    } catch (e) {
      return _handleAuthError(e, '전화번호 인증');
    }
  }

  /// SMS 인증코드 확인
  Future<AppAuthResult.AuthResult> confirmSignInWithSMS(String confirmationCode) async {
    try {
      final result = await Amplify.Auth.confirmSignIn(
        confirmationValue: confirmationCode,
      );

      if (result.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        final session = await Amplify.Auth.fetchAuthSession();
        
        // 토큰 저장
        await _saveTokensFromSession(session);
        await _saveUserInfo(user, '');

        return AppAuthResult.AuthResult.success(
          user: user,
          loginMethod: 'PHONE',
          accessToken: await _getStoredToken(_accessTokenKey),
          refreshToken: await _getStoredToken(_refreshTokenKey),
        );
      } else {
        return AppAuthResult.AuthResult.failure(error: '인증코드가 올바르지 않습니다.');
      }
    } catch (e) {
      return _handleAuthError(e, 'SMS 인증코드 확인');
    }
  }

  /// 소셜 로그인 (Google)
  Future<AppAuthResult.AuthResult> signInWithGoogle() async {
    try {
      final result = await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.google,
      );

      if (result.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        final session = await Amplify.Auth.fetchAuthSession();
        
        // 토큰 저장
        await _saveTokensFromSession(session);
        await _saveUserInfo(user, '');

        return AppAuthResult.AuthResult.success(
          user: user,
          loginMethod: 'GOOGLE',
          accessToken: await _getStoredToken(_accessTokenKey),
          refreshToken: await _getStoredToken(_refreshTokenKey),
        );
      } else {
        return AppAuthResult.AuthResult.failure(error: '구글 로그인에 실패했습니다.');
      }
    } catch (e) {
      return _handleAuthError(e, '구글 로그인');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
      await _clearStoredTokens();
      print('✅ 로그아웃 완료');
    } catch (e) {
      print('❌ 로그아웃 실패: $e');
      // 로컬 토큰은 삭제
      await _clearStoredTokens();
      rethrow;
    }
  }

  /// 현재 사용자 정보 조회
  Future<AppAuthResult.AuthResult?> getCurrentUser() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        return null;
      }

      final user = await Amplify.Auth.getCurrentUser();
      final storedEmail = await _getStoredValue(_emailKey);

      return AppAuthResult.AuthResult.success(
        user: user,
        loginMethod: 'COGNITO',
        accessToken: await _getStoredToken(_accessTokenKey),
        refreshToken: await _getStoredToken(_refreshTokenKey),
      );
    } catch (e) {
      print('❌ 현재 사용자 조회 실패: $e');
      return null;
    }
  }

  /// 토큰 갱신
  Future<AppAuthResult.AuthResult> refreshTokens() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession(
        options: const FetchAuthSessionOptions(forceRefresh: true),
      );

      if (session.isSignedIn) {
        await _saveTokensFromSession(session);
        
        return AppAuthResult.AuthResult.success(
          user: await Amplify.Auth.getCurrentUser(),
          loginMethod: 'TOKEN_REFRESH',
          accessToken: await _getStoredToken(_accessTokenKey),
          refreshToken: await _getStoredToken(_refreshTokenKey),
        );
      } else {
        await _clearStoredTokens();
        return AppAuthResult.AuthResult.failure(error: '토큰 갱신에 실패했습니다. 다시 로그인해주세요.');
      }
    } catch (e) {
      await _clearStoredTokens();
      return _handleAuthError(e, '토큰 갱신');
    }
  }

  /// 비밀번호 재설정 요청
  Future<AppAuthResult.AuthResult> resetPassword(String email) async {
    try {
      await Amplify.Auth.resetPassword(username: email);
      return AppAuthResult.AuthResult.success(
        user: null,
        loginMethod: 'PASSWORD_RESET',
      );
    } catch (e) {
      return _handleAuthError(e, '비밀번호 재설정');
    }
  }

  /// 비밀번호 재설정 확인
  Future<AppAuthResult.AuthResult> confirmResetPassword({
    required String email,
    required String confirmationCode,
    required String newPassword,
  }) async {
    try {
      await Amplify.Auth.confirmResetPassword(
        username: email,
        confirmationCode: confirmationCode,
        newPassword: newPassword,
      );
      
      return AppAuthResult.AuthResult.success(
        user: null,
        loginMethod: 'PASSWORD_RESET_CONFIRM',
      );
    } catch (e) {
      return _handleAuthError(e, '비밀번호 재설정 확인');
    }
  }


  // Private 헬퍼 메서드들

  /// 이메일 중복 확인
  Future<bool> _checkEmailExists(String email) async {
    try {
      // 이메일로 사용자 검색 시도
      // 먼저 저장된 username을 확인
      final savedUsername = await _secureStorage.read(key: 'username_$email');
      if (savedUsername != null) {
        print('로컬 저장소에서 중복 이메일 발견: $email (username: $savedUsername)');
        return true;
      }
      
      // Cognito에서 이메일 중복 확인 - 임시 비밀번호로 로그인 시도
      try {
        await Amplify.Auth.signIn(
          username: email,
          password: 'temp_password_for_check_123!',
        );
        // 로그인이 성공하면 사용자가 존재함
        await Amplify.Auth.signOut();
        print('Cognito에서 중복 이메일 발견: $email');
        return true;
      } catch (e) {
        if (e.toString().contains('UserNotFoundException')) {
          // 사용자가 존재하지 않음 - 중복 아님
          print('이메일 중복 없음: $email');
          return false;
        } else if (e.toString().contains('NotAuthorizedException') || 
                   e.toString().contains('UserNotConfirmedException')) {
          // 비밀번호가 틀렸지만 사용자는 존재함 - 중복임
          print('Cognito에서 중복 이메일 발견 (비밀번호 오류): $email');
          return true;
        } else {
          // 기타 에러 - 안전하게 중복 아님으로 처리
          print('이메일 중복 확인 중 에러, 중복 아님으로 처리: $e');
          return false;
        }
      }
    } catch (e) {
      print('이메일 중복 확인 실패: $e');
      // 확인할 수 없는 경우 안전하게 중복 아님으로 처리
      return false;
    }
  }

  /// 세션에서 토큰 저장
  Future<void> _saveTokensFromSession(AuthSession session) async {
    try {
      if (session is CognitoAuthSession) {
        final accessToken = session.userPoolTokensResult.value.accessToken;
        if (accessToken != null) {
          await _secureStorage.write(
            key: _accessTokenKey,
            value: accessToken.toString(),
          );
        }
        
        final refreshToken = session.userPoolTokensResult.value.refreshToken;
        if (refreshToken != null) {
          await _secureStorage.write(
            key: _refreshTokenKey,
            value: refreshToken,
          );
        }
        
        final idToken = session.userPoolTokensResult.value.idToken;
        if (idToken != null) {
          await _secureStorage.write(
            key: _idTokenKey,
            value: idToken.toString(),
          );
        }
      }
    } catch (e) {
      print('⚠️ 토큰 저장 실패: $e');
    }
  }

  /// 사용자 정보 저장
  Future<void> _saveUserInfo(AuthUser user, String email) async {
    try {
      await _secureStorage.write(key: _userIdKey, value: user.userId);
      if (email.isNotEmpty) {
        await _secureStorage.write(key: _emailKey, value: email);
      }
    } catch (e) {
      print('⚠️ 사용자 정보 저장 실패: $e');
    }
  }

  /// 저장된 토큰 조회
  Future<String?> _getStoredToken(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('⚠️ 토큰 조회 실패: $e');
      return null;
    }
  }

  /// 저장된 값 조회
  Future<String?> _getStoredValue(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('⚠️ 값 조회 실패: $e');
      return null;
    }
  }

  /// 저장된 토큰 및 정보 삭제
  Future<void> _clearStoredTokens() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _idTokenKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _emailKey);
    } catch (e) {
      print('⚠️ 토큰 삭제 실패: $e');
    }
  }

  /// 인증 에러 처리
  AppAuthResult.AuthResult _handleAuthError(dynamic error, String operation) {
    String errorMessage;
    
    print('AWS Cognito 에러 발생: $operation');
    print('에러 타입: ${error.runtimeType}');
    print('에러 메시지: $error');
    
    if (error is AuthException) {
      print('AuthException 상세: ${error.message}');
      switch (error.runtimeType.toString()) {
        case 'UserNotConfirmedException':
          errorMessage = '이메일 인증이 필요합니다.';
          break;
        case 'NotAuthorizedException':
          errorMessage = '아이디 또는 비밀번호가 올바르지 않습니다.';
          break;
        case 'UserNotFoundException':
          errorMessage = '존재하지 않는 사용자입니다.';
          break;
        case 'InvalidParameterException':
          errorMessage = '입력값이 올바르지 않습니다.';
          break;
        case 'TooManyRequestsException':
          errorMessage = '너무 많은 요청입니다. 잠시 후 다시 시도해주세요.';
          break;
        case 'NetworkException':
          errorMessage = '네트워크 연결을 확인해주세요.';
          break;
        case 'UsernameExistsException':
          errorMessage = '이미 사용 중인 이메일입니다.';
          break;
        case 'InvalidPasswordException':
          errorMessage = '비밀번호가 정책에 맞지 않습니다.';
          break;
        default:
          errorMessage = error.message;
      }
    } else {
      errorMessage = '$operation 중 오류가 발생했습니다: ${error.toString()}';
    }

    print('❌ $operation 실패: $errorMessage');
    return AppAuthResult.AuthResult.failure(error: errorMessage);
  }

  /// Access Token 유효성 검사
  Future<bool> isAccessTokenValid() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      return false;
    }
  }

  /// 자동 로그인 가능 여부 확인
  Future<bool> canAutoLogin() async {
    try {
      final accessToken = await _getStoredToken(_accessTokenKey);
      if (accessToken == null) return false;
      
      return await isAccessTokenValid();
    } catch (e) {
      return false;
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

  /// 이메일 인증 코드 확인
  Future<AppAuthResult.AuthResult> confirmSignUpCode({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      print('이메일 인증 코드 확인 시도: $email, 코드: $confirmationCode');
      
      // 저장된 username 가져오기
      final savedUsername = await _secureStorage.read(key: 'username_$email');
      if (savedUsername == null) {
        print('저장된 username이 없습니다.');
        return AppAuthResult.AuthResult.failure(error: '사용자 정보를 찾을 수 없습니다.');
      }
      
      print('저장된 username으로 인증: $savedUsername');
      
      // 인증 코드 확인
      final result = await Amplify.Auth.confirmSignUp(
        username: savedUsername,
        confirmationCode: confirmationCode,
      );
      
      print('인증 코드 확인 결과: isSignUpComplete=${result.isSignUpComplete}');
      
      if (result.isSignUpComplete) {
        print('✅ 이메일 인증 완료!');
        return AppAuthResult.AuthResult.success(
          loginMethod: 'COGNITO',
        );
      } else {
        return AppAuthResult.AuthResult.failure(error: '인증이 완료되지 않았습니다.');
      }
      
    } catch (e) {
      return _handleAuthError(e, '이메일 인증');
    }
  }

  /// 인증 코드 재전송
  Future<AppAuthResult.AuthResult> resendConfirmationCode({
    required String email,
  }) async {
    try {
      print('인증 코드 재전송: $email');
      
      // 저장된 username 가져오기
      final savedUsername = await _secureStorage.read(key: 'username_$email');
      if (savedUsername == null) {
        return AppAuthResult.AuthResult.failure(error: '사용자 정보를 찾을 수 없습니다.');
      }
      
      await Amplify.Auth.resendSignUpCode(username: savedUsername);
      print('✅ 인증 코드 재전송 완료');
      
      return AppAuthResult.AuthResult.success(
        user: null,
        loginMethod: 'COGNITO',
      );
      
    } catch (e) {
      return _handleAuthError(e, '인증 코드 재전송');
    }
  }


}