import 'package:amplify_flutter/amplify_flutter.dart';

class AuthService {
  // 회원가입
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    Map<String, String>? attributes,
  }) async {
    final userAttributes = <AuthUserAttributeKey, String>{
      AuthUserAttributeKey.email: email,
      if (attributes != null)
        ...attributes.map((k, v) => MapEntry(CognitoUserAttributeKey.custom(k), v)),
    };
    return await Amplify.Auth.signUp(
      username: email,
      password: password,
      options: SignUpOptions(userAttributes: userAttributes),
    );
  }

  // 이메일 인증 코드 확인
  Future<SignUpResult> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    return await Amplify.Auth.confirmSignUp(
      username: email,
      confirmationCode: confirmationCode,
    );
  }

  // 로그인
  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    return await Amplify.Auth.signIn(
      username: email,
      password: password,
    );
  }

  // 로그아웃
  Future<void> signOut() async {
    await Amplify.Auth.signOut();
  }

  // 현재 사용자 정보
  Future<AuthUser?> getCurrentUser() async {
    try {
      return await Amplify.Auth.getCurrentUser();
    } catch (_) {
      return null;
    }
  }

  // 비밀번호 재설정(코드 요청)
  Future<ResetPasswordResult> resetPassword({
    required String email,
  }) async {
    return await Amplify.Auth.resetPassword(username: email);
  }

  // 비밀번호 재설정(코드 확인 및 변경)
  Future<ResetPasswordResult> confirmResetPassword({
    required String email,
    required String newPassword,
    required String confirmationCode,
  }) async {
    return await Amplify.Auth.confirmResetPassword(
      username: email,
      newPassword: newPassword,
      confirmationCode: confirmationCode,
    );
  }

  // 사용자 속성 수정 (여러 개)
  Future<Map<AuthUserAttributeKey, UpdateUserAttributeResult>> updateUserAttributes({
    required Map<String, String> attributes,
  }) async {
    final attrs = attributes.entries.map((e) => AuthUserAttribute(
      userAttributeKey: CognitoUserAttributeKey.custom(e.key),
      value: e.value,
    )).toList();
    return await Amplify.Auth.updateUserAttributes(attributes: attrs);
  }

  // 계정 삭제
  Future<void> deleteUser() async {
    await Amplify.Auth.deleteUser();
  }
}
