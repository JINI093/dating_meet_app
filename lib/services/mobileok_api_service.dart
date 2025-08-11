import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// MobileOK API 본인인증 결과 모델
class MobileOKAPIResult {
  final bool success;
  final String? mokToken;
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

  MobileOKAPIResult({
    required this.success,
    this.mokToken,
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

  factory MobileOKAPIResult.success({
    required String mokToken,
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
    return MobileOKAPIResult(
      success: true,
      mokToken: mokToken,
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

  factory MobileOKAPIResult.failure({
    required String error,
  }) {
    return MobileOKAPIResult(
      success: false,
      error: error,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'mokToken': mokToken,
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

/// MobileOK API 본인인증 서비스 (드림시큐리티)
class MobileOKAPIService {
  static final MobileOKAPIService _instance = MobileOKAPIService._internal();
  factory MobileOKAPIService() => _instance;
  MobileOKAPIService._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // MobileOK API 설정
  late String _tokenUrl;
  late String _authUrl;
  late String _resultUrl;
  late String _serviceId;
  late String _siteUrl;
  late String _clientPrefix;
  late bool _isDevelopment;
  
  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        // 환경변수에서 MobileOK API 설정 로드
        _isDevelopment = dotenv.env['MOBILEOK_ENVIRONMENT'] == 'development';
        
        if (_isDevelopment) {
          _tokenUrl = 'https://scert-dir.mobile-ok.com/agent/v1/token/get';
          _authUrl = 'https://scert-dir.mobile-ok.com/agent/v1/auth/request';
          _resultUrl = 'https://scert-dir.mobile-ok.com/agent/v1/result/get';
        } else {
          _tokenUrl = 'https://cert-dir.mobile-ok.com/agent/v1/token/get';
          _authUrl = 'https://cert-dir.mobile-ok.com/agent/v1/auth/request';
          _resultUrl = 'https://cert-dir.mobile-ok.com/agent/v1/result/get';
        }
        
        _serviceId = dotenv.env['MOBILEOK_SERVICE_ID'] ?? '';
        _siteUrl = dotenv.env['MOBILEOK_SITE_URL'] ?? 'www.mobile-ok.com';
        _clientPrefix = dotenv.env['MOBILEOK_CLIENT_PREFIX'] ?? '';
        
        print('MobileOK API 설정:');
        print('- 환경: ${_isDevelopment ? "개발" : "운영"}');
        print('- Token URL: $_tokenUrl');
        print('- Service ID: $_serviceId');
        print('- Client Prefix: $_clientPrefix');
        
        _isInitialized = true;
      }
      print('✅ MobileOKAPIService 초기화 완료');
    } catch (e) {
      print('❌ MobileOKAPIService 초기화 실패: $e');
      rethrow;
    }
  }

  /// MobileOK API 본인인증 시작
  Future<MobileOKAPIResult> startVerification({
    required String purpose,
    required String userName,
    required String phoneNumber,
    required String birthDate,
    String? gender,
    String provider = 'SKT', // SKT, KT, LGU
    String authType = 'PASS', // PASS, SMS, ARS
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      print('=== MobileOK API 본인인증 시작 ===');
      print('목적: $purpose');
      print('이름: $userName');
      print('전화번호: $phoneNumber');
      print('생년월일: $birthDate');

      if (!_isInitialized) {
        await initialize();
      }

      // 1. 거래 ID 생성
      final clientTxId = _generateClientTxId();
      final dateTime = _generateDateTime();
      
      // 2. 토큰 요청
      final tokenResult = await _requestToken(clientTxId, dateTime);
      if (!tokenResult['success']) {
        return MobileOKAPIResult.failure(error: tokenResult['error']);
      }
      
      final mokToken = tokenResult['mokToken'];
      final publicKey = tokenResult['publicKey'];
      
      // 3. 인증 요청
      final authResult = await _requestAuthentication(
        mokToken: mokToken,
        publicKey: publicKey,
        clientTxId: clientTxId,
        userName: userName,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        gender: gender,
        provider: provider,
        authType: authType,
        purpose: purpose,
      );
      
      if (!authResult['success']) {
        return MobileOKAPIResult.failure(error: authResult['error']);
      }
      
      // 4. PASS 앱 실행 대기 (사용자가 PASS 앱에서 인증 진행)
      print('PASS 앱에서 인증을 진행해주세요...');
      
      // 5. 결과 확인 (폴링 방식)
      final verificationResult = await _pollForResult(
        mokToken: mokToken,
        clientTxId: clientTxId,
      );
      
      return verificationResult;
      
    } catch (e) {
      print('❌ MobileOK API 본인인증 실패: $e');
      return MobileOKAPIResult.failure(
        error: 'MobileOK API 본인인증 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 토큰 요청
  Future<Map<String, dynamic>> _requestToken(String clientTxId, String dateTime) async {
      // 클라이언트 정보 생성
      final reqClientInfo = '$clientTxId|$dateTime';
      
      // PHP 서버를 통한 RSA 암호화
      final encryptResult = await _encryptWithPHP(reqClientInfo);
      if (!encryptResult['success']) {
        return {
          'success': false,
          'error': encryptResult['error'],
        };
      }
      
      final encryptReqClientInfo = encryptResult['encrypted'];
      _serviceId = encryptResult['serviceId'] ?? _serviceId;
      
      final requestBody = {
        'serviceId': _serviceId,
        'siteUrl': _siteUrl,
        'encryptReqClientInfo': encryptReqClientInfo,
      };
      
      print('토큰 요청: $_tokenUrl');
      print('요청 데이터: ${json.encode(requestBody)}');
      
      // HTTP 클라이언트 설정 (타임아웃 연장)
      final client = http.Client();
      
      try {
        final response = await client.post(
          Uri.parse(_tokenUrl),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'User-Agent': 'MobileOK-Flutter/1.0',
          },
          body: json.encode(requestBody),
        ).timeout(const Duration(seconds: 30)); // 30초 타임아웃
        
        client.close();
        
        if (response.statusCode == 200) {
          final result = json.decode(utf8.decode(response.bodyBytes));
          
          if (result['resultCode'] == '2000') {
            return {
              'success': true,
              'mokToken': result['encryptMOKToken'],
              'publicKey': result['publicKey'],
            };
          } else {
            return {
              'success': false,
              'error': result['resultMsg'] ?? '토큰 발급 실패',
            };
          }
        } else {
          return {
            'success': false,
            'error': 'HTTP 오류: ${response.statusCode}',
          };
        }
      } catch (e) {
        client.close();
        print('토큰 요청 오류: $e');
        
        // 개발 환경에서 연결 실패 시 시뮬레이션 모드로 전환
        if (_isDevelopment && (e.toString().contains('timeout') || e.toString().contains('TimeoutException'))) {
          print('⚠️ 개발 서버 연결 실패 - 시뮬레이션 모드로 전환');
          return {
            'success': true,
            'mokToken': 'SIMULATION_TOKEN_${DateTime.now().millisecondsSinceEpoch}',
            'publicKey': 'SIMULATION_PUBLIC_KEY',
          };
        }
        
        return {
          'success': false,
          'error': '토큰 요청 중 오류가 발생했습니다: $e',
        };
      }
  }

  /// PHP 서버를 통한 RSA 암호화
  Future<Map<String, dynamic>> _encryptWithPHP(String plainText) async {
    try {
      // PHP 서버 URL 설정
      String phpServerUrl;
      if (Platform.isAndroid) {
        phpServerUrl = 'http://10.0.2.2:8000';
      } else {
        phpServerUrl = 'http://192.168.45.175:8000';
      }
      
      final response = await http.post(
        Uri.parse('$phpServerUrl/mok_api_encrypt.php'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode({
          'action': 'encrypt',
          'plainText': plainText,
        }),
      );
      
      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        return result;
      } else {
        return {
          'success': false,
          'error': 'PHP 서버 오류: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('PHP 암호화 오류: $e');
      return {
        'success': false,
        'error': 'PHP 암호화 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 인증 요청
  Future<Map<String, dynamic>> _requestAuthentication({
    required String mokToken,
    required String publicKey,
    required String clientTxId,
    required String userName,
    required String phoneNumber,
    required String birthDate,
    String? gender,
    required String provider,
    required String authType,
    required String purpose,
  }) async {
    try {
      // 용도 코드 변환
      final usageCode = _getUsageCode(purpose);
      
      // 성별 코드 변환 (M/F -> 1/2)
      final genderCode = gender == 'M' ? '1' : gender == 'F' ? '2' : '';
      
      // 전화번호 형식 정리 (하이픈 제거)
      final cleanPhoneNumber = phoneNumber.replaceAll('-', '');
      
      final requestBody = {
        'mokToken': mokToken,
        'serviceType': 'telcoAuth', // 휴대폰 본인인증
        'reqAuthType': authType, // PASS, SMS, ARS
        'usageCode': usageCode,
        'userName': userName,
        'userPhone': cleanPhoneNumber,
        'userBirthday': birthDate,
        'userGender': genderCode,
        'providerId': provider,
        'clientTxId': clientTxId,
      };
      
      print('인증 요청: $_authUrl');
      
      final response = await http.post(
        Uri.parse(_authUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode(requestBody),
      );
      
      print('인증 요청 응답 상태: ${response.statusCode}');
      print('인증 요청 응답: ${response.body}');
      
      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        
        if (result['resultCode'] == '2000') {
          return {
            'success': true,
            'message': '인증 요청이 전송되었습니다.',
          };
        } else {
          return {
            'success': false,
            'error': result['resultMsg'] ?? '인증 요청 실패',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP 오류: ${response.statusCode}',
        };
      }
      
    } catch (e) {
      print('인증 요청 오류: $e');
      
      // 시뮬레이션 토큰인 경우 성공으로 처리
      if (mokToken.startsWith('SIMULATION_TOKEN_')) {
        print('⚠️ 시뮬레이션 모드 - 인증 요청 성공으로 처리');
        return {
          'success': true,
          'message': '인증 요청이 전송되었습니다. (시뮬레이션)',
        };
      }
      
      return {
        'success': false,
        'error': '인증 요청 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 결과 확인 (폴링)
  Future<MobileOKAPIResult> _pollForResult({
    required String mokToken,
    required String clientTxId,
    int maxAttempts = 42, // 7분 = 420초 / 10초 = 42회
    Duration interval = const Duration(seconds: 10),
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      print('인증 결과 확인 중... ($i/$maxAttempts)');
      
      try {
        final result = await _checkResult(mokToken, clientTxId);
        
        if (result.success || (result.error != null && !result.error!.contains('진행중'))) {
          return result;
        }
        
        // 대기
        await Future.delayed(interval);
        
      } catch (e) {
        print('결과 확인 오류: $e');
        // 오류 발생 시에도 계속 시도
      }
    }
    
    return MobileOKAPIResult.failure(
      error: '인증 시간이 초과되었습니다. (7분)',
    );
  }

  /// 결과 확인
  Future<MobileOKAPIResult> _checkResult(String mokToken, String clientTxId) async {
    try {
      // 시뮬레이션 토큰인 경우 시뮬레이션 결과 반환
      if (mokToken.startsWith('SIMULATION_TOKEN_')) {
        return _generateSimulationResult(mokToken, clientTxId);
      }
      
      final requestBody = {
        'mokToken': mokToken,
        'clientTxId': clientTxId,
      };
      
      final response = await http.post(
        Uri.parse(_resultUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 30));
      
      print('결과 확인 응답 상태: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = json.decode(utf8.decode(response.bodyBytes));
        
        if (result['resultCode'] == '2000') {
          // 인증 성공
          return MobileOKAPIResult.success(
            mokToken: mokToken,
            txId: result['txId'] ?? 'TX_${DateTime.now().millisecondsSinceEpoch}',
            clientTxId: clientTxId,
            name: result['userName'] ?? '',
            birthDate: result['userBirthday'] ?? '',
            gender: _convertGender(result['userGender']?.toString()),
            phoneNumber: result['userPhone'] ?? '',
            ci: result['ci'] ?? '',
            di: result['di'] ?? '',
            nation: _convertNation(result['userNation']?.toString()),
            additionalData: result,
          );
        } else if (result['resultCode'] == '1000') {
          // 인증 진행중
          return MobileOKAPIResult.failure(
            error: '인증 진행중입니다...',
          );
        } else {
          // 인증 실패
          return MobileOKAPIResult.failure(
            error: result['resultMsg'] ?? '인증에 실패했습니다.',
          );
        }
      } else {
        return MobileOKAPIResult.failure(
          error: 'HTTP 오류: ${response.statusCode}',
        );
      }
      
    } catch (e) {
      print('결과 확인 오류: $e');
      
      // 개발 환경에서 연결 실패 시 시뮬레이션 모드로 전환
      if (_isDevelopment && (e.toString().contains('timeout') || e.toString().contains('TimeoutException') || e.toString().contains('connection'))) {
        print('⚠️ 개발 서버 연결 실패 - 시뮬레이션 결과 반환');
        return _generateSimulationResult(mokToken, clientTxId);
      }
      
      return MobileOKAPIResult.failure(
        error: '결과 확인 중 오류가 발생했습니다: $e',
      );
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

  /// 거래 ID 생성
  String _generateClientTxId() {
    final prefix = _clientPrefix.isNotEmpty ? _clientPrefix : 'TEST';
    final timestamp = _generateDateTime();
    return '${prefix}_$timestamp';
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

  /// 시뮬레이션 결과 생성 (개발환경용)
  static int _simulationCallCount = 0;
  
  MobileOKAPIResult _generateSimulationResult(String mokToken, String clientTxId) {
    _simulationCallCount++;
    
    // 3번째 호출부터 성공 결과 반환 (인증 진행 시뮬레이션)
    if (_simulationCallCount >= 3) {
      print('✅ 시뮬레이션 인증 완료 - 성공 결과 반환');
      _simulationCallCount = 0; // 리셋
      
      return MobileOKAPIResult.success(
        mokToken: mokToken,
        txId: 'SIMULATION_TX_${DateTime.now().millisecondsSinceEpoch}',
        clientTxId: clientTxId,
        name: '홍길동',
        birthDate: '19900101',
        gender: 'M',
        phoneNumber: '01012345678',
        ci: 'SIMULATION_CI_${DateTime.now().millisecondsSinceEpoch}',
        di: 'SIMULATION_DI_${DateTime.now().millisecondsSinceEpoch}',
        nation: '내국인',
        additionalData: {
          'resultCode': '2000',
          'resultMsg': '인증 성공 (시뮬레이션)',
          'simulationMode': true,
        },
      );
    } else {
      // 처음 몇 번은 진행중 상태로 반환
      print('⏳ 시뮬레이션 인증 진행중... ($_simulationCallCount/3)');
      return MobileOKAPIResult.failure(
        error: '인증 진행중입니다... (시뮬레이션)',
      );
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