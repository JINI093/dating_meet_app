import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userToken;
  Map<String, dynamic>? _userData;

  bool get isAuthenticated => _isAuthenticated;
  String? get userToken => _userToken;
  Map<String, dynamic>? get userData => _userData;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _userToken = prefs.getString('user_token');
    _isAuthenticated = _userToken != null;
    
    if (_isAuthenticated) {
      // 사용자 데이터 로드
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        // JSON 파싱 로직 추가 필요
        // _userData = jsonDecode(userDataString);
      }
    }
    
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      // Firebase Auth 로그인 로직
      // final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
      
      // 임시 로그인 로직 (실제로는 Firebase Auth 사용)
      if (email == 'admin@example.com' && password == 'password') {
        _userToken = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
        _isAuthenticated = true;
        _userData = {
          'id': '1',
          'email': email,
          'name': '관리자',
          'role': 'admin',
        };
        
        // 토큰 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', _userToken!);
        await prefs.setString('user_data', '{"id":"1","email":"$email","name":"관리자","role":"admin"}');
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print('로그인 오류: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Firebase Auth 로그아웃 로직
      // await FirebaseAuth.instance.signOut();
      
      _isAuthenticated = false;
      _userToken = null;
      _userData = null;
      
      // 저장된 데이터 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_token');
      await prefs.remove('user_data');
      
      notifyListeners();
    } catch (e) {
      print('로그아웃 오류: $e');
    }
  }

  Future<void> updateUserData(Map<String, dynamic> newData) async {
    _userData = newData;
    
    final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('user_data', jsonEncode(newData));
    
    notifyListeners();
  }
} 