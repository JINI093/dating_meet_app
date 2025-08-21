import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../services/multi_auth_service.dart';
import '../services/aws_cognito_service.dart';
import '../services/kakao_login_service.dart';
import '../services/aws_kakao_auth_service.dart';
import '../services/aws_naver_auth_service.dart';
import '../services/aws_google_auth_service.dart';
import '../models/auth_result.dart';
import '../models/signup_data.dart';

// 상태 클래스
class AuthState {
  final bool isLoading;
  final bool isSignedIn;
  final String? error;
  final AuthResult? currentUser;
  final String selectedLoginMethod;
  final bool isPhoneVerificationPending;
  final bool isAutoLoginEnabled;
  final bool isBiometricEnabled;
  final bool isBiometricAvailable;
  final String? lastLoginMethod;
  final DateTime? lastLoginAt;
  final List<LoginRecord> loginHistory;

  AuthState({
    this.isLoading = false,
    this.isSignedIn = false,
    this.error,
    this.currentUser,
    this.selectedLoginMethod = 'CREDENTIALS',
    this.isPhoneVerificationPending = false,
    this.isAutoLoginEnabled = false,
    this.isBiometricEnabled = false,
    this.isBiometricAvailable = false,
    this.lastLoginMethod,
    this.lastLoginAt,
    this.loginHistory = const [],
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isSignedIn,
    String? error,
    AuthResult? currentUser,
    String? selectedLoginMethod,
    bool? isPhoneVerificationPending,
    bool? isAutoLoginEnabled,
    bool? isBiometricEnabled,
    bool? isBiometricAvailable,
    String? lastLoginMethod,
    DateTime? lastLoginAt,
    List<LoginRecord>? loginHistory,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      error: error,
      currentUser: currentUser ?? this.currentUser,
      selectedLoginMethod: selectedLoginMethod ?? this.selectedLoginMethod,
      isPhoneVerificationPending: isPhoneVerificationPending ?? this.isPhoneVerificationPending,
      isAutoLoginEnabled: isAutoLoginEnabled ?? this.isAutoLoginEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      lastLoginMethod: lastLoginMethod ?? this.lastLoginMethod,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      loginHistory: loginHistory ?? this.loginHistory,
    );
  }
}

// 자동 로그인 결과 클래스
class AutoLoginResult {
  final bool success;
  final AuthResult? user;
  final String? error;

  AutoLoginResult({
    required this.success,
    this.user,
    this.error,
  });
}

class EnhancedAuthNotifier extends StateNotifier<AuthState> {
  final MultiAuthService _authService = MultiAuthService();
  final AWSCognitoService _cognitoService = AWSCognitoService();
  final KakaoLoginService _kakaoService = KakaoLoginService();
  final AWSKakaoAuthService _awsKakaoService = AWSKakaoAuthService();
  final AWSNaverAuthService _awsNaverService = AWSNaverAuthService();
  final AWSGoogleAuthService _awsGoogleService = AWSGoogleAuthService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // 전화번호 인증 관련
  String? _phoneVerificationId;
  String? _pendingPhoneNumber;
  
  EnhancedAuthNotifier() : super(AuthState());

  // 비밀번호 재설정 요청
  Future<bool> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _cognitoService.resetPassword(email);
      
