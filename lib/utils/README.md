# 인증 유틸리티 가이드

이 디렉토리에는 데이팅 앱의 인증 시스템을 위한 종합적인 유틸리티들이 포함되어 있습니다.

## 📁 파일 구조

```
lib/utils/
├── auth_error_handler.dart      # 에러 처리 및 복구
├── auth_validators.dart         # 입력 검증 및 중복 확인
├── auth_ux_utils.dart          # 사용자 경험 개선
├── auth_usage_example.dart     # 사용 예시
└── README.md                   # 이 파일
```

## 🔧 주요 기능

### 1. AuthErrorHandler - 에러 처리 및 복구

AWS Cognito, 소셜 로그인, 전화번호 인증 등 다양한 인증 방식의 에러를 통합적으로 처리합니다.

#### 주요 기능:
- **AWS Cognito 에러 코드별 사용자 친화적 메시지**
- **소셜 로그인 에러 처리** (취소, 네트워크 오류 등)
- **전화번호 인증 에러 처리** (잘못된 번호, SMS 실패 등)
- **자동 재시도 로직** (네트워크 오류 시)
- **오프라인 상태 처리**

#### 사용 예시:
```dart
// 에러 처리
try {
  await loginWithEmail(email, password);
} catch (error) {
  final message = AuthErrorHandler.getErrorMessage(error, 'login');
  showErrorDialog(message);
}

// 자동 재시도
final result = await AuthErrorHandler.retryOperation(
  operation: () => loginWithEmail(email, password),
  maxAttempts: 3,
  shouldRetry: (error) => error.toString().contains('network'),
);
```

### 2. AuthValidators - 입력 검증 및 중복 확인

사용자 입력의 유효성을 검증하고 중복을 확인합니다.

#### 주요 기능:
- **아이디 형식 검증** (영문, 숫자, 길이)
- **비밀번호 강도 검증** (대소문자, 숫자, 특수문자)
- **이메일 형식 검증**
- **전화번호 형식 검증** (국가별)
- **실시간 중복 확인**

#### 사용 예시:
```dart
// 비밀번호 강도 검증
final passwordResult = AuthValidators.validatePassword(password);
if (passwordResult.strength == PasswordStrength.strong) {
  // 강한 비밀번호
}

// 실시간 검증
final result = AuthValidators.validateRealTime(
  value, 
  ValidationType.email
);

// 중복 확인
final isAvailable = await AuthValidators.checkUsernameAvailability(username);
```

### 3. AuthUXUtils - 사용자 경험 개선

사용자 편의성을 위한 다양한 기능을 제공합니다.

#### 주요 기능:
- **자동 완성** (이전 로그인 계정)
- **생체 인증 지원** (지문, Face ID)
- **로그인 기록 및 보안 알림**
- **다중 기기 로그인 감지**

#### 사용 예시:
```dart
// 생체 인증
final support = await AuthUXUtils.checkBiometricSupport();
if (support.isSupported) {
  final result = await AuthUXUtils.authenticateWithBiometric();
  if (result.success) {
    // 자동 로그인
  }
}

// 다중 기기 감지
final multiDevice = await AuthUXUtils.checkMultiDeviceLogin(username);
if (multiDevice.isMultiDevice) {
  // 보안 알림 생성
  await AuthUXUtils.addSecurityAlert(
    SecurityAlertType.newDevice,
    '새로운 기기에서 로그인이 감지되었습니다.',
  );
}
```

## 🚀 통합 사용법

### 로그인 화면에서의 사용

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 실시간 검증 설정
    _emailController.addListener(() {
      final result = AuthValidators.validateRealTime(
        _emailController.text, 
        ValidationType.email
      );
      setState(() {
        _emailError = result.isValid ? null : result.message;
      });
    });
  }

  Future<void> _login() async {
    try {
      // 로그인 시도
      await authService.login(_emailController.text, _passwordController.text);
      
      // 성공 시 계정 저장
      await AuthUXUtils.saveAccount(
        _emailController.text, 
        _emailController.text, 
        'email'
      );
      
      // 로그인 기록 추가
      await AuthUXUtils.addLoginRecord(
        _emailController.text, 
        'email', 
        true
      );
      
    } catch (error) {
      // 에러 처리
      await AuthErrorHandler.logError(error, 'login');
      final message = AuthErrorHandler.getErrorMessage(error, 'login');
      
      // 로그인 실패 기록
      await AuthUXUtils.addLoginRecord(
        _emailController.text, 
        'email', 
        false, 
        message
      );
      
      showErrorDialog(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 자동 완성 텍스트 필드
          FutureBuilder<Widget>(
            future: AuthUsageExample.buildAccountAutocomplete(),
            builder: (context, snapshot) {
              return snapshot.data ?? TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                  errorText: _emailError,
                ),
              );
            },
          ),
          
          // 비밀번호 강도 표시
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: '비밀번호'),
          ),
          AuthUsageExample.buildPasswordStrengthIndicator(
            _passwordController.text
          ),
          
          ElevatedButton(
            onPressed: _login,
            child: Text('로그인'),
          ),
        ],
      ),
    );
  }
}
```

### 회원가입 화면에서의 사용

```dart
Future<bool> _validateSignupForm() async {
  final summary = AuthValidators.validateAll(
    username: _usernameController.text,
    password: _passwordController.text,
    email: _emailController.text,
    phoneNumber: _phoneController.text,
  );
  
  if (!summary.isValid) {
    showValidationErrors(summary.errorMessages);
    return false;
  }
  
  // 중복 확인
  final usernameAvailable = await AuthValidators.checkUsernameAvailability(
    _usernameController.text
  );
  final emailAvailable = await AuthValidators.checkEmailAvailability(
    _emailController.text
  );
  
  if (!usernameAvailable || !emailAvailable) {
    showDuplicateError(usernameAvailable, emailAvailable);
    return false;
  }
  
  return true;
}
```

## 🔒 보안 기능

### 의심스러운 활동 감지

```dart
// 앱 시작 시 의심스러운 활동 확인
@override
void initState() {
  super.initState();
  _checkSuspiciousActivity();
}

