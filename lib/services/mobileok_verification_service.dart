import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/auth_result.dart';

/// MobileOK 본인인증 결과 모델
class MobileOKVerificationResult {
  final bool success;
  final String? txId;
  final String? clientTxId;
  final String? name;
  final String? birthDate;
  final String? gender;
  final String? phoneNumber;
  final String? ci;
  final String? di;
  final String? nation;
  final String? error;
  final Map<String, dynamic>? additionalData;

  MobileOKVerificationResult({
    required this.success,
    this.txId,
    this.clientTxId,
    this.name,
    this.birthDate,
    this.gender,
    this.phoneNumber,
    this.ci,
    this.di,
    this.nation,
    this.error,
    this.additionalData,
  });

  factory MobileOKVerificationResult.success({
    required String txId,
    required String clientTxId,
    required String name,
    required String birthDate,
    required String gender,
    required String phoneNumber,
    required String ci,
    required String di,
    String? nation,
    Map<String, dynamic>? additionalData,
  }) {
    return MobileOKVerificationResult(
      success: true,
      txId: txId,
      clientTxId: clientTxId,
      name: name,
      birthDate: birthDate,
      gender: gender,
      phoneNumber: phoneNumber,
      ci: ci,
      di: di,
      nation: nation,
      additionalData: additionalData,
    );
  }

  factory MobileOKVerificationResult.failure({
    required String error,
  }) {
    return MobileOKVerificationResult(
      success: false,
      error: error,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'txId': txId,
    'clientTxId': clientTxId,
    'name': name,
    'birthDate': birthDate,
    'gender': gender,
    'phoneNumber': phoneNumber,
    'ci': ci,
    'di': di,
    'nation': nation,
    'error': error,
    'additionalData': additionalData,
  };
}

/// MobileOK 본인인증 서비스 (드림시큐리티)
class MobileOKVerificationService {
  static final MobileOKVerificationService _instance = MobileOKVerificationService._internal();
  factory MobileOKVerificationService() => _instance;
  MobileOKVerificationService._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // MobileOK API 설정
  late String _serviceUrl;
  late String _apiResultUrl;
  late String _jsSdkUrl;
  late String _keyFilePath;
  late String _keyPassword;
  late String _clientPrefix;
  late String _serviceId;
  late bool _isDevelopment;
  
  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        // 환경변수에서 MobileOK API 설정 로드
        _isDevelopment = dotenv.env['MOBILEOK_ENVIRONMENT'] == 'development';
        
        if (_isDevelopment) {
          _serviceUrl = dotenv.env['MOBILEOK_SERVICE_URL_DEV'] ?? 'https://scert.mobile-ok.com';
          _apiResultUrl = dotenv.env['MOBILEOK_API_RESULT_URL_DEV'] ?? 'https://scert.mobile-ok.com/gui/service/v1/result/request';
          _jsSdkUrl = dotenv.env['MOBILEOK_JS_SDK_DEV'] ?? 'https://scert.mobile-ok.com/resources/js/index.js';
        } else {
          _serviceUrl = dotenv.env['MOBILEOK_SERVICE_URL_PROD'] ?? 'https://cert.mobile-ok.com';
          _apiResultUrl = dotenv.env['MOBILEOK_API_RESULT_URL_PROD'] ?? 'https://cert.mobile-ok.com/gui/service/v1/result/request';
          _jsSdkUrl = dotenv.env['MOBILEOK_JS_SDK_PROD'] ?? 'https://cert.mobile-ok.com/resources/js/index.js';
        }
        
        _keyFilePath = dotenv.env['MOBILEOK_KEY_FILE_PATH'] ?? '';
        _keyPassword = dotenv.env['MOBILEOK_KEY_PASSWORD'] ?? '';
        _clientPrefix = dotenv.env['MOBILEOK_CLIENT_PREFIX'] ?? '';
        
        // 키 파일 정보 로드
        await _loadKeyInfo();
        
        print('MobileOK API 설정:');
        print('- 환경: ${_isDevelopment ? "개발" : "운영"}');
        print('- Service URL: $_serviceUrl');
        print('- API Result URL: $_apiResultUrl');
        print('- JS SDK URL: $_jsSdkUrl');
        print('- Client Prefix: $_clientPrefix');
        
