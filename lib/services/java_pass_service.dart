import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Java PASS 본인인증 결과 모델
class JavaPassVerificationResult {
  final bool success;
  final String? txId;
  final String? name;
  final String? birthDate;
  final String? gender;
  final String? phoneNumber;
  final String? ci;
  final String? di;
  final String? error;
  final Map<String, dynamic>? additionalData;

  JavaPassVerificationResult({
    required this.success,
    this.txId,
    this.name,
    this.birthDate,
    this.gender,
    this.phoneNumber,
    this.ci,
    this.di,
    this.error,
    this.additionalData,
  });

  factory JavaPassVerificationResult.success({
    required String txId,
    required String name,
    required String birthDate,
    required String gender,
    required String phoneNumber,
    required String ci,
    required String di,
    Map<String, dynamic>? additionalData,
  }) {
    return JavaPassVerificationResult(
      success: true,
      txId: txId,
      name: name,
      birthDate: birthDate,
      gender: gender,
      phoneNumber: phoneNumber,
      ci: ci,
      di: di,
      additionalData: additionalData,
    );
  }

  factory JavaPassVerificationResult.failure({
    required String error,
  }) {
    return JavaPassVerificationResult(
      success: false,
      error: error,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'txId': txId,
    'name': name,
    'birthDate': birthDate,
    'gender': gender,
    'phoneNumber': phoneNumber,
    'ci': ci,
    'di': di,
    'error': error,
    'additionalData': additionalData,
  };
}

/// Java PASS 본인인증 서비스
class JavaPassService {
  static const String _storageKey = 'java_pass_verification';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Java API 서버 URL (로컬 파일 사용)
  String _apiBaseUrl = 'file:///Users/sunwoo/Desktop/development/dating_meet_app/pass';
  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 환경변수에서 API URL 로드
      final apiUrl = dotenv.env['JAVA_PASS_API_URL'];
      if (apiUrl != null && apiUrl.isNotEmpty) {
        _apiBaseUrl = apiUrl;
      }

      print('✅ Java PASS 서비스 초기화 완료');
      print('API URL: $_apiBaseUrl');
      
      _isInitialized = true;
    } catch (e) {
      print('❌ Java PASS 서비스 초기화 실패: $e');
      throw Exception('Java PASS 서비스 초기화 실패: $e');
    }
  }

  /// Java PASS 본인인증 시작
  Future<JavaPassVerificationResult> startVerification({
    required BuildContext context,
    required String purpose,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      print('=== Java PASS 본인인증 시작 ===');
      print('목적: $purpose');

      if (!_isInitialized) {
        await initialize();
      }

      // 1단계: Java API에서 인증 요청 생성
      final requestResult = await _createAuthRequest(purpose);
      if (!requestResult['success']) {
        return JavaPassVerificationResult.failure(
          error: requestResult['error'] ?? '인증 요청 생성 실패',
        );
      }

      final requestData = requestResult['requestData'];
      final clientTxId = requestResult['clientTxId'];

      // 2단계: 웹뷰로 PASS 인증 페이지 열기
      final authResult = await _openPassWebView(
        context: context,
        requestData: requestData,
        clientTxId: clientTxId,
      );

      return authResult;
    } catch (e) {
      print('❌ Java PASS 본인인증 실패: $e');
      return JavaPassVerificationResult.failure(error: e.toString());
    }
  }

  /// Java API에서 인증 요청 생성
  Future<Map<String, dynamic>> _createAuthRequest(String purpose) async {
    try {
      // GitHub Pages는 정적 호스팅이므로 시뮬레이션 모드로 처리
      await Future.delayed(const Duration(seconds: 1));
      
      // 시뮬레이션 데이터 반환
      return {
        'success': true,
        'requestData': json.encode({
          'usageCode': '01001',
          'serviceId': 'test_service_id',
          'encryptReqClientInfo': 'simulated_encrypted_data',
          'serviceType': 'telcoAuth',
          'retTransferType': 'MOKToken',
          'returnUrl': 'https://jini093.github.io/sagilrae-temp/result.html',
        }),
        'clientTxId': 'DATING_APP_${DateTime.now().millisecondsSinceEpoch}',
      };
    } catch (e) {
      print('❌ Java API 요청 실패: $e');
      return {
        'success': false,
        'error': 'API 요청 중 오류: $e',
      };
    }
  }

  /// PASS 웹뷰 열기
  Future<JavaPassVerificationResult> _openPassWebView({
    required BuildContext context,
    required String requestData,
    required String clientTxId,
  }) async {
    final completer = Completer<JavaPassVerificationResult>();

          // PASS 인증 페이지 URL 생성 (로컬 파일)
      final passUrl = 'file:///Users/sunwoo/Desktop/development/dating_meet_app/pass/local_pass_server.html';
    
    // 웹뷰 화면 표시
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JavaPassWebViewScreen(
          passUrl: passUrl,
          requestData: requestData,
          clientTxId: clientTxId,
          onResult: (result) {
            Navigator.of(context).pop();
            completer.complete(result);
          },
          onError: (error) {
            Navigator.of(context).pop();
            completer.complete(JavaPassVerificationResult.failure(error: error));
          },
        ),
      ),
    );

    return await completer.future;
  }

  /// Java API에서 인증 결과 처리
  Future<JavaPassVerificationResult> _processAuthResult(String data) async {
    try {
      // GitHub Pages는 정적 호스팅이므로 시뮬레이션 모드로 처리
      await Future.delayed(const Duration(seconds: 1));
      
      // 시뮬레이션 성공 결과 반환
      return JavaPassVerificationResult.success(
        txId: 'simulated_tx_${DateTime.now().millisecondsSinceEpoch}',
        name: '홍길동',
        birthDate: '19900101',
        gender: 'M',
        phoneNumber: '01012345678',
        ci: 'simulated_ci_${DateTime.now().millisecondsSinceEpoch}',
        di: 'simulated_di_${DateTime.now().millisecondsSinceEpoch}',
        additionalData: {
          'resultCode': '0000',
          'resultMsg': '성공',
          'method': 'github_pages_simulation',
          'data': data,
        },
      );
    } catch (e) {
      print('❌ Java API 결과 처리 실패: $e');
      return JavaPassVerificationResult.failure(error: '결과 처리 중 오류: $e');
    }
  }

  /// 인증 결과 저장
  Future<void> storeVerificationResult(String userId, JavaPassVerificationResult result) async {
    try {
      final data = {
        'userId': userId,
        'result': result.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _storage.write(
        key: '$_storageKey:$userId',
        value: json.encode(data),
      );
      
      print('✅ Java PASS 인증 결과 저장 완료');
    } catch (e) {
      print('❌ Java PASS 인증 결과 저장 실패: $e');
    }
  }

  /// 저장된 인증 결과 조회
  Future<JavaPassVerificationResult?> getStoredVerificationResult(String userId) async {
    try {
      final data = await _storage.read(key: '$_storageKey:$userId');
      if (data != null) {
        final jsonData = json.decode(data);
        final resultData = jsonData['result'];
        
        if (resultData['success']) {
          return JavaPassVerificationResult.success(
            txId: resultData['txId'],
            name: resultData['name'],
            birthDate: resultData['birthDate'],
            gender: resultData['gender'],
            phoneNumber: resultData['phoneNumber'],
            ci: resultData['ci'],
            di: resultData['di'],
            additionalData: resultData['additionalData'],
          );
        }
      }
      return null;
    } catch (e) {
      print('❌ 저장된 Java PASS 인증 결과 조회 실패: $e');
      return null;
    }
  }

  /// 에러 메시지 변환
  String getErrorMessage(String? error) {
    if (error == null) return '알 수 없는 오류가 발생했습니다.';
    
    if (error.contains('네트워크')) return '네트워크 연결을 확인해주세요.';
    if (error.contains('타임아웃')) return '요청 시간이 초과되었습니다.';
    if (error.contains('인증')) return '본인인증에 실패했습니다.';
    
    return error;
  }
}

