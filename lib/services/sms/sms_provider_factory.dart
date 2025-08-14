import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'sms_provider_interface.dart';
import 'aws_sns_provider.dart';
import 'twilio_provider.dart';
import 'korea_sms_provider.dart';
import '../../utils/logger.dart';
import '../../models/auth_result.dart' as app_auth_result;

/// SMS 제공업체 타입
enum SMSProviderType {
  awsSns,
  awsLambda,
  twilio,
  kt,
  skt,
  lgu,
  simulation, // 개발용 시뮬레이션
}

/// SMS 제공업체 팩토리
class SMSProviderFactory {
  static SMSProviderFactory? _instance;
  static SMSProviderFactory get instance => _instance ??= SMSProviderFactory._internal();
  SMSProviderFactory._internal();

  final Map<SMSProviderType, SMSProvider> _providers = {};
  SMSProviderType _currentProviderType = SMSProviderType.simulation;

  /// 현재 설정된 제공업체 반환
  SMSProvider get currentProvider => _providers[_currentProviderType] ?? _createProvider(_currentProviderType);

  /// 제공업체 타입 설정
  Future<void> setProviderType(SMSProviderType type) async {
    _currentProviderType = type;
    
    // 기존 제공업체가 없으면 새로 생성
    if (!_providers.containsKey(type)) {
      _providers[type] = _createProvider(type);
    }
    
    // 초기화
    await _providers[type]!.initialize();
    Logger.log('SMS 제공업체 변경: ${_providers[type]!.providerName}', name: 'SMSProviderFactory');
  }

  /// 환경 변수에서 제공업체 설정 자동 감지
  Future<void> autoDetectProvider() async {
    try {
      final configuredProvider = dotenv.env['SMS_PROVIDER']?.toLowerCase();
      
      switch (configuredProvider) {
        case 'aws_sns':
          await setProviderType(SMSProviderType.awsSns);
          break;
        case 'aws_lambda':
          await setProviderType(SMSProviderType.awsLambda);
          break;
        case 'twilio':
          await setProviderType(SMSProviderType.twilio);
          break;
        case 'kt':
          await setProviderType(SMSProviderType.kt);
          break;
        case 'skt':
          await setProviderType(SMSProviderType.skt);
          break;
        case 'lgu':
          await setProviderType(SMSProviderType.lgu);
          break;
        default:
          // 개발 모드에서는 시뮬레이션 사용
          if (dotenv.env['DEBUG_SMS'] == 'true') {
            await setProviderType(SMSProviderType.simulation);
          } else {
            // 사용 가능한 제공업체 자동 감지
            await _detectAvailableProvider();
          }
      }
    } catch (e) {
      Logger.error('SMS 제공업체 자동 감지 실패: $e', name: 'SMSProviderFactory');
      // 실패 시 시뮬레이션으로 폴백
      await setProviderType(SMSProviderType.simulation);
    }
  }

  /// 사용 가능한 제공업체 감지
  Future<void> _detectAvailableProvider() async {
    final providersToCheck = [
      SMSProviderType.awsSns,
      SMSProviderType.twilio,
      SMSProviderType.kt,
      SMSProviderType.skt,
      SMSProviderType.lgu,
    ];

    for (final type in providersToCheck) {
      try {
        final provider = _createProvider(type);
        await provider.initialize();
        
        if (await provider.isAvailable()) {
          await setProviderType(type);
          Logger.log('사용 가능한 SMS 제공업체 감지: ${provider.providerName}', name: 'SMSProviderFactory');
          return;
        }
      } catch (e) {
        Logger.error('${type.name} 제공업체 확인 실패: $e', name: 'SMSProviderFactory');
        continue;
      }
    }

    // 모든 제공업체가 사용 불가능하면 시뮬레이션 사용
    await setProviderType(SMSProviderType.simulation);
    Logger.log('⚠️ 사용 가능한 SMS 제공업체가 없어 시뮬레이션 모드로 설정됩니다.', name: 'SMSProviderFactory');
  }

  /// 제공업체 인스턴스 생성
  SMSProvider _createProvider(SMSProviderType type) {
    switch (type) {
      case SMSProviderType.awsSns:
      case SMSProviderType.awsLambda:
        return AWSSNSProvider();
      
      case SMSProviderType.twilio:
        return TwilioProvider();
      
      case SMSProviderType.kt:
        final provider = KoreaSMSProvider();
        provider.setCarrier('kt');
        return provider;
      
      case SMSProviderType.skt:
        final provider = KoreaSMSProvider();
        provider.setCarrier('skt');
        return provider;
      
      case SMSProviderType.lgu:
        final provider = KoreaSMSProvider();
        provider.setCarrier('lgu');
        return provider;
      
      case SMSProviderType.simulation:
        return SimulationSMSProvider();
    }
  }

  /// 모든 제공업체 상태 확인
  Future<Map<String, bool>> checkAllProvidersStatus() async {
    final status = <String, bool>{};
    
    for (final type in SMSProviderType.values) {
      if (type == SMSProviderType.simulation) continue;
      
      try {
        final provider = _createProvider(type);
        await provider.initialize();
        status[provider.providerName] = await provider.isAvailable();
      } catch (e) {
        status[type.name] = false;
      }
    }
    
    return status;
  }

  /// 제공업체별 테스트 메시지 전송
  Future<Map<String, bool>> testAllProviders(String testPhoneNumber) async {
    final results = <String, bool>{};
    const testMessage = '[사귈래] SMS 연결 테스트입니다.';
    
    for (final type in SMSProviderType.values) {
      if (type == SMSProviderType.simulation) continue;
      
      try {
        final provider = _createProvider(type);
        await provider.initialize();
        
        if (await provider.isAvailable()) {
          final result = await provider.sendSMS(
            phoneNumber: testPhoneNumber,
            message: testMessage,
          );
          results[provider.providerName] = result.success;
        } else {
          results[provider.providerName] = false;
        }
      } catch (e) {
        Logger.error('${type.name} 테스트 실패: $e', name: 'SMSProviderFactory');
        results[type.name] = false;
      }
    }
    
    return results;
  }
}

/// 개발용 시뮬레이션 SMS 제공업체
class SimulationSMSProvider implements SMSProvider {
  @override
  String get providerName => 'Simulation';

  @override
  Future<void> initialize() async {
    Logger.log('✅ Simulation SMS Provider 초기화 완료', name: 'SimulationSMSProvider');
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<app_auth_result.AuthResult> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    // 시뮬레이션 지연
    await Future.delayed(const Duration(seconds: 1));
    
    Logger.log('📱 [시뮬레이션] SMS 전송: $phoneNumber', name: 'SimulationSMSProvider');
    Logger.log('💬 [시뮬레이션] 메시지: $message', name: 'SimulationSMSProvider');
    
    return app_auth_result.AuthResult.success(
      additionalData: {
        'messageId': 'sim-${DateTime.now().millisecondsSinceEpoch}',
        'provider': 'simulation',
        'phoneNumber': phoneNumber,
        'message': message,
      },
    );
  }
}

