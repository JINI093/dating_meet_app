class Validators {
  static bool isEmail(String? value) {
    if (value == null) return false;
    final emailReg = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}');
    return emailReg.hasMatch(value);
  }

  static bool isPassword(String? value) {
    if (value == null) return false;
    // 8자 이상, 영문/숫자/특수문자 조합
    final pwReg = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}');
    return pwReg.hasMatch(value);
  }

  static bool isNotEmpty(String? value) => value != null && value.trim().isNotEmpty;
}