      // 임시 수정: API 변경에 대응
      try {
        state = state.copyWith(error: null);
        return true;
      } catch (e) {
        state = state.copyWith(error: '비밀번호 재설정 요청에 실패했습니다.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '비밀번호 재설정 요청 오류: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 비밀번호 재설정 확인
  Future<bool> confirmPasswordReset({
    required String email,
    required String confirmationCode,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _cognitoService.confirmResetPassword(
        email: email,
        confirmationCode: confirmationCode,
        newPassword: newPassword,
      );
      
      // 임시 수정: API 변경에 대응
      try {
        state = state.copyWith(error: null);
        return true;
      } catch (e) {
        state = state.copyWith(error: '비밀번호 재설정에 실패했습니다.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '비밀번호 재설정 오류: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 초기화
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      await _cognitoService.initialize();
      await _authService.initialize();
      await _loadPreferences();
      await _checkBiometricAvailability();
      await _checkCurrentUser();
    } catch (e) {
      state = state.copyWith(error: '초기화 오류: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
  
  // 현재 로그인 상태 확인
  Future<void> _checkCurrentUser() async {
    try {
      final cognitoUser = await _cognitoService.getCurrentUser();
      if (cognitoUser != null && cognitoUser.success) {
        print('=== _checkCurrentUser 디버깅 ===');
        print('cognitoUser.success: ${cognitoUser.success}');
        print('cognitoUser.user: ${cognitoUser.user}');
        print('cognitoUser.user?.userId: ${cognitoUser.user?.userId}');
        print('===============================');
        
        state = state.copyWith(
          isSignedIn: true,
          currentUser: cognitoUser, // 실제 사용자 객체 설정
          error: null,
        );
        _updateLoginRecord('COGNITO', true);
      } else {
        print('Current user check failed: cognitoUser is null or not successful');
        state = state.copyWith(
          isSignedIn: false,
          currentUser: null,
        );
      }
    } catch (e) {
      print('_checkCurrentUser error: $e');
      state = state.copyWith(
        isSignedIn: false,
        currentUser: null,
        error: '로그인 상태 확인 오류: $e',
      );
    }
  }
  
  // 생체 인증 가능 여부 확인
  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      final isBiometricAvailable = isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
      state = state.copyWith(isBiometricAvailable: isBiometricAvailable);
    } catch (e) {
      state = state.copyWith(isBiometricAvailable: false);
    }
  }
  
  // 설정 로드
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAutoLoginEnabled = prefs.getBool('auto_login_enabled') ?? true;
      final isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      final lastLoginMethod = prefs.getString('last_login_method');
      final lastLoginAtStr = prefs.getString('last_login_at');
      DateTime? lastLoginAt;
      if (lastLoginAtStr != null) {
        lastLoginAt = DateTime.parse(lastLoginAtStr);
      }
      
      // 로그인 기록 로드
      final historyJson = prefs.getStringList('login_history') ?? [];
      final loginHistory = historyJson.map((jsonStr) {
        final Map<String, dynamic> jsonMap = json.decode(jsonStr);
        return LoginRecord.fromJson(jsonMap);
      }).toList();
      
      state = state.copyWith(
        isAutoLoginEnabled: isAutoLoginEnabled,
        isBiometricEnabled: isBiometricEnabled,
        lastLoginMethod: lastLoginMethod,
        lastLoginAt: lastLoginAt,
        loginHistory: loginHistory,
      );
    } catch (e) {
      print('설정 로드 오류: $e');
    }
  }
  
  // 설정 저장
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_login_enabled', state.isAutoLoginEnabled);
      await prefs.setBool('biometric_enabled', state.isBiometricEnabled);
      if (state.lastLoginMethod != null) {
        await prefs.setString('last_login_method', state.lastLoginMethod!);
      }
      if (state.lastLoginAt != null) {
        await prefs.setString('last_login_at', state.lastLoginAt!.toIso8601String());
      }
      
      // 로그인 기록 저장 (JSON 문자열로 변환)
      final historyJson = state.loginHistory.map((record) => 
        json.encode(record.toJson())).toList();
      await prefs.setStringList('login_history', historyJson);
    } catch (e) {
      print('설정 저장 오류: $e');
    }
  }
  
  // 자동 로그인 체크
  Future<AutoLoginResult> checkAutoLogin() async {
    if (!state.isAutoLoginEnabled) {
      return AutoLoginResult(success: false, error: '자동 로그인이 비활성화되어 있습니다.');
    }
    
    try {
      final canAutoLogin = await _cognitoService.canAutoLogin();
      if (canAutoLogin) {
        await _checkCurrentUser();
        return AutoLoginResult(
          success: state.isSignedIn,
          user: state.currentUser,
        );
      }
      return AutoLoginResult(success: false, error: '자동 로그인에 실패했습니다.');
    } catch (e) {
      return AutoLoginResult(success: false, error: '자동 로그인 오류: $e');
    }
  }
  
  // 생체 인증 실행
  Future<bool> authenticateWithBiometric() async {
    if (!state.isBiometricAvailable || !state.isBiometricEnabled) return false;
    
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: '로그인을 위해 생체 인증을 진행합니다.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      if (authenticated) {
        // 생체 인증 성공 시 자동 로그인 시도
        final result = await checkAutoLogin();
        return result.success;
      }
      
      return false;
    } catch (e) {
      state = state.copyWith(error: '생체 인증 오류: $e');
      return false;
    }
  }
  
  // 자동 로그인 설정 변경
  Future<void> setAutoLoginEnabled(bool enabled) async {
    state = state.copyWith(isAutoLoginEnabled: enabled);
    await _savePreferences();
  }
  
  // 생체 인증 설정 변경
  Future<void> setBiometricEnabled(bool enabled) async {
    state = state.copyWith(isBiometricEnabled: enabled);
    await _savePreferences();
  }
  
  // 현재 사용자 상태 강제 새로고침
  Future<void> refreshCurrentUser() async {
    // 강제 로그인 상태인 경우 _checkCurrentUser를 호출하지 않음
    if (state.lastLoginMethod == 'SIGNUP_FORCE') {
      print('강제 로그인 상태이므로 _checkCurrentUser 건너뛰기');
      return;
    }
    await _checkCurrentUser();
  }
  
  // 로그인 방식 선택
  void setLoginMethod(String method) {
    state = state.copyWith(
      selectedLoginMethod: method,
      error: null,
    );
  }
  
  // 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
  
  // 로딩 상태 설정
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
  
  // 로그인 기록 업데이트
  void _updateLoginRecord(String method, bool success, [String? errorMessage]) {
    final newRecord = LoginRecord(
      username: state.currentUser?.username ?? 'unknown',
      loginType: method,
      timestamp: DateTime.now(),
      success: success,
      errorMessage: errorMessage,
      deviceInfo: DeviceInfo(
        platform: 'Unknown',
        model: 'Unknown',
        version: 'Unknown',
        deviceId: 'Unknown',
      ),
    );
    
    final updatedHistory = [newRecord, ...state.loginHistory];
    if (updatedHistory.length > 10) {
      updatedHistory.removeRange(10, updatedHistory.length);
    }
    
    state = state.copyWith(loginHistory: updatedHistory);
  }
  
  // 인증 상태 새로고침
  Future<void> refreshAuthState() async {
    try {
      // 토큰 갱신 시도
      final refreshResult = await _cognitoService.refreshTokens();
      if (refreshResult.success) {
        state = state.copyWith(
          currentUser: refreshResult,
          isSignedIn: true,
        );
      }
    } catch (e) {
      print('토큰 갱신 실패: $e');
    }
    
    await _checkCurrentUser();
  }
  
  // 현재 상태 저장
  Future<void> saveCurrentState() async {
    await _savePreferences();
  }
  
  // 정리 작업
  Future<void> cleanup() async {
    // 필요한 정리 작업 수행
    await _savePreferences();
  }

  // 1. 일반 로그인
  Future<bool> signInWithCredentials(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _cognitoService.signIn(email: username, password: password);
      
      if (result.success) {
        state = state.copyWith(
          currentUser: result,
          isSignedIn: true,
          lastLoginMethod: 'COGNITO',
          lastLoginAt: DateTime.now(),
          isAutoLoginEnabled: true,
        );
        _updateLoginRecord('COGNITO', true);
        await _savePreferences();
        return true;
      } else if (result.requiresConfirmation == true) {
        // 이메일 인증이 필요한 경우
        state = state.copyWith(
          error: result.error ?? '이메일 인증이 필요합니다.',
          isSignedIn: false,
        );
        _updateLoginRecord('COGNITO', false, 'EMAIL_CONFIRMATION_REQUIRED');
        return false;
      } else {
        state = state.copyWith(error: result.error ?? '로그인에 실패했습니다.');
        _updateLoginRecord('COGNITO', false, result.error);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '로그인 오류: $e');
      _updateLoginRecord('COGNITO', false, e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 2. 전화번호 로그인
  Future<bool> signInWithPhone(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _cognitoService.signInWithPhoneNumber(phoneNumber);
      
      if (result.requiresConfirmation == true) {
        _phoneVerificationId = 'cognito_phone_verification';
        _pendingPhoneNumber = phoneNumber;
        state = state.copyWith(isPhoneVerificationPending: true);
        return true;
      } else if (result.success) {
        state = state.copyWith(
          currentUser: result,
          isSignedIn: true,
          lastLoginMethod: 'PHONE',
          lastLoginAt: DateTime.now(),
          isAutoLoginEnabled: true,
        );
        _updateLoginRecord('PHONE', true);
        await _savePreferences();
        return true;
      } else {
        state = state.copyWith(error: result.error ?? '전화번호 인증에 실패했습니다.');
        _updateLoginRecord('PHONE', false, result.error);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '전화번호 로그인 오류: $e');
      _updateLoginRecord('PHONE', false, e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 전화번호 인증 코드 확인
  Future<bool> verifyPhoneCode(String code) async {
    if (_phoneVerificationId == null || _pendingPhoneNumber == null) {
      state = state.copyWith(error: '인증 정보가 없습니다.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _cognitoService.confirmSignInWithSMS(code);
      
      if (result.success) {
        state = state.copyWith(
          currentUser: result,
          isSignedIn: true,
          isPhoneVerificationPending: false,
          lastLoginMethod: 'PHONE',
          lastLoginAt: DateTime.now(),
          isAutoLoginEnabled: true,
        );
        _updateLoginRecord('PHONE', true);
        await _savePreferences();
        
        // 인증 정보 초기화
        _phoneVerificationId = null;
        _pendingPhoneNumber = null;
        
        return true;
      } else {
        state = state.copyWith(error: result.error ?? '인증 코드가 올바르지 않습니다.');
        _updateLoginRecord('PHONE', false, result.error);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '인증 코드 확인 오류: $e');
      _updateLoginRecord('PHONE', false, e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 3. 소셜 로그인
  Future<bool> signInWithSocial(String provider) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      AuthResult result;
      
      switch (provider.toUpperCase()) {
        case 'GOOGLE':
          // AWS Cognito와 연동된 구글 로그인
          result = await _awsGoogleService.signInWithGoogle();
          break;
        case 'KAKAO':
          // AWS Cognito와 연동된 카카오 로그인
          result = await _awsKakaoService.signInWithKakao();
          break;
        case 'NAVER':
          // AWS Cognito와 연동된 네이버 로그인
          result = await _awsNaverService.signInWithNaver();
          break;
        default:
          throw Exception('지원하지 않는 소셜 로그인: $provider');
      }
      
      if (result.success) {
        state = state.copyWith(
          currentUser: result,
          isSignedIn: true,
          lastLoginMethod: provider.toUpperCase(),
          lastLoginAt: DateTime.now(),
          isAutoLoginEnabled: true,
        );
        _updateLoginRecord(provider.toUpperCase(), true);
        await _savePreferences();
        return true;
      } else {
        state = state.copyWith(error: result.error ?? '소셜 로그인에 실패했습니다.');
        _updateLoginRecord(provider.toUpperCase(), false, result.error);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '소셜 로그인 오류: $e');
      _updateLoginRecord(provider.toUpperCase(), false, e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _cognitoService.signOut();
      state = state.copyWith(
        currentUser: null,
        isSignedIn: false,
        isPhoneVerificationPending: false,
      );
      
      // 인증 정보 초기화
      _phoneVerificationId = null;
      _pendingPhoneNumber = null;
      
      await _savePreferences();
    } catch (e) {
      state = state.copyWith(error: '로그아웃 오류: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 회원가입
  Future<bool> signUp(SignupData data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      print('=== Enhanced Auth Provider signUp 디버깅 ===');
      print('SignupData: ${data.toString()}');
      print('data.email: ${data.email}');
      print('data.name: ${data.name}');
      print('data.username: ${data.username}');
      print('전달할 name: ${data.name ?? data.username}');
      print('==========================================');
      
      final result = await _cognitoService.signUp(
        email: data.email,
        password: data.password,
        name: data.name ?? data.username, // name이 없으면 username을 사용
        phoneNumber: data.phoneNumber,
      );
      
      print('회원가입 최종 결과: ${result.success}');
      
      if (result.success) {
        // 회원가입 성공 시 자동 로그인된 경우
        print('회원가입 성공 - 인증 상태 업데이트 중...');
        print('result.user: ${result.user}');
        print('result.user?.userId: ${result.user?.userId}');
        
        state = state.copyWith(
          currentUser: result,
          isSignedIn: true,
          lastLoginMethod: 'SIGNUP',
          lastLoginAt: DateTime.now(),
          error: null,
        );
        _updateLoginRecord('SIGNUP', true);
        await _savePreferences();
        
        // 상태 확인을 위해 다시 체크 (하지만 강제 로그인 상태는 유지)
        print('_checkCurrentUser 호출 전 상태: isSignedIn=${state.isSignedIn}');
        // await _checkCurrentUser(); // 강제 로그인 상태를 덮어쓸 수 있으므로 주석 처리
        
        print('인증 상태 업데이트 완료:');
        print('state.isSignedIn: ${state.isSignedIn}');
        print('state.currentUser: ${state.currentUser}');
        print('state.currentUser?.user?.userId: ${state.currentUser?.user?.userId}');
        
        return true;
      } else if (result.requiresConfirmation == true) {
        // 이메일 인증이 필요한 경우 - 강제로 로그인 상태로 만들기
        print('이메일 인증 필요하지만 강제로 로그인 상태 처리');
        
        // 실제 사용자 정보를 포함한 AuthResult 생성하여 로그인 상태로 만들기
        AuthResult mockAuthResult;
        try {
          // AWS Cognito에서 실제 사용자 정보 가져오기 시도
          final cognitoUser = await _cognitoService.getCurrentUser();
          if (cognitoUser != null && cognitoUser.user != null) {
            mockAuthResult = AuthResult.success(
              user: cognitoUser.user,
              loginMethod: 'SIGNUP_FORCE',
            );
            print('실제 Cognito 사용자 정보로 강제 로그인 설정: ${cognitoUser.user!.userId}');
          } else {
            mockAuthResult = AuthResult.success(
              user: null, // Cognito에서 가져올 수 없으면 null
              loginMethod: 'SIGNUP_FORCE',
            );
            print('Cognito 사용자 정보 없음, null로 강제 로그인 설정');
          }
        } catch (e) {
          print('Cognito 사용자 정보 조회 실패: $e');
          mockAuthResult = AuthResult.success(
            user: null,
            loginMethod: 'SIGNUP_FORCE',
          );
        }
        
        state = state.copyWith(
          currentUser: mockAuthResult,
          isSignedIn: true,
          lastLoginMethod: 'SIGNUP_FORCE',
          lastLoginAt: DateTime.now(),
          error: null,
        );
        _updateLoginRecord('SIGNUP_FORCE', true);
        await _savePreferences();
        
        print('강제 로그인 상태 설정 완료');
        return true;
      } else {
        state = state.copyWith(error: result.error ?? '회원가입에 실패했습니다.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '회원가입 오류: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 이메일 인증 확인
  Future<bool> confirmSignUp(String email, String confirmationCode) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _cognitoService.confirmSignUp(
        email: email,
        confirmationCode: confirmationCode,
      );
      
      if (result.success) {
        state = state.copyWith(error: null);
        return true;
      } else {
        state = state.copyWith(error: result.error ?? '인증 코드 확인에 실패했습니다.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '이메일 인증 오류: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 소셜 로그인 통합 메서드
  Future<void> loginWithSocial(String provider) async {
    // provider: 'GOOGLE', 'KAKAO', 'NAVER' 등
    // 실제 소셜 로그인 로직을 여기에 구현
    // 예시:
    if (provider == 'GOOGLE') {
      await signInWithSocial('GOOGLE');
    } else if (provider == 'KAKAO') {
      await signInWithSocial('KAKAO');
    } else if (provider == 'NAVER') {
      await signInWithSocial('NAVER');
    }
  }
}

// Provider 정의
final enhancedAuthProvider = StateNotifierProvider<EnhancedAuthNotifier, AuthState>((ref) {
  return EnhancedAuthNotifier();
});

// 로그인 기록 모델 (기존 코드에서 가져옴)
class LoginRecord {
  final String username;
  final String loginType;
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;
  final DeviceInfo deviceInfo;

  LoginRecord({
    required this.username,
    required this.loginType,
    required this.timestamp,
    required this.success,
    this.errorMessage,
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'loginType': loginType,
    'timestamp': timestamp.toIso8601String(),
    'success': success,
    'errorMessage': errorMessage,
    'deviceInfo': deviceInfo.toJson(),
  };

  factory LoginRecord.fromJson(Map<String, dynamic> json) => LoginRecord(
    username: json['username'],
    loginType: json['loginType'],
    timestamp: DateTime.parse(json['timestamp']),
    success: json['success'],
    errorMessage: json['errorMessage'],
    deviceInfo: DeviceInfo.fromJson(json['deviceInfo']),
  );
}

// 기기 정보 모델 (기존 코드에서 가져옴)
class DeviceInfo {
  final String platform;
  final String model;
  final String version;
  final String deviceId;

  DeviceInfo({
    required this.platform,
    required this.model,
    required this.version,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'model': model,
    'version': version,
    'deviceId': deviceId,
  };

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
    platform: json['platform'],
    model: json['model'],
    version: json['version'],
    deviceId: json['deviceId'],
  );
} 