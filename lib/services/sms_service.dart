import 'dart:convert';
import 'dart:math';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

import '../utils/logger.dart';
import '../models/auth_result.dart' as AppAuthResult;
import 'sms/sms_provider_factory.dart';

/// SMS 인증 서비스 (AWS SNS 사용)
class SMSService {
  static final SMSService _instance = SMSService._internal();
  factory SMSService() => _instance;
  SMSService._internal();

  static const String _verificationCodeKey = 'sms_verification_codes';
  static const String _codeTimestampKey = 'sms_code_timestamps';
  static const Duration _codeValidityDuration = Duration(minutes: 5);

  /// SMS 인증번호 생성
  String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// 인증번호와 전화번호를 해시하여 저장 키 생성
  String _getStorageKey(String phoneNumber) {
    final bytes = utf8.encode(phoneNumber);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 실제 SMS 전송 (다중 제공업체 지원)
  Future<AppAuthResult.AuthResult> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      Logger.log('SMS 전송 시작: $phoneNumber', name: 'SMSService');

      // SMS 제공업체 팩토리 사용
      final factory = SMSProviderFactory.instance;
      await factory.autoDetectProvider();
      
      final provider = factory.currentProvider;
      Logger.log('사용 중인 SMS 제공업체: ${provider.providerName}', name: 'SMSService');
      
      // 실제 SMS 전송
      final result = await provider.sendSMS(
        phoneNumber: phoneNumber,
        message: message,
      );
      
      if (result.success) {
        Logger.log('✅ SMS 전송 완료: $phoneNumber via ${provider.providerName}', name: 'SMSService');
        return AppAuthResult.AuthResult.success(
          metadata: result.metadata,
        );
      } else {
        Logger.error('❌ SMS 전송 실패: ${result.error}', name: 'SMSService');
        return AppAuthResult.AuthResult.failure(
          error: result.error ?? 'SMS 전송에 실패했습니다.',
        );
      }
      
    } catch (e) {
      Logger.error('❌ SMS 전송 오류: $e', name: 'SMSService');
      return AppAuthResult.AuthResult.failure(error: 'SMS 전송에 실패했습니다: ${e.toString()}');
    }
  }

  /// 인증번호 SMS 전송
  Future<AppAuthResult.AuthResult> sendVerificationCode(String phoneNumber) async {
    try {
      Logger.log('인증번호 SMS 전송 요청: $phoneNumber', name: 'SMSService');

      // 인증번호 생성
      final verificationCode = _generateVerificationCode();
      final message = '[사귈래] 인증번호는 [$verificationCode]입니다. 5분 이내에 입력해주세요.';

      // 개발용: 콘솔에 인증번호 출력 (실제 SMS가 오지 않으므로)
      print('🔐 [개발용] 인증번호: $verificationCode ($phoneNumber)');
      Logger.log('🔐 [개발용] 생성된 인증번호: $verificationCode', name: 'SMSService');

      // 인증번호 로컬 저장
      await _storeVerificationCode(phoneNumber, verificationCode);

      // SMS 전송
      final result = await sendSMS(
        phoneNumber: phoneNumber,
        message: message,
      );

      if (result.success) {
        Logger.log('✅ 인증번호 SMS 전송 완료: $phoneNumber', name: 'SMSService');
        Logger.log('📱 인증번호를 콘솔에서 확인하세요: $verificationCode', name: 'SMSService');
        
        return AppAuthResult.AuthResult.success(
          metadata: {
            'phoneNumber': phoneNumber,
            'codeSent': true,
            'verificationCode': verificationCode, // 개발용으로 추가
          },
        );
      } else {
        return result;
      }
    } catch (e) {
      Logger.error('❌ 인증번호 SMS 전송 오류: $e', name: 'SMSService');
      return AppAuthResult.AuthResult.failure(error: '인증번호 전송에 실패했습니다.');
    }
  }

  /// 인증번호 검증
  Future<AppAuthResult.AuthResult> verifyCode({
    required String phoneNumber,
    required String inputCode,
  }) async {
    try {
      Logger.log('인증번호 검증: $phoneNumber, 입력코드: $inputCode', name: 'SMSService');

      final storedData = await _getStoredVerificationCode(phoneNumber);
      
      if (storedData == null) {
        Logger.error('저장된 인증번호가 없음', name: 'SMSService');
        return AppAuthResult.AuthResult.failure(error: '인증번호가 만료되었습니다. 다시 요청해주세요.');
      }

      final storedCode = storedData['code'];
      final timestamp = storedData['timestamp'];
      final sentTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

      // 유효시간 확인
      if (DateTime.now().difference(sentTime) > _codeValidityDuration) {
        Logger.error('인증번호 유효시간 만료', name: 'SMSService');
        await _removeStoredVerificationCode(phoneNumber);
        return AppAuthResult.AuthResult.failure(error: '인증번호가 만료되었습니다. 다시 요청해주세요.');
      }

      // 인증번호 확인
      if (storedCode == inputCode) {
        Logger.log('✅ 인증번호 검증 성공', name: 'SMSService');
        await _removeStoredVerificationCode(phoneNumber);
        return AppAuthResult.AuthResult.success(
          metadata: {
            'phoneNumber': phoneNumber,
            'verified': true,
          },
        );
      } else {
        Logger.error('❌ 인증번호 불일치', name: 'SMSService');
        return AppAuthResult.AuthResult.failure(error: '인증번호가 올바르지 않습니다.');
      }
    } catch (e) {
      Logger.error('❌ 인증번호 검증 오류: $e', name: 'SMSService');
      return AppAuthResult.AuthResult.failure(error: '인증번호 검증에 실패했습니다.');
    }
  }

  /// 인증번호 로컬 저장
  Future<void> _storeVerificationCode(String phoneNumber, String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(phoneNumber);
      
      final data = {
        'code': code,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString('${_verificationCodeKey}_$key', jsonEncode(data));
      Logger.log('인증번호 저장 완료: $phoneNumber', name: 'SMSService');
    } catch (e) {
      Logger.error('인증번호 저장 실패: $e', name: 'SMSService');
    }
  }

  /// 저장된 인증번호 조회
  Future<Map<String, dynamic>?> _getStoredVerificationCode(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(phoneNumber);
      final storedData = prefs.getString('${_verificationCodeKey}_$key');
      
      if (storedData != null) {
        return jsonDecode(storedData);
      }
      return null;
    } catch (e) {
      Logger.error('저장된 인증번호 조회 실패: $e', name: 'SMSService');
      return null;
    }
  }

  /// 저장된 인증번호 삭제
  Future<void> _removeStoredVerificationCode(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(phoneNumber);
      await prefs.remove('${_verificationCodeKey}_$key');
      Logger.log('저장된 인증번호 삭제 완료', name: 'SMSService');
    } catch (e) {
      Logger.error('저장된 인증번호 삭제 실패: $e', name: 'SMSService');
    }
  }

  /// 전화번호 정규화
  String normalizePhoneNumber(String phoneNumber) {
    // 숫자만 추출
    String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // 한국 번호 형식 처리
    if (digits.startsWith('010') || digits.startsWith('011') || 
        digits.startsWith('016') || digits.startsWith('017') || 
        digits.startsWith('018') || digits.startsWith('019')) {
      // 010-1234-5678 → +821012345678
      return '+82${digits.substring(1)}';
    } else if (digits.startsWith('82')) {
      // 이미 82로 시작하는 경우
      return '+$digits';
    } else {
      // 기본적으로 +82 추가
      return '+82$digits';
    }
  }

  /// 서비스 상태 확인
  Future<bool> isServiceAvailable() async {
    try {
      // Amplify 설정 확인
      if (!Amplify.isConfigured) {
        return false;
      }

      // 인증 상태 확인
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      Logger.error('SMS 서비스 상태 확인 실패: $e', name: 'SMSService');
      return false;
    }
  }
}