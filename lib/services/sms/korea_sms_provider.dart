import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';

import 'sms_provider_interface.dart';
import '../../utils/logger.dart';
import '../../models/auth_result.dart' as app_auth_result;

/// 한국 통신사 SMS 제공업체 (KT, SKT, LG U+)
class KoreaSMSProvider implements SMSProvider {
  static final KoreaSMSProvider _instance = KoreaSMSProvider._internal();
  factory KoreaSMSProvider() => _instance;
  KoreaSMSProvider._internal();

  late Dio _dio;
  bool _isInitialized = false;
  String _selectedCarrier = 'kt'; // 기본값: KT

  @override
  String get providerName => 'Korea SMS (${_selectedCarrier.toUpperCase()})';

  /// 통신사 선택
  void setCarrier(String carrier) {
    if (['kt', 'skt', 'lgu'].contains(carrier.toLowerCase())) {
      _selectedCarrier = carrier.toLowerCase();
      _isInitialized = false; // 재초기화 필요
    }
  }

  @override
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      _dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      ));

      _isInitialized = true;
      Logger.log('✅ Korea SMS Provider ($_selectedCarrier) 초기화 완료', name: 'KoreaSMSProvider');
    } catch (e) {
      Logger.error('❌ Korea SMS Provider 초기화 실패: $e', name: 'KoreaSMSProvider');
      throw Exception('Korea SMS Provider 초기화 실패: $e');
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      if (!_isInitialized) await initialize();

      // 통신사별 설정 확인
      switch (_selectedCarrier) {
        case 'kt':
          return _checkKTConfig();
        case 'skt':
          return _checkSKTConfig();
        case 'lgu':
          return _checkLGUConfig();
        default:
          return false;
      }
    } catch (e) {
      Logger.error('Korea SMS 서비스 상태 확인 실패: $e', name: 'KoreaSMSProvider');
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
      
      Logger.log('Korea SMS 전송 시작 ($_selectedCarrier): $phoneNumber', name: 'KoreaSMSProvider');

      switch (_selectedCarrier) {
        case 'kt':
          return await _sendViaKT(phoneNumber, message);
        case 'skt':
          return await _sendViaSKT(phoneNumber, message);
        case 'lgu':
          return await _sendViaLGU(phoneNumber, message);
        default:
          throw Exception('지원하지 않는 통신사: $_selectedCarrier');
      }
    } catch (e) {
      Logger.error('❌ Korea SMS 전송 실패: $e', name: 'KoreaSMSProvider');
      return app_auth_result.AuthResult.failure(
        error: 'Korea SMS 전송 실패: ${e.toString()}',
      );
    }
  }

  /// KT SMS API 호출
  Future<app_auth_result.AuthResult> _sendViaKT(String phoneNumber, String message) async {
    try {
      final apiUrl = dotenv.env['KT_SMS_API_URL'] ?? 'https://api.kt.com/sms';
      final apiKey = dotenv.env['KT_API_KEY'];
      final secretKey = dotenv.env['KT_SECRET_KEY'];
      final senderNumber = dotenv.env['KT_SENDER_NUMBER'];

      if (apiKey == null || secretKey == null || senderNumber == null) {
        throw Exception('KT SMS 설정이 완료되지 않았습니다.');
      }

      // KT API 인증 헤더 생성
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final signature = _generateKTSignature(apiKey, secretKey, timestamp);

      final response = await _dio.post(
        '$apiUrl/v1/send',
        data: {
          'sender': senderNumber,
          'receiver': phoneNumber,
          'message': message,
          'type': 'SMS',
        },
        options: Options(
          headers: {
            'X-API-KEY': apiKey,
            'X-API-SIGNATURE': signature,
            'X-API-TIMESTAMP': timestamp,
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.log('✅ KT SMS 전송 성공: ${response.data['messageId']}', name: 'KoreaSMSProvider');
        return app_auth_result.AuthResult.success(
          additionalData: {
            'messageId': response.data['messageId'],
            'provider': 'kt',
            'carrier': 'KT',
          },
        );
      } else {
        throw Exception(response.data['message'] ?? 'KT SMS 전송 실패');
      }
    } catch (e) {
      Logger.error('KT SMS 전송 실패: $e', name: 'KoreaSMSProvider');
      return app_auth_result.AuthResult.failure(error: 'KT SMS 전송 실패: $e');
    }
  }

  /// SKT SMS API 호출
  Future<app_auth_result.AuthResult> _sendViaSKT(String phoneNumber, String message) async {
    try {
      final apiUrl = dotenv.env['SKT_SMS_API_URL'] ?? 'https://api.sktelecom.com/sms';
      final apiKey = dotenv.env['SKT_API_KEY'];
      final secretKey = dotenv.env['SKT_SECRET_KEY'];
      final senderNumber = dotenv.env['SKT_SENDER_NUMBER'];

      if (apiKey == null || secretKey == null || senderNumber == null) {
        throw Exception('SKT SMS 설정이 완료되지 않았습니다.');
      }

      // SKT API 인증 토큰 생성
      final accessToken = await _getSKTAccessToken(apiKey, secretKey);

      final response = await _dio.post(
        '$apiUrl/v1/messages',
        data: {
          'from': senderNumber,
          'to': phoneNumber,
          'text': message,
          'type': 'SMS',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 201) {
        Logger.log('✅ SKT SMS 전송 성공: ${response.data['messageId']}', name: 'KoreaSMSProvider');
        return app_auth_result.AuthResult.success(
          additionalData: {
            'messageId': response.data['messageId'],
            'provider': 'skt',
            'carrier': 'SKT',
          },
        );
      } else {
        throw Exception(response.data['message'] ?? 'SKT SMS 전송 실패');
      }
    } catch (e) {
      Logger.error('SKT SMS 전송 실패: $e', name: 'KoreaSMSProvider');
      return app_auth_result.AuthResult.failure(error: 'SKT SMS 전송 실패: $e');
    }
  }

  /// LG U+ SMS API 호출
  Future<app_auth_result.AuthResult> _sendViaLGU(String phoneNumber, String message) async {
    try {
      final apiUrl = dotenv.env['LGU_SMS_API_URL'] ?? 'https://api.lguplus.co.kr/sms';
      final apiKey = dotenv.env['LGU_API_KEY'];
      final secretKey = dotenv.env['LGU_SECRET_KEY'];
      final senderNumber = dotenv.env['LGU_SENDER_NUMBER'];

      if (apiKey == null || secretKey == null || senderNumber == null) {
        throw Exception('LG U+ SMS 설정이 완료되지 않았습니다.');
      }

      // LG U+ API 인증 헤더 생성
      final timestamp = DateTime.now().toIso8601String();
      final nonce = DateTime.now().millisecondsSinceEpoch.toString();
      final signature = _generateLGUSignature(apiKey, secretKey, timestamp, nonce);

      final response = await _dio.post(
        '$apiUrl/v2/sms/send',
        data: {
          'sender': senderNumber,
          'recipients': [phoneNumber],
          'content': message,
          'messageType': 'SMS',
        },
        options: Options(
          headers: {
            'X-LGU-API-KEY': apiKey,
            'X-LGU-TIMESTAMP': timestamp,
            'X-LGU-NONCE': nonce,
            'X-LGU-SIGNATURE': signature,
          },
        ),
      );

      if (response.statusCode == 200 && response.data['resultCode'] == '0000') {
        Logger.log('✅ LG U+ SMS 전송 성공: ${response.data['messageKey']}', name: 'KoreaSMSProvider');
        return app_auth_result.AuthResult.success(
          additionalData: {
            'messageId': response.data['messageKey'],
            'provider': 'lgu',
            'carrier': 'LG U+',
          },
        );
      } else {
        throw Exception(response.data['resultMessage'] ?? 'LG U+ SMS 전송 실패');
      }
    } catch (e) {
      Logger.error('LG U+ SMS 전송 실패: $e', name: 'KoreaSMSProvider');
      return app_auth_result.AuthResult.failure(error: 'LG U+ SMS 전송 실패: $e');
    }
  }

  /// 설정 확인 메소드들
  bool _checkKTConfig() {
    return dotenv.env['KT_API_KEY'] != null &&
           dotenv.env['KT_SECRET_KEY'] != null &&
           dotenv.env['KT_SENDER_NUMBER'] != null;
  }

  bool _checkSKTConfig() {
    return dotenv.env['SKT_API_KEY'] != null &&
           dotenv.env['SKT_SECRET_KEY'] != null &&
           dotenv.env['SKT_SENDER_NUMBER'] != null;
  }

  bool _checkLGUConfig() {
    return dotenv.env['LGU_API_KEY'] != null &&
           dotenv.env['LGU_SECRET_KEY'] != null &&
           dotenv.env['LGU_SENDER_NUMBER'] != null;
  }

  /// KT API 서명 생성
  String _generateKTSignature(String apiKey, String secretKey, String timestamp) {
    final data = '$apiKey$timestamp';
    final key = utf8.encode(secretKey);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64Encode(digest.bytes);
  }

  /// SKT Access Token 획득
  Future<String> _getSKTAccessToken(String apiKey, String secretKey) async {
    try {
      final credentials = base64Encode(utf8.encode('$apiKey:$secretKey'));
      
      final response = await _dio.post(
        'https://api.sktelecom.com/oauth/token',
        data: {'grant_type': 'client_credentials'},
        options: Options(
          headers: {
            'Authorization': 'Basic $credentials',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['access_token'];
      } else {
        throw Exception('SKT Access Token 획득 실패');
      }
    } catch (e) {
      throw Exception('SKT Access Token 획득 실패: $e');
    }
  }

  /// LG U+ API 서명 생성
  String _generateLGUSignature(String apiKey, String secretKey, String timestamp, String nonce) {
    final data = '$apiKey$timestamp$nonce';
    final key = utf8.encode(secretKey);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64Encode(digest.bytes);
  }
}