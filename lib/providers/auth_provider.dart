import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> checkAutoLogin() async {
    _isLoading = true;
    notifyListeners();
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        _isLoggedIn = true;
        _user = {'username': currentUser.username, 'userId': currentUser.userId};
      } else {
        _isLoggedIn = false;
        _user = null;
      }
      _error = null;
    } catch (e) {
      _isLoggedIn = false;
      _user = null;
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.signIn(email: email, password: password);
      if (result.isSignedIn) {
        _isLoggedIn = true;
        _user = {'username': email};
        _error = null;
        notifyListeners();
        return true;
      } else {
        _isLoggedIn = false;
        _user = null;
        _error = '로그인 실패';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoggedIn = false;
      _user = null;
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signOut();
      _isLoggedIn = false;
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
} 