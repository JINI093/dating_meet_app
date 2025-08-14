import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';

import 'sms_provider_interface.dart';
import '../../utils/logger.dart';
import '../../models/auth_result.dart' as app_auth_result;

/// AWS SNS를 통한 SMS 제공업체
class AWSSNSProvider implements SMSProvider {
  static final AWSSNSProvider _instance = AWSSNSProvider._internal();
  factory AWSSNSProvider() => _instance;
  AWSSNSProvider._internal();

  late Dio _dio;
  bool _isInitialized = false;

  @override
  String get providerName => 'AWS SNS';

  @override
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      _dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ));

      _isInitialized = true;
      Logger.log('✅ AWS SNS Provider 초기화 완료', name: 'AWSSNSProvider');
    } catch (e) {
      Logger.error('❌ AWS SNS Provider 초기화 실패: $e', name: 'AWSSNSProvider');
      throw Exception('AWS SNS Provider 초기화 실패: $e');
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      if (!_isInitialized) await initialize();
      
      // Amplify 설정 확인
      if (!Amplify.isConfigured) return false;

      // 인증 세션 확인
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      Logger.error('AWS SNS 서비스 상태 확인 실패: $e', name: 'AWSSNSProvider');
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
      
      Logger.log('AWS SNS SMS 전송 시작: $phoneNumber', name: 'AWSSNSProvider');

      // 방법 1: AWS API Gateway + Lambda 사용
      final lambdaResult = await _sendViaLambda(phoneNumber, message);
      if (lambdaResult.success) {
        return lambdaResult;
      }

      // 방법 2: Amplify API 사용 (백업)
      final amplifyResult = await _sendViaAmplifyAPI(phoneNumber, message);
      if (amplifyResult.success) {
        return amplifyResult;
      }

      // 방법 3: 직접 AWS SNS API 호출 (최종 백업)
      return await _sendViaDirectAPI(phoneNumber, message);

    } catch (e) {
      Logger.error('❌ AWS SNS SMS 전송 실패: $e', name: 'AWSSNSProvider');
      return app_auth_result.AuthResult.failure(
        error: 'SMS 전송에 실패했습니다: ${e.toString()}',
      );
    }
  }

  /// AWS Lambda를 통한 SMS 전송
  Future<app_auth_result.AuthResult> _sendViaLambda(String phoneNumber, String message) async {
    try {
      final apiGatewayUrl = dotenv.env['AWS_API_GATEWAY_URL'];
      if (apiGatewayUrl == null || apiGatewayUrl.isEmpty) {
        throw Exception('AWS_API_GATEWAY_URL이 설정되지 않았습니다.');
      }

      // JWT 토큰 가져오기
      String? authToken;
      try {
        final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
        if (session.isSignedIn) {
          authToken = session.userPoolTokensResult.value.idToken.raw;
        }
      } catch (e) {
        Logger.error('JWT 토큰 가져오기 실패: $e', name: 'AWSSNSProvider');
      }

      final response = await _dio.post(
        '$apiGatewayUrl/sms/send',
        data: {
          'phoneNumber': phoneNumber,
          'message': message,
          'provider': 'sns',
        },
        options: Options(
          headers: {
            if (authToken != null) 'Authorization': 'Bearer $authToken',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        Logger.log('✅ Lambda를 통한 SMS 전송 성공', name: 'AWSSNSProvider');
        return app_auth_result.AuthResult.success(
          metadata: {
            'messageId': response.data['messageId'],
            'provider': 'aws_lambda',
          },
        );
      } else {
        throw Exception(response.data['error'] ?? 'Lambda SMS 전송 실패');
      }
    } catch (e) {
      Logger.error('Lambda SMS 전송 실패: $e', name: 'AWSSNSProvider');
      return app_auth_result.AuthResult.failure(error: 'Lambda SMS 전송 실패: $e');
    }
  }

  /// Amplify API를 통한 SMS 전송
  Future<app_auth_result.AuthResult> _sendViaAmplifyAPI(String phoneNumber, String message) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
          mutation SendSMS(\$phoneNumber: String!, \$message: String!) {
            sendSMS(phoneNumber: \$phoneNumber, message: \$message) {
              success
              messageId
              error
            }
          }
        ''',
        variables: {
          'phoneNumber': phoneNumber,
          'message': message,
        },
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.errors.isNotEmpty) {
        throw Exception('GraphQL 오류: ${response.errors}');
      }

      if (response.data != null) {
        final data = jsonDecode(response.data!);
        final result = data['sendSMS'];
        
        if (result['success'] == true) {
          Logger.log('✅ Amplify API SMS 전송 성공: ${result['messageId']}', name: 'AWSSNSProvider');
          return app_auth_result.AuthResult.success(
            metadata: {
              'messageId': result['messageId'],
              'provider': 'amplify_graphql',
            },
          );
        } else {
          throw Exception(result['error'] ?? 'Amplify API SMS 전송 실패');
        }
      }

      throw Exception('Amplify API 응답이 없습니다.');
    } catch (e) {
      Logger.error('Amplify API SMS 전송 실패: $e', name: 'AWSSNSProvider');
      return app_auth_result.AuthResult.failure(error: 'Amplify API SMS 전송 실패: $e');
    }
  }

  /// 직접 AWS SNS API 호출
  Future<app_auth_result.AuthResult> _sendViaDirectAPI(String phoneNumber, String message) async {
    try {
      final accessKeyId = dotenv.env['AWS_ACCESS_KEY_ID'];
      final secretAccessKey = dotenv.env['AWS_SECRET_ACCESS_KEY'];
      final region = dotenv.env['AWS_REGION'] ?? 'ap-northeast-2';
      
      if (accessKeyId == null || secretAccessKey == null) {
        Logger.error('AWS 인증 정보가 설정되지 않았습니다.', name: 'AWSSNSProvider');
        return app_auth_result.AuthResult.failure(
          error: 'AWS 인증 정보가 설정되지 않았습니다. AWS_ACCESS_KEY_ID와 AWS_SECRET_ACCESS_KEY를 .env 파일에 설정해주세요.',
        );
      }
      
      Logger.log('🚀 직접 AWS SNS API 호출 시작: $phoneNumber', name: 'AWSSNSProvider');
      
      // AWS SNS API 호출을 위한 서명 생성
      final timestamp = DateTime.now().toUtc();
      final dateStamp = timestamp.toIso8601String().substring(0, 10).replaceAll('-', '');
      final amzDate = '${timestamp.toIso8601String().replaceAll(RegExp(r'[:\-]'), '').replaceAll(RegExp(r'\.\d{3}'), '')}Z';
      
      // 요청 매개변수
      final params = <String, String>{
        'Action': 'Publish',
        'PhoneNumber': phoneNumber,
        'Message': message,
        'Version': '2010-03-31',
      };
      
      // 정렬된 쿼리 스트링 생성
      final sortedKeys = params.keys.toList()..sort();
      final queryString = sortedKeys
          .map((key) => '$key=${Uri.encodeQueryComponent(params[key]!)}')
          .join('&');
      
      // Canonical 요청 생성
      final canonicalHeaders = 'host:sns.$region.amazonaws.com\nx-amz-date:$amzDate\n';
      final signedHeaders = 'host;x-amz-date';
      final payloadHash = _sha256Hash(queryString);
      
      final canonicalRequest = [
        'POST',
        '/',
        '',
        canonicalHeaders,
        signedHeaders,
        payloadHash,
      ].join('\n');
      
      // String to Sign 생성
      final credentialScope = '$dateStamp/$region/sns/aws4_request';
      final stringToSign = [
        'AWS4-HMAC-SHA256',
        amzDate,
        credentialScope,
        _sha256Hash(canonicalRequest),
      ].join('\n');
      
      Logger.log('🔐 AWS 서명 생성 중...', name: 'AWSSNSProvider');
      Logger.log('날짜: $dateStamp, 시간: $amzDate', name: 'AWSSNSProvider');
      Logger.log('쿼리: $queryString', name: 'AWSSNSProvider');
      
      // 서명 키 생성
      final signingKey = _getSignatureKey(secretAccessKey, dateStamp, region, 'sns');
      final signature = _hmacSha256(signingKey, stringToSign);
      
      // Authorization 헤더
      final authorization = 'AWS4-HMAC-SHA256 '
          'Credential=$accessKeyId/$credentialScope, '
          'SignedHeaders=$signedHeaders, '
          'Signature=${_bytesToHex(signature)}';
      
      Logger.log('🚀 AWS SNS API 호출: sns.$region.amazonaws.com', name: 'AWSSNSProvider');
      
      // HTTP 요청
      final response = await _dio.post(
        'https://sns.$region.amazonaws.com/',
        data: queryString,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
            'Host': 'sns.$region.amazonaws.com',
            'X-Amz-Date': amzDate,
            'Authorization': authorization,
          },
        ),
      );
      
      if (response.statusCode == 200) {
        // XML 응답 파싱 (간단한 방법)
        final xmlResponse = response.data.toString();
        Logger.log('📨 AWS SNS 응답: $xmlResponse', name: 'AWSSNSProvider');
        
        if (xmlResponse.contains('<MessageId>')) {
          final messageIdMatch = RegExp(r'<MessageId>([^<]+)</MessageId>').firstMatch(xmlResponse);
          final messageId = messageIdMatch?.group(1) ?? 'unknown';
          
          Logger.log('✅ 직접 AWS SNS API 호출 성공: MessageId=$messageId', name: 'AWSSNSProvider');
          return app_auth_result.AuthResult.success(
            metadata: {
              'messageId': messageId,
              'provider': 'aws_sns_direct',
              'phoneNumber': phoneNumber,
            },
          );
        }
      }
      
      Logger.error('AWS SNS API 호출 실패: ${response.statusCode}', name: 'AWSSNSProvider');
      Logger.error('응답 데이터: ${response.data}', name: 'AWSSNSProvider');
      Logger.error('요청 헤더: ${response.requestOptions.headers}', name: 'AWSSNSProvider');
      
      // AWS 오류 응답 파싱
      final errorResponse = response.data.toString();
      if (errorResponse.contains('<Code>')) {
        final codeMatch = RegExp(r'<Code>([^<]+)</Code>').firstMatch(errorResponse);
        final messageMatch = RegExp(r'<Message>([^<]+)</Message>').firstMatch(errorResponse);
        final errorCode = codeMatch?.group(1) ?? 'UnknownError';
        final errorMessage = messageMatch?.group(1) ?? 'Unknown error occurred';
        
        Logger.error('❌ AWS SNS 오류코드: $errorCode', name: 'AWSSNSProvider');
        Logger.error('❌ AWS SNS 오류메시지: $errorMessage', name: 'AWSSNSProvider');
        
        return app_auth_result.AuthResult.failure(
          error: 'AWS SNS 오류 [$errorCode]: $errorMessage',
        );
      }
      
      return app_auth_result.AuthResult.failure(
        error: 'AWS SNS API 호출 실패: HTTP ${response.statusCode}',
      );
      
    } catch (e) {
      Logger.error('직접 AWS SNS API 호출 실패: $e', name: 'AWSSNSProvider');
      return app_auth_result.AuthResult.failure(error: '직접 AWS SNS API 호출 실패: $e');
    }
  }
  
  /// SHA256 해시
  String _sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// HMAC-SHA256
  List<int> _hmacSha256(List<int> key, String message) {
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(utf8.encode(message));
    return digest.bytes;
  }
  
  /// AWS 서명 키 생성
  List<int> _getSignatureKey(String key, String dateStamp, String regionName, String serviceName) {
    final kDate = _hmacSha256(utf8.encode('AWS4$key'), dateStamp);
    final kRegion = _hmacSha256(kDate, regionName);
    final kService = _hmacSha256(kRegion, serviceName);
    final kSigning = _hmacSha256(kService, 'aws4_request');
    return kSigning;
  }
  
  /// 바이트를 16진수 문자열로 변환
  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}