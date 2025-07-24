import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_protector/screen_protector.dart';
import '../widgets/dialogs/capture_prevention_dialog.dart';

class ScreenCaptureService {
  static final ScreenCaptureService _instance = ScreenCaptureService._internal();
  factory ScreenCaptureService() => _instance;
  ScreenCaptureService._internal();

  StreamSubscription<bool>? _screenshotSubscription;
  StreamSubscription<bool>? _screenRecordingSubscription;
  bool _isInitialized = false;
  
  // iOS 네이티브 통신용 메소드 채널
  static const MethodChannel _methodChannel = MethodChannel('screen_capture_channel');

  /// 스크린 캡처 방지 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 스크린 캡처 방지 활성화
      await ScreenProtector.protectDataLeakageOn();
      
      // 스크린샷 방지 활성화
      await ScreenProtector.preventScreenshotOn();
      
      _isInitialized = true;
      print('ScreenCaptureService: 초기화 완료');
    } catch (e) {
      print('ScreenCaptureService 초기화 실패: $e');
    }
  }

  /// 스크린 캡처 감지 리스너 시작
  void startListening(BuildContext context) {
    if (!_isInitialized) {
      return;
    }

    // iOS 네이티브 스크린샷 감지 메소드 채널 설정
    _methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onScreenshotDetected':
          _handleScreenCapture(context, '스크린샷');
          break;
        case 'onScreenRecordingDetected':
          _handleScreenCapture(context, '스크린 녹화');
          break;
      }
    });

    print('ScreenCaptureService: 리스너 시작');
  }

  /// 스크린 캡처 감지 리스너 정지
  void stopListening() {
    _screenshotSubscription?.cancel();
    _screenRecordingSubscription?.cancel();
    _screenshotSubscription = null;
    _screenRecordingSubscription = null;
    print('ScreenCaptureService: 리스너 정지');
  }

  /// 스크린 캡처 방지 해제
  Future<void> dispose() async {
    stopListening();
    
    try {
      await ScreenProtector.protectDataLeakageOff();
      await ScreenProtector.preventScreenshotOff();
      _isInitialized = false;
      print('ScreenCaptureService: 해제 완료');
    } catch (e) {
      print('ScreenCaptureService 해제 실패: $e');
    }
  }

  /// 스크린 캡처 감지 시 처리
  void _handleScreenCapture(BuildContext context, String captureType) {
    print('ScreenCaptureService: $captureType 감지됨');
    
    // 경고 다이얼로그 표시
    if (context.mounted) {
      CapturePreventionDialog.show(context);
    }
    
    // 추가 보안 조치 (필요시)
    _logSecurityEvent(captureType);
  }

  /// 보안 이벤트 로깅
  void _logSecurityEvent(String eventType) {
    final timestamp = DateTime.now().toIso8601String();
    print('보안 이벤트: $eventType - $timestamp');
    
    // TODO: 서버로 보안 이벤트 전송
    // SecurityEventService.logEvent(SecurityEventType.screenCapture, {
    //   'type': eventType,
    //   'timestamp': timestamp,
    //   'userId': CurrentUser.id,
    // });
  }

  /// 현재 보호 상태 확인
  bool get isProtected => _isInitialized;

  /// 특정 화면에서 일시적으로 보호 해제 (예: 이미지 저장 기능)
  Future<void> temporaryDisable() async {
    if (!_isInitialized) return;
    
    try {
      await ScreenProtector.preventScreenshotOff();
      print('ScreenCaptureService: 일시적 보호 해제');
    } catch (e) {
      print('ScreenCaptureService 일시적 해제 실패: $e');
    }
  }

  /// 일시적 해제 후 다시 활성화
  Future<void> reEnable() async {
    if (!_isInitialized) return;
    
    try {
      await ScreenProtector.preventScreenshotOn();
      print('ScreenCaptureService: 보호 재활성화');
    } catch (e) {
      print('ScreenCaptureService 재활성화 실패: $e');
    }
  }

  /// 신고 전용 스크린샷 캡처
  Future<String?> captureForReport() async {
    if (!_isInitialized) return null;
    
    try {
      // 1. 일시적으로 스크린 보호 해제
      await temporaryDisable();
      
      // 2. 짧은 지연을 두어 보호 해제가 적용되도록 함
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 3. 스크린샷 캡처를 위한 네이티브 메소드 호출
      final String? screenshotPath = await _methodChannel.invokeMethod('captureScreenshot');
      
      // 4. 즉시 스크린 보호 재활성화
      await reEnable();
      
      if (screenshotPath != null) {
        print('ScreenCaptureService: 신고용 스크린샷 캡처 완료 - $screenshotPath');
        _logSecurityEvent('Report Screenshot Captured');
        return screenshotPath;
      } else {
        print('ScreenCaptureService: 신고용 스크린샷 캡처 실패');
        return null;
      }
    } catch (e) {
      print('ScreenCaptureService 신고 캡처 실패: $e');
      // 오류 발생 시에도 반드시 보호 재활성화
      await reEnable();
      return null;
    }
  }
}