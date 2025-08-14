import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../config/api_config.dart';

/// 관리자 회원 관리 서비스
class AdminUsersService {
  final Dio _dio = Dio();

  AdminUsersService() {
    _dio.options = BaseOptions(
      baseUrl: '${ApiConfig.baseUrl}/admin',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  /// 회원 목록 조회
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int pageSize = 20,
    String searchQuery = '',
    Map<String, dynamic> filters = const {},
    String? sortField,
    bool sortAscending = true,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'pageSize': pageSize,
        if (searchQuery.isNotEmpty) 'search': searchQuery,
        if (sortField != null) 'sortField': sortField,
        'sortOrder': sortAscending ? 'asc' : 'desc',
        ...filters,
      };

      final response = await _dio.get('/users', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'users': (data['users'] as List)
              .map((json) => UserModel.fromJson(json))
              .toList(),
          'totalCount': data['totalCount'] as int,
        };
      }

      throw Exception('회원 목록을 불러올 수 없습니다');
    } catch (e) {
      throw Exception('회원 목록 조회 실패: $e');
    }
  }

  /// 회원 상세 정보 조회
  Future<UserModel> getUser(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }

      throw Exception('회원 정보를 불러올 수 없습니다');
    } catch (e) {
      throw Exception('회원 상세 조회 실패: $e');
    }
  }

  /// 회원 상태 변경
  Future<void> updateUserStatus(String userId, UserStatus status) async {
    try {
      final response = await _dio.put('/users/$userId/status', data: {
        'status': status.name,
      });

      if (response.statusCode != 200) {
        throw Exception('회원 상태를 변경할 수 없습니다');
      }
    } catch (e) {
      throw Exception('회원 상태 변경 실패: $e');
    }
  }

  /// VIP 상태 변경
  Future<void> updateVipStatus(String userId, bool isVip) async {
    try {
      final response = await _dio.put('/users/$userId/vip', data: {
        'isVip': isVip,
      });

      if (response.statusCode != 200) {
        throw Exception('VIP 상태를 변경할 수 없습니다');
      }
    } catch (e) {
      throw Exception('VIP 상태 변경 실패: $e');
    }
  }

  /// 일괄 작업
  Future<void> bulkAction(String action, List<String> userIds) async {
    try {
      final response = await _dio.post('/users/bulk', data: {
        'action': action,
        'userIds': userIds,
      });

      if (response.statusCode != 200) {
        throw Exception('일괄 작업을 수행할 수 없습니다');
      }
    } catch (e) {
      throw Exception('일괄 작업 실패: $e');
    }
  }

  /// 회원 정보 수정
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/users/$userId', data: data);

      if (response.statusCode != 200) {
        throw Exception('회원 정보를 수정할 수 없습니다');
      }
    } catch (e) {
      throw Exception('회원 정보 수정 실패: $e');
    }
  }

  /// 엑셀 다운로드용 데이터 조회
  Future<List<UserModel>> getUsersForExcel({
    String searchQuery = '',
    Map<String, dynamic> filters = const {},
    String? sortField,
    bool sortAscending = true,
  }) async {
    try {
      final queryParams = {
        'export': true,
        if (searchQuery.isNotEmpty) 'search': searchQuery,
        if (sortField != null) 'sortField': sortField,
        'sortOrder': sortAscending ? 'asc' : 'desc',
        ...filters,
      };

      final response = await _dio.get('/users/export', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['users'] as List)
            .map((json) => UserModel.fromJson(json))
            .toList();
      }

      throw Exception('엑셀 데이터를 불러올 수 없습니다');
    } catch (e) {
      throw Exception('엑셀 데이터 조회 실패: $e');
    }
  }
}