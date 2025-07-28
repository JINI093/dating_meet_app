import 'package:dio/dio.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../config/aws_config.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AWSConfig.apiGatewayUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  ApiService() {
    print('[API][DEBUG] ApiService initialized with baseUrl: ${_dio.options.baseUrl}');
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // JWT 토큰 자동 헤더 추가
        try {
          final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
          if (session.isSignedIn && session.userPoolTokensResult.value != null) {
            final idToken = session.userPoolTokensResult.value!.idToken.raw;
            if (idToken.isNotEmpty) {
              // Bearer 토큰 형식으로 변경
              options.headers['Authorization'] = 'Bearer $idToken';
              print('[API][AUTH] 토큰 추가됨: Bearer ${idToken.substring(0, 20)}...');
            } else {
              print('[API][AUTH] ID 토큰이 비어있습니다');
            }
          } else {
            print('[API][AUTH] 인증되지 않았거나 토큰이 없습니다');
          }
        } catch (e) {
          print('[API][AUTH] 토큰 가져오기 실패: $e');
        }
        // 로깅
        print('[API][REQUEST] ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 로깅
        print('[API][RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        print('[API][ERROR] ${e.message}');
        // 토큰 만료 시 재로그인/재시도 로직 등 구현 가능
        return handler.next(e);
      },
    ));
  }

  // GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _retry(() => _dio.get(path, queryParameters: queryParameters));
  }

  // POST
  Future<Response> post(String path, {dynamic data}) async {
    return await _retry(() => _dio.post(path, data: data));
  }

  // PUT
  Future<Response> put(String path, {dynamic data}) async {
    return await _retry(() => _dio.put(path, data: data));
  }

  // DELETE
  Future<Response> delete(String path, {dynamic data}) async {
    return await _retry(() => _dio.delete(path, data: data));
  }

  // 재시도 로직 (최대 2회)
  Future<Response> _retry(Future<Response> Function() requestFn) async {
    int retryCount = 0;
    while (true) {
      try {
        return await requestFn();
      } catch (e) {
        if (retryCount++ < 2) {
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }
        rethrow;
      }
    }
  }
} 