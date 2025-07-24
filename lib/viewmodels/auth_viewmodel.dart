import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final String? userToken;
  final Map<String, dynamic>? userData;

  const AuthState({
    this.isAuthenticated = false,
    this.userToken,
    this.userData,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userToken,
    Map<String, dynamic>? userData,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userToken: userToken ?? this.userToken,
      userData: userData ?? this.userData,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel() : super(const AuthState());

  Future<bool> signIn(String email, String password) async {
    // 임시 로그인 로직 (실제로는 Firebase Auth 사용)
    if (email == 'admin@example.com' && password == 'password') {
      state = state.copyWith(
        isAuthenticated: true,
        userToken: 'dummy_token',
        userData: {
          'id': '1',
          'email': email,
          'name': '관리자',
          'role': 'admin',
        },
      );
      return true;
    }
    return false;
  }

  void signOut() {
    state = const AuthState();
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel();
}); 