Future<void> _checkSuspiciousActivity() async {
  final activities = await AuthUXUtils.detectSuspiciousActivity();
  
  for (final activity in activities) {
    switch (activity.severity) {
      case SuspiciousActivitySeverity.high:
        // 즉시 보안 알림 및 추가 인증 요구
        await _handleHighSeverityActivity(activity);
        break;
      case SuspiciousActivitySeverity.medium:
        // 보안 알림
        await _handleMediumSeverityActivity(activity);
        break;
      case SuspiciousActivitySeverity.low:
        // 로그만 기록
        await _handleLowSeverityActivity(activity);
        break;
    }
  }
}
```

### 보안 알림 관리

```dart
// 보안 알림 화면
class SecurityAlertsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('보안 알림')),
      body: FutureBuilder<Widget>(
        future: AuthUsageExample.buildSecurityAlerts(),
        builder: (context, snapshot) {
          return snapshot.data ?? CircularProgressIndicator();
        },
      ),
    );
  }
}
```

## 📊 통계 및 모니터링

### 로그인 통계

```dart
// 통계 화면
class LoginStatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인 통계')),
      body: FutureBuilder<Widget>(
        future: AuthUsageExample.buildLoginStatistics(),
        builder: (context, snapshot) {
          return snapshot.data ?? CircularProgressIndicator();
        },
      ),
    );
  }
}
```

### 에러 통계

```dart
// 에러 통계 확인
final errorStats = await AuthErrorHandler.getErrorStatistics();
print('총 에러 수: ${errorStats['totalErrors']}');
print('에러 타입별: ${errorStats['errorTypes']}');
```

## ⚙️ 설정 및 커스터마이징

### 에러 메시지 커스터마이징

```dart
// 커스텀 에러 메시지 추가
class CustomAuthErrorHandler extends AuthErrorHandler {
  static String getCustomErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'CUSTOM_ERROR':
        return '커스텀 에러 메시지';
      default:
        return AuthErrorHandler.getCognitoErrorMessage(errorCode);
    }
  }
}
```

### 검증 규칙 커스터마이징

```dart
// 커스텀 검증 규칙
class CustomAuthValidators extends AuthValidators {
  static ValidationResult validateCustomField(String value) {
    // 커스텀 검증 로직
    if (value.length < 3) {
      return ValidationResult(false, '최소 3자 이상 입력해주세요.');
    }
    return ValidationResult(true, '유효한 입력입니다.');
  }
}
```

## 🧪 테스트

### 단위 테스트 예시

```dart
void main() {
  group('AuthValidators Tests', () {
    test('이메일 검증 테스트', () {
      expect(
        AuthValidators.validateEmail('test@example.com').isValid, 
        true
      );
      expect(
        AuthValidators.validateEmail('invalid-email').isValid, 
        false
      );
    });
    
    test('비밀번호 강도 테스트', () {
      final weakPassword = AuthValidators.validatePassword('123');
      expect(weakPassword.strength, PasswordStrength.weak);
      
      final strongPassword = AuthValidators.validatePassword('StrongPass123!');
      expect(strongPassword.strength, PasswordStrength.strong);
    });
  });
}
```

## 📝 주의사항

1. **보안**: 민감한 정보는 `flutter_secure_storage`를 사용하여 저장하세요.
2. **성능**: 대량의 데이터 처리 시 백그라운드에서 실행하세요.
3. **사용자 경험**: 에러 메시지는 사용자 친화적으로 표시하세요.
4. **테스트**: 모든 기능에 대한 단위 테스트를 작성하세요.

## 🔄 업데이트 로그

- **v1.0.0**: 초기 버전 - 기본 에러 처리, 검증, UX 기능
- **v1.1.0**: 생체 인증, 다중 기기 감지 추가
- **v1.2.0**: 보안 알림, 의심스러운 활동 감지 추가

## 📞 지원

문제가 발생하거나 개선 사항이 있으면 개발팀에 문의하세요. 