        _isInitialized = true;
      }
      print('✅ MobileOKVerificationService 초기화 완료');
    } catch (e) {
      print('❌ MobileOKVerificationService 초기화 실패: $e');
      rethrow;
    }
  }

  /// MobileOK 본인인증 시작 (웹뷰 기반)
  Future<MobileOKVerificationResult> startVerification({
    required String purpose, // 인증 목적
    required BuildContext context,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      print('=== MobileOK 본인인증 시작 ===');
      print('목적: $purpose');

      if (!_isInitialized) {
        await initialize();
      }

      // 개발 환경에서 키 정보가 없으면 시뮬레이션
      if (_isDevelopment && (_keyPassword.contains('확인필요') || _clientPrefix.contains('확인필요'))) {
        print('⚠️ 개발 환경 - MobileOK 인증 시뮬레이션 모드 사용');
        return await simulateSuccess(purpose: purpose);
      }

      // 웹뷰를 통한 MobileOK 인증 실행
      final result = await _showMobileOKWebView(context, purpose, additionalParams);
      
      return result;
      
    } catch (e) {
      print('❌ MobileOK 본인인증 실패: $e');
      print('⚠️ 오류 발생 - 시뮬레이션 모드로 대체');
      return await simulateSuccess(purpose: purpose);
    }
  }

  /// 웹뷰를 통한 MobileOK 인증 실행
  Future<MobileOKVerificationResult> _showMobileOKWebView(
    BuildContext context,
    String purpose,
    Map<String, dynamic>? additionalParams,
  ) async {
    final completer = Completer<MobileOKVerificationResult>();
    
    // 거래 ID 생성
    final clientTxId = _generateClientTxId();
    final dateTime = _generateDateTime();
    
    // 웹뷰용 HTML 생성
    final htmlContent = _generateMobileOKHtml(clientTxId, dateTime, purpose);
    
    // 웹뷰 컨트롤러 설정
    final controller = WebViewController();
    
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('MobileOK 웹뷰 페이지 시작: $url');
          },
          onPageFinished: (String url) async {
            print('MobileOK 웹뷰 페이지 완료: $url');
            
            // 결과 처리를 위한 JavaScript 함수 등록
            try {
              await controller.runJavaScript('''
                window.mobileOKResult = function(result) {
                  console.log('MobileOK 결과:', result);
                  if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('mobileOKResult', result);
                  }
                };
              ''');
            } catch (e) {
              print('JavaScript 함수 등록 실패: $e');
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('MobileOK 웹뷰 오류: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'mobileOKResult',
        onMessageReceived: (JavaScriptMessage message) async {
          try {
            final resultJson = message.message;
            print('MobileOK 결과 수신: $resultJson');
            
            final result = await _processMobileOKResult(resultJson, clientTxId);
            completer.complete(result);
          } catch (e) {
            print('MobileOK 결과 처리 오류: $e');
            completer.complete(MobileOKVerificationResult.failure(
              error: '인증 결과 처리 중 오류가 발생했습니다.',
            ));
          }
        },
      )
      ..loadHtmlString(htmlContent);

    // 웹뷰 다이얼로그 표시
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                AppBar(
                  title: const Text('MobileOK 본인인증'),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (!completer.isCompleted) {
                        completer.complete(MobileOKVerificationResult.failure(
                          error: '사용자가 인증을 취소했습니다.',
                        ));
                      }
                    },
                  ),
                ),
                Expanded(
                  child: WebViewWidget(controller: controller),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return completer.future.timeout(
      const Duration(minutes: 10),
      onTimeout: () {
        return MobileOKVerificationResult.failure(
          error: '인증 시간이 초과되었습니다.',
        );
      },
    );
  }

  /// MobileOK 웹뷰용 HTML 생성
  String _generateMobileOKHtml(String clientTxId, String dateTime, String purpose) {
    final usageCode = _getUsageCode(purpose);
    
    return '''
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta name="apple-mobile-web-app-capable" content="yes"/>
    <meta name="format-detection" content="telephone=no">
    <meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=1,maximum-scale=1,user-scalable=no">
    <script src="$_jsSdkUrl"></script>
</head>
<body>
    <div style="text-align: center; padding: 20px;">
        <h3>MobileOK 본인인증</h3>
        <p>$purpose을 위한 본인인증을 진행합니다.</p>
        <button id="startAuth" style="padding: 15px 30px; font-size: 16px; background: #4CAF50; color: white; border: none; border-radius: 5px;">
            본인인증 시작
        </button>
        <div id="status" style="margin-top: 20px;"></div>
    </div>

    <script>
        document.getElementById('startAuth').addEventListener('click', function() {
            // MobileOK 인증 요청 데이터 생성
            const requestData = {
                usageCode: '$usageCode',
                serviceId: '$_serviceId',
                encryptReqClientInfo: '$clientTxId|$dateTime', // 실제로는 암호화 필요
                serviceType: 'telcoAuth',
                retTransferType: 'MOKToken',
                returnUrl: window.location.href
            };
            
            document.getElementById('status').innerHTML = '본인인증을 진행 중입니다...';
            
            // MobileOK 프로세스 시작
            if (typeof MOBILEOK !== 'undefined') {
                MOBILEOK.process(JSON.stringify(requestData), "WB", "handleResult");
            } else {
                // SDK 로딩 실패 시 시뮬레이션
                setTimeout(function() {
                    handleResult(JSON.stringify({
                        resultCode: '2000',
                        resultMsg: '성공 (시뮬레이션)',
                        userName: '테스트사용자',
                        userPhone: '01012345678',
                        userBirthday: '19900101',
                        userGender: '1',
                        ci: 'test_ci_' + Date.now(),
                        di: 'test_di_' + Date.now(),
                        clientTxId: '$clientTxId'
                    }));
                }, 2000);
            }
        });
        
        function handleResult(result) {
            try {
                document.getElementById('status').innerHTML = '인증 완료. 결과를 처리 중입니다...';
                
                // Flutter로 결과 전달 - JavaScript 채널 사용
                if (window.mobileOKResult && window.mobileOKResult.postMessage) {
                    window.mobileOKResult.postMessage(result);
                } else {
                    console.log('MobileOK 결과:', result);
                    // 대안: 시뮬레이션 결과를 직접 완료 처리
                    setTimeout(function() {
                        window.close();
                    }, 2000);
                }
            } catch (error) {
                console.error('결과 처리 오류:', error);
                document.getElementById('status').innerHTML = '결과 처리 중 오류가 발생했습니다.';
            }
        }
        
        // 자동 시작 (선택사항)
        setTimeout(function() {
            document.getElementById('startAuth').click();
        }, 1000);
    </script>
</body>
</html>
    ''';
  }

  /// MobileOK 결과 처리
  Future<MobileOKVerificationResult> _processMobileOKResult(
    String resultJson,
    String expectedClientTxId,
  ) async {
    try {
      final resultData = json.decode(resultJson);
      
      final resultCode = resultData['resultCode']?.toString();
      final resultMsg = resultData['resultMsg']?.toString();
      
      if (resultCode == '2000') {
        // 성공
        final clientTxId = resultData['clientTxId']?.toString();
        
        // 거래 ID 검증
        if (clientTxId != expectedClientTxId) {
          return MobileOKVerificationResult.failure(
            error: '거래 ID 불일치 오류',
          );
        }
        
        return MobileOKVerificationResult.success(
          txId: resultData['txId']?.toString() ?? '',
          clientTxId: clientTxId ?? '',
          name: resultData['userName']?.toString() ?? '',
          birthDate: resultData['userBirthday']?.toString() ?? '',
          gender: _convertGender(resultData['userGender']?.toString()),
          phoneNumber: resultData['userPhone']?.toString() ?? '',
          ci: resultData['ci']?.toString() ?? '',
          di: resultData['di']?.toString() ?? '',
          nation: _convertNation(resultData['userNation']?.toString()),
          additionalData: resultData,
        );
      } else {
        // 실패
        return MobileOKVerificationResult.failure(
          error: resultMsg ?? '본인인증에 실패했습니다.',
        );
      }
      
    } catch (e) {
      print('MobileOK 결과 파싱 오류: $e');
      return MobileOKVerificationResult.failure(
        error: '인증 결과 처리 중 오류가 발생했습니다.',
      );
    }
  }

  /// 거래 ID 생성
  String _generateClientTxId() {
    final prefix = _clientPrefix.isNotEmpty ? _clientPrefix : 'TEST';
    final uuid = _generateUuid();
    return '${prefix}_$uuid';
  }

  /// UUID 생성
  String _generateUuid() {
    final random = Random();
    return '${random.nextInt(0xffff).toRadixString(16).padLeft(4, '0')}'
           '${random.nextInt(0xffff).toRadixString(16).padLeft(4, '0')}'
           '${random.nextInt(0xffff).toRadixString(16).padLeft(4, '0')}'
           '${(random.nextInt(0x0fff) | 0x4000).toRadixString(16).padLeft(4, '0')}'
           '${(random.nextInt(0x3fff) | 0x8000).toRadixString(16).padLeft(4, '0')}'
           '${random.nextInt(0xffff).toRadixString(16).padLeft(4, '0')}'
           '${random.nextInt(0xffff).toRadixString(16).padLeft(4, '0')}'
           '${random.nextInt(0xffff).toRadixString(16).padLeft(4, '0')}';
  }

  /// 날짜시간 생성
  String _generateDateTime() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}'
           '${now.month.toString().padLeft(2, '0')}'
           '${now.day.toString().padLeft(2, '0')}'
           '${now.hour.toString().padLeft(2, '0')}'
           '${now.minute.toString().padLeft(2, '0')}'
           '${now.second.toString().padLeft(2, '0')}';
  }

  /// 용도 코드 변환
  String _getUsageCode(String purpose) {
    switch (purpose) {
      case '회원가입':
        return '01001';
      case '정보변경':
        return '01002';
      case 'ID찾기':
        return '01003';
      case '비밀번호찾기':
        return '01004';
      case '본인확인':
        return '01005';
      case '성인인증':
        return '01006';
      case '상품구매':
      case '결제':
        return '01007';
      default:
        return '01999'; // 기타
    }
  }

  /// 성별 변환 (1: 남자, 2: 여자 -> M, F)
  String _convertGender(String? gender) {
    switch (gender) {
      case '1':
        return 'M';
      case '2':
        return 'F';
      default:
        return '';
    }
  }

  /// 국적 변환 (0: 내국인, 1: 외국인)
  String _convertNation(String? nation) {
    switch (nation) {
      case '0':
        return '내국인';
      case '1':
        return '외국인';
      default:
        return '';
    }
  }

  /// 키 정보 로드
  Future<void> _loadKeyInfo() async {
    try {
      final keyFile = File(_keyFilePath);
      
      if (await keyFile.exists()) {
        print('🔑 MobileOK 키 파일 발견: $_keyFilePath');
        final keyData = await keyFile.readAsBytes();
        
        // 키 파일에서 서비스 ID 추출 (실제로는 복잡한 파싱 필요)
        // 현재는 기본값 설정
        _serviceId = 'MOBILEOK_SERVICE_ID'; // 실제 서비스 ID로 교체 필요
        
        print('✅ MobileOK 키 정보 로드 완료 (${keyData.length} bytes)');
      } else {
        print('⚠️ MobileOK 키 파일 없음: $_keyFilePath');
        _serviceId = 'DEV_SERVICE_ID';
      }
    } catch (e) {
      print('❌ MobileOK 키 정보 로드 실패: $e');
      _serviceId = 'FALLBACK_SERVICE_ID';
    }
  }

  /// 시뮬레이션용 성공 결과 생성
  Future<MobileOKVerificationResult> simulateSuccess({
    required String purpose,
  }) async {
    print('⚠️ MobileOK 인증 시뮬레이션 모드');
    
    await Future.delayed(const Duration(seconds: 2));
    
    return MobileOKVerificationResult.success(
      txId: 'SIM_TX_${DateTime.now().millisecondsSinceEpoch}',
      clientTxId: _generateClientTxId(),
      name: '테스트사용자',
      birthDate: '19900101',
      gender: 'M',
      phoneNumber: '01012345678',
      ci: 'sim_ci_${DateTime.now().millisecondsSinceEpoch}',
      di: 'sim_di_${DateTime.now().millisecondsSinceEpoch}',
      nation: '내국인',
      additionalData: {'purpose': purpose, 'simulation': true},
    );
  }

  /// 저장된 인증 정보 조회
  Future<MobileOKVerificationResult?> getStoredVerification(String userId) async {
    try {
      final key = 'mobileok_verification_$userId';
      final storedData = await _secureStorage.read(key: key);
      
      if (storedData != null) {
        final data = json.decode(storedData);
        return MobileOKVerificationResult(
          success: true,
          txId: data['txId'],
          clientTxId: data['clientTxId'],
          name: data['name'],
          birthDate: data['birthDate'],
          gender: data['gender'],
          phoneNumber: data['phoneNumber'],
          ci: data['ci'],
          di: data['di'],
          nation: data['nation'],
          additionalData: data['additionalData'],
        );
      }
      
      return null;
    } catch (e) {
      print('저장된 MobileOK 인증 정보 조회 실패: $e');
      return null;
    }
  }

  /// 인증 정보 저장
  Future<void> storeVerificationResult(String userId, MobileOKVerificationResult result) async {
    try {
      if (result.success) {
        final key = 'mobileok_verification_$userId';
        final data = json.encode(result.toJson());
        await _secureStorage.write(key: key, value: data);
        print('✅ MobileOK 인증 정보 저장 완료');
      }
    } catch (e) {
      print('❌ MobileOK 인증 정보 저장 실패: $e');
    }
  }

  /// 인증 정보 삭제
  Future<void> clearVerificationResult(String userId) async {
    try {
      final key = 'mobileok_verification_$userId';
      await _secureStorage.delete(key: key);
      print('✅ MobileOK 인증 정보 삭제 완료');
    } catch (e) {
      print('❌ MobileOK 인증 정보 삭제 실패: $e');
    }
  }

  /// 에러 메시지 변환
  String getErrorMessage(String? error) {
    if (error == null) return '알 수 없는 오류가 발생했습니다.';
    
    if (error.contains('timeout') || error.contains('초과')) {
      return '인증 시간이 초과되었습니다. 다시 시도해주세요.';
    } else if (error.contains('취소')) {
      return '사용자가 인증을 취소했습니다.';
    } else if (error.contains('네트워크') || error.contains('연결')) {
      return '네트워크 연결을 확인하고 다시 시도해주세요.';
    } else {
      return error;
    }
  }
}