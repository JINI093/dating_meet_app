import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'sms_provider_interface.dart';
import '../../utils/logger.dart';
import '../../models/auth_result.dart' as app_auth_result;

/// Twilio SMS 제공업체
class TwilioProvider implements SMSProvider {
  static final TwilioProvider _instance = TwilioProvider._internal();
  factory TwilioProvider() => _instance;
  TwilioProvider._internal();

  late Dio _dio;
  bool _isInitialized = false;
  String? _accountSid;
  String? _authToken;
  String? _fromNumber;

  @override
  String get providerName => 'Twilio';

  @override
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      _accountSid = dotenv.env['TWILIO_ACCOUNT_SID'];
      _authToken = dotenv.env['TWILIO_AUTH_TOKEN'];
      _fromNumber = dotenv.env['TWILIO_FROM_NUMBER'];

      if (_accountSid == null || _authToken == null || _fromNumber == null) {
        throw Exception('Twilio 설정이 완료되지 않았습니다. .env 파일을 확인해주세요.');
      }

      // Basic Auth 인증 헤더 생성
      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));

      _dio = Dio(BaseOptions(
        baseUrl: 'https://api.twilio.com/2010-04-01',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ));

      _isInitialized = true;
      Logger.log('✅ Twilio Provider 초기화 완료', name: 'TwilioProvider');
    } catch (e) {
      Logger.error('❌ Twilio Provider 초기화 실패: $e', name: 'TwilioProvider');
      throw Exception('Twilio Provider 초기화 실패: $e');
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      if (!_isInitialized) await initialize();
      
      // 설정값 확인
      return _accountSid != null && _authToken != null && _fromNumber != null;
    } catch (e) {
      Logger.error('Twilio 서비스 상태 확인 실패: $e', name: 'TwilioProvider');
      return false;
    }
  }

  @override
  Future<app_auth_result.AuthResult> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      if (!_isInitialized) await initialize();
      
      Logger.log('Twilio SMS 전송 시작: $phoneNumber', name: 'TwilioProvider');

      // Twilio API 호출
      final response = await _dio.post(
        '/Accounts/$_accountSid/Messages.json',
        data: {
          'From': _fromNumber,
          'To': phoneNumber,
          'Body': message,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        final messageSid = data['sid'];
        final status = data['status'];

        Logger.log('✅ Twilio SMS 전송 성공: $messageSid (상태: $status)', name: 'TwilioProvider');
        
        return app_auth_result.AuthResult.success(
          additionalData: {
            'messageId': messageSid,
            'status': status,
            'provider': 'twilio',
            'to': data['to'],
            'from': data['from'],
          },
        );
      } else {
        throw Exception('Twilio API 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Twilio SMS 전송 실패: $e', name: 'TwilioProvider');
      
      // DioException 처리
      if (e is DioException) {
        final errorMessage = _parseTwilioError(e);
        return app_auth_result.AuthResult.failure(error: errorMessage);
      }
      
      return app_auth_result.AuthResult.failure(
        error: 'Twilio SMS 전송 실패: ${e.toString()}',
      );
    }
  }

  /// Twilio 오류 메시지 파싱
  String _parseTwilioError(DioException e) {
    try {
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map && errorData.containsKey('message')) {
          return 'Twilio 오류: ${errorData['message']}';
        }
      }
      return 'Twilio SMS 전송 실패: ${e.message}';
    } catch (_) {
      return 'Twilio SMS 전송 중 알 수 없는 오류가 발생했습니다.';
    }
  }

  /// 메시지 상태 확인
  Future<Map<String, dynamic>?> getMessageStatus(String messageSid) async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _dio.get('/Accounts/$_accountSid/Messages/$messageSid.json');

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      Logger.error('Twilio 메시지 상태 확인 실패: $e', name: 'TwilioProvider');
      return null;
    }
  }

  /// 계정 정보 확인
  Future<Map<String, dynamic>?> getAccountInfo() async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _dio.get('/Accounts/$_accountSid.json');

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      Logger.error('Twilio 계정 정보 확인 실패: $e', name: 'TwilioProvider');
      return null;
    }
  }
}