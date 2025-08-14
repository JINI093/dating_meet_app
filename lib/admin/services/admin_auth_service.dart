import 'package:dio/dio.dart';
import '../models/admin_user.dart';
import '../../config/api_config.dart';

/// 관리자 인증 서비스
class AdminAuthService {
  final Dio _dio = Dio();
  
  AdminAuthService() {
    _dio.options = BaseOptions(
      baseUrl: '${ApiConfig.baseUrl}/admin',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  /// 로그인
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'user': AdminUser.fromJson(data['user']),
          'token': data['token'] as String,
        };
      }
      
      return null;
    } catch (e) {
      throw Exception('로그인 실패: $e');
    }
  }

  /// 토큰 검증
  Future<AdminUser?> verifyToken(String token) async {
    try {
      final response = await _dio.get(
        '/auth/verify',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return AdminUser.fromJson(response.data['user']);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 토큰 갱신
  Future<String?> refreshToken(String token) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data['token'] as String;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 로그아웃
  Future<void> logout(String token) async {
    try {
      await _dio.post(
        '/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      // 로그아웃 실패해도 로컬에서는 처리
    }
  }
}