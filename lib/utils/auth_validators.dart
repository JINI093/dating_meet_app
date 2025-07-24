import 'package:shared_preferences/shared_preferences.dart';

class AuthValidators {
  // 아이디 형식 검증
  static ValidationResult validateUsername(String username) {
    if (username.isEmpty) {
      return ValidationResult(false, '아이디를 입력해주세요.');
    }
    
    if (username.length < 4) {
      return ValidationResult(false, '아이디는 4자 이상이어야 합니다.');
    }
    
    if (username.length > 20) {
      return ValidationResult(false, '아이디는 20자 이하여야 합니다.');
    }
    
    // 영문, 숫자, 언더스코어만 허용
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(username)) {
      return ValidationResult(false, '아이디는 영문, 숫자, 언더스코어(_)만 사용 가능합니다.');
    }
    
    // 연속된 언더스코어 금지
    if (username.contains('__')) {
      return ValidationResult(false, '연속된 언더스코어는 사용할 수 없습니다.');
    }
    
    // 시작과 끝에 언더스코어 금지
    if (username.startsWith('_') || username.endsWith('_')) {
      return ValidationResult(false, '아이디는 언더스코어로 시작하거나 끝날 수 없습니다.');
    }
    
    return ValidationResult(true, '사용 가능한 아이디입니다.');
  }

  // 비밀번호 강도 검증
  static PasswordStrengthResult validatePassword(String password) {
    if (password.isEmpty) {
      return PasswordStrengthResult(
        isValid: false,
        strength: PasswordStrength.weak,
        message: '비밀번호를 입력해주세요.',
        details: [],
      );
    }
    
    final details = <String>[];
    int score = 0;
    
    // 길이 검증
    if (password.length < 8) {
      details.add('8자 이상');
    } else {
      score += 1;
      if (password.length >= 12) score += 1;
    }
    
    // 대문자 포함
    if (!password.contains(RegExp(r'[A-Z]'))) {
      details.add('대문자 포함');
    } else {
      score += 1;
    }
    
    // 소문자 포함
    if (!password.contains(RegExp(r'[a-z]'))) {
      details.add('소문자 포함');
    } else {
      score += 1;
    }
    
    // 숫자 포함
    if (!password.contains(RegExp(r'[0-9]'))) {
      details.add('숫자 포함');
    } else {
      score += 1;
    }
    
    // 특수문자 포함 (필수)
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      details.add('특수문자 포함');
    } else {
      score += 1;
    }
    
    // 연속된 문자 검증 (완화)
    if (_hasConsecutiveChars(password)) {
      // 점수만 차감하고 에러 메시지는 표시하지 않음
      score -= 1;
    }
    
    // 반복된 문자 검증 (완화)
    if (_hasRepeatedChars(password)) {
      // 점수만 차감하고 에러 메시지는 표시하지 않음
      score -= 1;
    }
    
    // 강도 판정
    PasswordStrength strength;
    String message;
    bool isValid;
    
    if (score < 3) {
      strength = PasswordStrength.weak;
      message = '약한 비밀번호입니다.';
      isValid = false;
    } else if (score < 5) {
      strength = PasswordStrength.medium;
      message = '보통 비밀번호입니다.';
      isValid = details.isEmpty; // 모든 필수 조건이 충족되어야 함
    } else {
      strength = PasswordStrength.strong;
      message = '강한 비밀번호입니다.';
      isValid = details.isEmpty; // 모든 필수 조건이 충족되어야 함
    }
    
    return PasswordStrengthResult(
      isValid: isValid,
      strength: strength,
      message: message,
      details: details,
    );
  }

  // 연속된 문자 검증
  static bool _hasConsecutiveChars(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      final char1 = password.codeUnitAt(i);
      final char2 = password.codeUnitAt(i + 1);
      final char3 = password.codeUnitAt(i + 2);
      
      if (char2 == char1 + 1 && char3 == char2 + 1) {
        return true;
      }
    }
    return false;
  }

  // 반복된 문자 검증
  static bool _hasRepeatedChars(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      final char1 = password[i];
      final char2 = password[i + 1];
      final char3 = password[i + 2];
      
      if (char1 == char2 && char2 == char3) {
        return true;
      }
    }
    return false;
  }

  // 이메일 형식 검증
  static ValidationResult validateEmail(String email) {
    if (email.isEmpty) {
      return ValidationResult(false, '이메일을 입력해주세요.');
    }
    
    print('=== 이메일 검증 디버깅 ===');
    print('입력된 이메일: "$email"');
    print('이메일 길이: ${email.length}');
    print('이메일 문자들: ${email.codeUnits}');
    
    // 간단한 이메일 정규식 ($ 이스케이프 문제 수정)
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final regexMatch = emailRegex.hasMatch(email);
    
    print('정규식 매치 결과: $regexMatch');
    print('==========================');
    
    if (!regexMatch) {
      return ValidationResult(false, '올바른 이메일 형식이 아닙니다.');
    }
    
    // 도메인 검증
    final parts = email.split('@');
    if (parts.length != 2) {
      return ValidationResult(false, '올바른 이메일 형식이 아닙니다.');
    }
    
    final domain = parts[1];
    if (domain.length < 3 || !domain.contains('.')) {
      return ValidationResult(false, '올바른 이메일 형식이 아닙니다.');
    }
    
    return ValidationResult(true, '올바른 이메일 형식입니다.');
  }

  // 전화번호 형식 검증 (국가별)
  static ValidationResult validatePhoneNumber(String phoneNumber, String countryCode) {
    if (phoneNumber.isEmpty) {
      return ValidationResult(false, '전화번호를 입력해주세요.');
    }
    
    // 숫자만 추출
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    switch (countryCode) {
      case '+82': // 한국
        return _validateKoreanPhone(digits);
      case '+1': // 미국/캐나다
        return _validateUSPhone(digits);
      case '+81': // 일본
        return _validateJapanesePhone(digits);
      case '+86': // 중국
        return _validateChinesePhone(digits);
      default:
        return _validateGenericPhone(digits);
    }
  }

  // 한국 전화번호 검증
  static ValidationResult _validateKoreanPhone(String digits) {
    if (digits.length < 10 || digits.length > 11) {
      return ValidationResult(false, '전화번호는 10-11자리여야 합니다.');
    }
    
    // 휴대폰 번호 (010, 011, 016, 017, 018, 019)
    if (digits.startsWith('01') && digits.length == 11) {
      return ValidationResult(true, '올바른 휴대폰 번호입니다.');
    }
    
    // 지역번호 (02, 03x, 04x, 05x, 06x)
    if (digits.startsWith('02') && digits.length == 10) {
      return ValidationResult(true, '올바른 서울 지역번호입니다.');
    }
    
    if ((digits.startsWith('03') || digits.startsWith('04') || 
         digits.startsWith('05') || digits.startsWith('06')) && 
        digits.length == 10) {
      return ValidationResult(true, '올바른 지역번호입니다.');
    }
    
    return ValidationResult(false, '올바른 전화번호 형식이 아닙니다.');
  }

  // 미국 전화번호 검증
  static ValidationResult _validateUSPhone(String digits) {
    if (digits.length != 10) {
      return ValidationResult(false, '전화번호는 10자리여야 합니다.');
    }
    
    return ValidationResult(true, '올바른 전화번호 형식입니다.');
  }

  // 일본 전화번호 검증
  static ValidationResult _validateJapanesePhone(String digits) {
    if (digits.length < 10 || digits.length > 11) {
      return ValidationResult(false, '전화번호는 10-11자리여야 합니다.');
    }
    
    return ValidationResult(true, '올바른 전화번호 형식입니다.');
  }

  // 중국 전화번호 검증
  static ValidationResult _validateChinesePhone(String digits) {
    if (digits.length != 11) {
      return ValidationResult(false, '전화번호는 11자리여야 합니다.');
    }
    
    return ValidationResult(true, '올바른 전화번호 형식입니다.');
  }

  // 일반 전화번호 검증
  static ValidationResult _validateGenericPhone(String digits) {
    if (digits.length < 7 || digits.length > 15) {
      return ValidationResult(false, '전화번호는 7-15자리여야 합니다.');
    }
    
    return ValidationResult(true, '올바른 전화번호 형식입니다.');
  }

  // 실시간 중복 확인 (캐시 기반)
  static final Map<String, bool> _availabilityCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // 아이디 중복 확인
  static Future<bool> checkUsernameAvailability(String username) async {
    // 캐시 확인
    if (_availabilityCache.containsKey(username)) {
      final timestamp = _cacheTimestamps[username];
      if (timestamp != null && 
          DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _availabilityCache[username]!;
      }
    }
    
    try {
      // 실제 API 호출
      await Future.delayed(Duration(milliseconds: 500));
      
      // TODO: 실제 서버 API 호출 구현 필요
      // 현재는 모든 아이디가 사용 가능한 것으로 처리
      final isAvailable = true;
      
      // 캐시에 저장
      _availabilityCache[username] = isAvailable;
      _cacheTimestamps[username] = DateTime.now();
      
      return isAvailable;
    } catch (e) {
      // 에러 시 기본적으로 사용 가능으로 처리
      return true;
    }
  }

  // 이메일 중복 확인
  static Future<bool> checkEmailAvailability(String email) async {
    final cacheKey = 'email_$email';
    
    if (_availabilityCache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null && 
          DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _availabilityCache[cacheKey]!;
      }
    }
    
    try {
      await Future.delayed(Duration(milliseconds: 500));
      
      // TODO: 실제 서버 API 호출 구현 필요
      // 현재는 모든 이메일이 사용 가능한 것으로 처리
      final isAvailable = true;
      
      _availabilityCache[cacheKey] = isAvailable;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      return isAvailable;
    } catch (e) {
      return true;
    }
  }

  // 전화번호 중복 확인
  static Future<bool> checkPhoneNumberAvailability(String phoneNumber) async {
    final cacheKey = 'phone_$phoneNumber';
    
    if (_availabilityCache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null && 
          DateTime.now().difference(timestamp) < _cacheExpiry) {
        return _availabilityCache[cacheKey]!;
      }
    }
    
    try {
      await Future.delayed(Duration(milliseconds: 500));
      
      // TODO: 실제 서버 API 호출 구현 필요
      // 현재는 모든 전화번호가 사용 가능한 것으로 처리
      final isAvailable = true;
      
      _availabilityCache[cacheKey] = isAvailable;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      return isAvailable;
    } catch (e) {
      return true;
    }
  }

  // 캐시 정리
  static void clearCache() {
    _availabilityCache.clear();
    _cacheTimestamps.clear();
  }

  // 만료된 캐시 정리
  static void cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) >= _cacheExpiry) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _availabilityCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  // 실시간 검증 (입력 중 검증)
  static ValidationResult validateRealTime(String value, ValidationType type, [String? countryCode]) {
    switch (type) {
      case ValidationType.username:
        return validateUsername(value);
      case ValidationType.email:
        return validateEmail(value);
      case ValidationType.phoneNumber:
        return validatePhoneNumber(value, countryCode ?? '+82');
      default:
        return ValidationResult(true, '');
    }
  }

  // 종합 검증
  static ValidationSummary validateAll({
    required String username,
    required String password,
    required String email,
    String? phoneNumber,
    String? countryCode,
  }) {
    final results = <String, ValidationResult>{};
    
    results['username'] = validateUsername(username);
    final passwordResult = validatePassword(password);
    results['password'] = ValidationResult(passwordResult.isValid, passwordResult.message);
    results['email'] = validateEmail(email);
    
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      results['phoneNumber'] = validatePhoneNumber(phoneNumber, countryCode ?? '+82');
    }
    
    final isValid = results.values.every((result) => result.isValid);
    
    return ValidationSummary(
      isValid: isValid,
      results: results,
    );
  }
}

// 검증 결과 클래스
class ValidationResult {
  final bool isValid;
  final String message;

  ValidationResult(this.isValid, this.message);
}

// 비밀번호 강도 결과 클래스
class PasswordStrengthResult {
  final bool isValid;
  final PasswordStrength strength;
  final String message;
  final List<String> details;

  PasswordStrengthResult({
    required this.isValid,
    required this.strength,
    required this.message,
    required this.details,
  });
}

// 비밀번호 강도 열거형
enum PasswordStrength {
  weak,
  medium,
  strong,
}

// 검증 타입 열거형
enum ValidationType {
  username,
  password,
  email,
  phoneNumber,
}

// 종합 검증 결과 클래스
class ValidationSummary {
  final bool isValid;
  final Map<String, ValidationResult> results;

  ValidationSummary({
    required this.isValid,
    required this.results,
  });

  List<String> get errorMessages {
    return results.entries
        .where((entry) => !entry.value.isValid)
        .map((entry) => entry.value.message)
        .toList();
  }

  List<String> get validFields {
    return results.entries
        .where((entry) => entry.value.isValid)
        .map((entry) => entry.key)
        .toList();
  }
} 