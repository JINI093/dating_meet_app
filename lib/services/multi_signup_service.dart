import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:amplify_auth_cognito/amplify_auth_cognito.dart'; // Unnecessary import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
// import 'dart:io'; // Unused import
import 'multi_auth_service.dart';
import '../utils/point_exchange_validator.dart';

class MultiSignupService {
  final MultiAuthService _authService = MultiAuthService();
  // final ImagePicker _imagePicker = ImagePicker(); // Unused field

  // 1. 일반 회원가입 (아이디/비밀번호)
  Future<SignupResult> signUpWithCredentials({
    required String username,
    required String password,
    required String email,
    String? phoneNumber,
    String? name,
    required List<String> agreedTerms,
  }) async {
    try {
      // 약관 동의 검증
      if (!_validateTermsAgreement(agreedTerms)) {
        return SignupResult.failure('필수 약관에 동의해주세요.');
      }

      // 이메일 형식 검증
      if (!_isValidEmail(email)) {
        return SignupResult.failure('올바른 이메일 형식이 아닙니다.');
      }

      // 전화번호 형식 검증 (있는 경우)
      if (phoneNumber != null && !PointExchangeValidator.isValidPhoneNumber(phoneNumber)) {
        return SignupResult.failure('올바른 전화번호 형식이 아닙니다.');
      }

      final result = await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: email,
            if (phoneNumber != null) AuthUserAttributeKey.phoneNumber: phoneNumber,
            if (name != null) AuthUserAttributeKey.name: name,
            // AuthUserAttributeKey.custom('agreed_terms'): agreedTerms.join(','), // 커스텀 속성은 별도 처리 필요
          },
        ),
      );

      if (result.isSignUpComplete) {
        return SignupResult.success(
          userId: result.userId,
          needsConfirmation: false,
        );
      } else {
        return SignupResult.needsConfirmation(
          userId: result.userId,
          destination: result.nextStep.codeDeliveryDetails?.destination,
        );
      }
    } catch (e) {
      return SignupResult.failure('회원가입 오류: $e');
    }
  }

  // 2. 소셜 로그인 기반 회원가입 (추가 정보 입력)
  Future<SignupResult> completeSocialSignup({
    required String tempUserId,
    required String provider,
    String? additionalEmail,
    String? additionalPhone,
    Map<String, dynamic>? preferences,
    required List<String> agreedTerms,
    XFile? profileImage,
  }) async {
    try {
      // 약관 동의 검증
      if (!_validateTermsAgreement(agreedTerms)) {
        return SignupResult.failure('필수 약관에 동의해주세요.');
      }

      // 프로필 이미지 업로드 (있는 경우)
      String? profileImageUrl;
      if (profileImage != null) {
        profileImageUrl = await _uploadProfileImage(profileImage, tempUserId);
      }

      // 소셜 로그인으로 얻은 정보에 추가 정보를 결합
      final userInfo = {
        'userId': tempUserId,
        'provider': provider,
        'additionalEmail': additionalEmail,
        'additionalPhone': additionalPhone,
        'preferences': preferences,
        'agreedTerms': agreedTerms,
        'profileImageUrl': profileImageUrl,
        'signupCompletedAt': DateTime.now().toIso8601String(),
      };

      // AWS DynamoDB나 다른 저장소에 저장
      await _saveCompleteUserInfo(userInfo);

      return SignupResult.success(
        userId: tempUserId,
        needsConfirmation: false,
      );
    } catch (e) {
      return SignupResult.failure('회원가입 완료 오류: $e');
    }
  }

  // 3. 전화번호 기반 회원가입
  Future<SignupResult> signUpWithPhoneNumber({
    required String phoneNumber,
    String? name,
    String? email,
    required List<String> agreedTerms,
  }) async {
    try {
      // 약관 동의 검증
      if (!_validateTermsAgreement(agreedTerms)) {
        return SignupResult.failure('필수 약관에 동의해주세요.');
      }

      // 전화번호 형식 검증
      if (!PointExchangeValidator.isValidPhoneNumber(phoneNumber)) {
        return SignupResult.failure('올바른 전화번호 형식이 아닙니다.');
      }

      // AWS Cognito로 전화번호 인증 시작
      final authResult = await _authService.signInWithPhoneNumber(phoneNumber);

      if (authResult.success) {
        // 인증 성공 시 회원가입 완료 처리
        final userInfo = {
          'userId': authResult.user?.userId ?? phoneNumber,
          'provider': 'PHONE',
          'phoneNumber': phoneNumber,
          'name': name,
          'email': email,
          'agreedTerms': agreedTerms,
          'signupCompletedAt': DateTime.now().toIso8601String(),
        };

        await _saveCompleteUserInfo(userInfo);
        
        return SignupResult.success(
          userId: authResult.user?.userId ?? phoneNumber,
          needsConfirmation: false,
        );
      } else {
        // SMS 코드 전송이 필요한 경우
        return SignupResult.needsPhoneVerification(
          verificationId: 'cognito_verification',
          phoneNumber: phoneNumber,
          tempUserInfo: {
            'name': name,
            'email': email,
            'agreedTerms': agreedTerms,
          },
        );
      }
    } catch (e) {
      return SignupResult.failure('전화번호 회원가입 오류: $e');
    }
  }

  // 4. 전화번호 인증 완료 후 회원가입 완료
  Future<SignupResult> completePhoneSignup({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    Map<String, dynamic>? additionalInfo,
    XFile? profileImage,
  }) async {
    try {
      // SMS 코드 확인
      final authResult = await _authService.verifyPhoneCode(verificationId, smsCode);

      if (authResult.success) {
        // 프로필 이미지 업로드 (있는 경우)
        String? profileImageUrl;
        if (profileImage != null) {
          profileImageUrl = await _uploadProfileImage(profileImage, authResult.user?.userId ?? phoneNumber);
        }

        // 회원가입 완료 처리
        final userInfo = {
          'userId': authResult.user?.userId ?? phoneNumber,
          'provider': 'PHONE',
          'phoneNumber': phoneNumber,
          'profileImageUrl': profileImageUrl,
          ...?additionalInfo,
          'signupCompletedAt': DateTime.now().toIso8601String(),
        };

        await _saveCompleteUserInfo(userInfo);

        return SignupResult.success(
          userId: authResult.user?.userId ?? phoneNumber,
          needsConfirmation: false,
        );
      }

      return SignupResult.failure('전화번호 인증에 실패했습니다.');
    } catch (e) {
      return SignupResult.failure('전화번호 회원가입 완료 오류: $e');
    }
  }

  // 5. 이메일 인증 확인
  Future<SignupResult> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );

      if (result.isSignUpComplete) {
        return SignupResult.success(
          userId: username,
          needsConfirmation: false,
        );
      }

      return SignupResult.failure('이메일 인증에 실패했습니다.');
    } catch (e) {
      return SignupResult.failure('이메일 인증 오류: $e');
    }
  }

  // 6. 중복 검사
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      // Cognito에서 사용자명 중복 검사
      // 실제로는 AWS API를 통해 검사
      return true; // 임시 구현
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkEmailAvailability(String email) async {
    try {
      // 이메일 중복 검사
      // 실제로는 AWS API를 통해 검사
      return true; // 임시 구현
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkPhoneNumberAvailability(String phoneNumber) async {
    try {
      // 전화번호 중복 검사
      // 실제로는 AWS API를 통해 검사
      return true; // 임시 구현
    } catch (e) {
      return false;
    }
  }

  // 7. 프로필 이미지 업로드
  Future<String?> _uploadProfileImage(XFile imageFile, String userId) async {
    try {
      // AWS S3에 업로드하는 로직
      // 실제 구현에서는 Amplify Storage S3 사용
      
      final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      
      // 임시 구현 - 실제로는 S3 업로드
      return 'https://example.com/profiles/$fileName';
    } catch (e) {
      // print('프로필 이미지 업로드 오류: $e'); // TODO: Use proper logging
      return null;
    }
  }

  // 8. 약관 동의 검증
  bool _validateTermsAgreement(List<String> agreedTerms) {
    final requiredTerms = ['service', 'privacy']; // 필수 약관
    return requiredTerms.every((term) => agreedTerms.contains(term));
  }

  // 9. 이메일 형식 검증
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  // 10. 사용자 정보 저장
  Future<void> _saveCompleteUserInfo(Map<String, dynamic> userInfo) async {
    try {
      // AWS DynamoDB, RDS 또는 다른 저장소에 저장
      // 실제 구현에서는 Amplify DataStore 또는 GraphQL 사용
      
      // 로컬 캐시에도 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_info', userInfo.toString());
      await prefs.setString('signup_completed_at', userInfo['signupCompletedAt']);
    } catch (e) {
      // print('사용자 정보 저장 오류: $e'); // TODO: Use proper logging
    }
  }

  // 11. 회원가입 진행 상태 조회
  Future<SignupProgress> getSignupProgress(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final signupCompletedAt = prefs.getString('signup_completed_at');
      
      if (signupCompletedAt != null) {
        return SignupProgress.completed(userId: userId);
      }
      
      return SignupProgress.inProgress(userId: userId);
    } catch (e) {
      return SignupProgress.error(error: e.toString());
    }
  }

  // 12. 회원가입 취소
  Future<void> cancelSignup(String userId) async {
    try {
      // 임시 사용자 정보 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_info');
      await prefs.remove('signup_completed_at');
      
      // AWS에서도 삭제 (실제 구현 필요)
    } catch (e) {
      // print('회원가입 취소 오류: $e'); // TODO: Use proper logging
    }
  }
}