/// Java PASS 웹뷰 화면
class JavaPassWebViewScreen extends StatefulWidget {
  final String passUrl;
  final String requestData;
  final String clientTxId;
  final Function(JavaPassVerificationResult) onResult;
  final Function(String) onError;

  const JavaPassWebViewScreen({
    super.key,
    required this.passUrl,
    required this.requestData,
    required this.clientTxId,
    required this.onResult,
    required this.onError,
  });

  @override
  State<JavaPassWebViewScreen> createState() => _JavaPassWebViewScreenState();
}

class _JavaPassWebViewScreenState extends State<JavaPassWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // PASS 인증 완료 후 리다이렉트 URL 처리
            if (request.url.contains('result') || request.url.contains('callback')) {
              _handlePassResult(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.passUrl));
  }

  void _handleJavaScriptMessage(String message) {
    try {
      final data = json.decode(message);
      if (data['success'] == true) {
        if (data['status'] == 'ready') {
          // 페이지 로드 완료
          print('✅ PASS 인증 페이지 로드 완료');
        } else {
          // 인증 결과 처리
          _processAuthResultFromJavaScript(data);
        }
      } else {
        widget.onError(data['error'] ?? '인증에 실패했습니다.');
      }
    } catch (e) {
      print('❌ JavaScript 메시지 처리 실패: $e');
      widget.onError('메시지 처리 중 오류가 발생했습니다.');
    }
  }

  void _processAuthResultFromJavaScript(Map<String, dynamic> data) {
    final result = JavaPassVerificationResult.success(
      txId: data['txId'] ?? data['clientTxId'],
      name: data['userName'],
      birthDate: data['userBirthday'],
      gender: data['userGender'] == '1' ? 'M' : 'F',
      phoneNumber: data['userPhone'],
      ci: data['ci'],
      di: data['di'],
      additionalData: data,
    );
    widget.onResult(result);
  }

  void _handlePassResult(String url) async {
    try {
      // GitHub Pages PASS 인증 페이지에서 결과 처리
      if (url.contains('result') || url.contains('callback') || url.contains('success')) {
        // 시뮬레이션 성공으로 처리
        final passService = JavaPassService();
        final result = await passService._processAuthResult('github_pages_success');
        widget.onResult(result);
      } else if (url.contains('error') || url.contains('cancel')) {
        widget.onError('사용자가 인증을 취소했습니다.');
      } else {
        // 기본적으로 성공으로 처리 (GitHub Pages 시뮬레이션)
        final passService = JavaPassService();
        final result = await passService._processAuthResult('github_pages_default');
        widget.onResult(result);
      }
    } catch (e) {
      widget.onError('인증 결과 처리 중 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PASS 본인인증'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onError('사용자가 인증을 취소했습니다.');
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