// 회원가입 결과 모델
class SignupResult {
  final bool isSuccess;
  final bool needsConfirmation;
  final bool needsPhoneVerification;
  final String? userId;
  final String? destination;
  final String? verificationId;
  final String? phoneNumber;
  final Map<String, dynamic>? tempUserInfo;
  final String? error;

  SignupResult.success({
    required this.userId,
    required this.needsConfirmation,
  }) : isSuccess = true, needsPhoneVerification = false, destination = null,
       verificationId = null, phoneNumber = null, tempUserInfo = null, error = null;

  SignupResult.needsConfirmation({
    required this.userId,
    required this.destination,
  }) : isSuccess = false, needsConfirmation = true, needsPhoneVerification = false,
       verificationId = null, phoneNumber = null, tempUserInfo = null, error = null;

  SignupResult.needsPhoneVerification({
    required this.verificationId,
    required this.phoneNumber,
    required this.tempUserInfo,
  }) : isSuccess = false, needsConfirmation = false, needsPhoneVerification = true,
       userId = null, destination = null, error = null;

  SignupResult.failure(this.error)
      : isSuccess = false, needsConfirmation = false, needsPhoneVerification = false,
        userId = null, destination = null, verificationId = null,
        phoneNumber = null, tempUserInfo = null;
}

// 회원가입 진행 상태 모델
class SignupProgress {
  final bool isCompleted;
  final bool isInProgress;
  final String? userId;
  final String? error;

  SignupProgress.completed({required this.userId})
      : isCompleted = true, isInProgress = false, error = null;

  SignupProgress.inProgress({required this.userId})
      : isCompleted = false, isInProgress = true, error = null;

  SignupProgress.error({required this.error})
      : isCompleted = false, isInProgress = false, userId = null;
} 