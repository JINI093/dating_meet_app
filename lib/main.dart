import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
// import 'package:firebase_core/firebase_core.dart'; // Removed Firebase dependency
// import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // Temporarily disabled
// import 'package:flutter_naver_login/flutter_naver_login.dart'; // Unused import
// import 'package:google_sign_in/google_sign_in.dart'; // Unused import
import 'package:app_links/app_links.dart';

import 'l10n/app_localizations.dart';
import 'routes/app_router.dart';
import 'utils/theme.dart';
import 'config/aws_config.dart';
import 'amplifyconfiguration.dart';
import 'providers/enhanced_auth_provider.dart';
import 'providers/permission_provider.dart';
import 'utils/auth_error_handler.dart';
import 'utils/auth_ux_utils.dart';
import 'services/screen_capture_service.dart';
// import 'models/auth_result.dart'; // Unused import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 시스템 UI 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 전역 에러 핸들링 먼저 설정
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter 에러: ${details.exception}');
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    print('플랫폼 에러: $error');
    return true;
  };

  // 환경 변수 로딩 (non-blocking)
  try {
    await dotenv.load().timeout(const Duration(seconds: 5));
    print('✅ 환경 변수 로딩 완료');
  } catch (e) {
    print('⚠️ 환경 변수 로딩 실패: $e');
  }

  // CRITICAL: Amplify 초기화를 앱 시작 전에 완료
  await _initializeCriticalServices();

  // 앱 시작 - 나머지 초기화는 백그라운드에서 진행
  runApp(const ProviderScope(child: MyApp()));
}

/// 앱 시작 전 필수 서비스 초기화 (동기적으로 실행)
Future<void> _initializeCriticalServices() async {
  try {
    print('🚀 필수 서비스 초기화 시작...');
    
    // 1. AWS Config 로딩
    await _loadAWSConfig();
    
    // 2. AWS Amplify 설정 (가장 중요)
    await _configureAmplify();
    
    print('✅ 필수 서비스 초기화 완료');
  } catch (e) {
    print('❌ 필수 서비스 초기화 실패: $e');
    // 초기화 실패해도 앱은 시작하되, 에러 상태로 표시
  }
}

/// 백그라운드 초기화 순서 (필수가 아닌 서비스들)
Future<void> _initializeBackgroundServices() async {
  try {
    print('🔄 백그라운드 서비스 초기화 시작...');
    
    // 1. 소셜 SDK 초기화
    await _initializeSocialSDKs();
    
    // 2. 딥링크 처리 설정
    await _setupDeepLinks();
    
    // 3. 오프라인 상태 복구
    await _handleOnlineState();
    
    print('✅ 백그라운드 서비스 초기화 완료');
  } catch (e) {
    print('❌ 백그라운드 서비스 초기화 실패: $e');
    // 에러 로깅은 optional로 처리
    try {
      await AuthErrorHandler.logError(e, 'background_initialization');
    } catch (logError) {
      print('로깅 실패: $logError');
    }
  }
}

/// AWS Config 로딩
Future<void> _loadAWSConfig() async {
  try {
    await AWSConfig.load().timeout(const Duration(seconds: 10));
    // 검증을 try-catch로 감싸서 실패해도 앱이 멈추지 않게 함
    try {
      AWSConfig.validate();
      print('✅ AWS Config 검증 완료');
    } catch (e) {
      print('⚠️ AWS Config 검증 실패: $e');
    }
  } catch (e) {
    print('⚠️ AWS Config 로딩 실패: $e');
  }
}

/// 오프라인 상태 처리
Future<void> _handleOnlineState() async {
  try {
    await AuthErrorHandler.handleOnlineState().timeout(const Duration(seconds: 5));
    print('✅ 오프라인 상태 복구 완료');
  } catch (e) {
    print('⚠️ 오프라인 상태 복구 실패: $e');
  }
}

/// AWS Amplify 설정
Future<void> _configureAmplify() async {
  try {
    if (!Amplify.isConfigured) {
      final auth = AmplifyAuthCognito();
      final api = AmplifyAPI();
      final storage = AmplifyStorageS3();
      
      // 타임아웃 설정으로 무한 대기 방지
      await Amplify.addPlugins([auth, api, storage]).timeout(const Duration(seconds: 15));
      await Amplify.configure(amplifyconfig).timeout(const Duration(seconds: 15));
      print('✅ AWS Amplify 초기화 완료');
    } else {
      print('✅ AWS Amplify 이미 초기화됨');
    }
  } catch (e) {
    print('⚠️ Amplify 초기화 실패: $e');
    print('📝 개발 환경에서는 로컬 모드로 진행됩니다.');
    // 에러 로깅은 optional로 처리
    try {
      await AuthErrorHandler.logError(e, 'amplify_initialization');
    } catch (logError) {
      print('로깅 실패: $logError');
    }
  }
}

/// Firebase 초기화 (제거됨)
// Future<void> _initializeFirebase() async {
//   try {
//     await Firebase.initializeApp();
//     print('✅ Firebase 초기화 완료');
//   } catch (e) {
//     print('⚠️  Firebase 초기화 실패: $e');
//     await AuthErrorHandler.logError(e, 'firebase_initialization');
//   }
// }

/// 소셜 SDK 초기화
Future<void> _initializeSocialSDKs() async {
  try {
    // 소셜 SDK 초기화를 백그라운드에서 비동기적으로 수행
    print('✅ 소셜 SDK 초기화 건너뛰기 (성능 최적화)');
    
    // 실제 필요할 때 초기화하도록 변경
    // 카카오, 네이버, 구글 로그인 SDK는 각각의 로그인 시점에 초기화
    
  } catch (e) {
    print('⚠️  소셜 SDK 초기화 실패: $e');
    // 에러 로깅 제거 (성능 최적화)
  }
}

/// 딥링크 처리 설정
Future<void> _setupDeepLinks() async {
  try {
    // 앱 시작 시 딥링크 처리 (타임아웃 설정)
    final AppLinks appLinks = AppLinks();
    final initialLink = await appLinks.getInitialAppLink().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('딥링크 초기화 타임아웃');
        return null;
      },
    );
    
    if (initialLink != null) {
      _handleDeepLink(initialLink.toString());
    }

    // 앱 실행 중 딥링크 처리
    appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri.toString());
    }, onError: (err) {
      print('딥링크 스트림 에러: $err');
    });
    
    print('✅ 딥링크 처리 설정 완료');
  } catch (e) {
    print('⚠️ 딥링크 설정 실패: $e');
  }
}

/// 딥링크 처리
void _handleDeepLink(String link) {
  try {
    print('🔗 딥링크 수신: $link');
    
    final uri = Uri.parse(link);
    
    // 카카오 로그인 콜백
    if (uri.scheme.startsWith('kakao')) {
      _handleKakaoCallback(uri);
    }
    // 네이버 로그인 콜백
    else if (uri.scheme.startsWith('naver')) {
      _handleNaverCallback(uri);
    }
    // 구글 로그인 콜백
    else if (uri.scheme.startsWith('com.googleusercontent.apps')) {
      _handleGoogleCallback(uri);
    }
    // 기타 딥링크
    else {
      _handleCustomDeepLink(uri);
    }
  } catch (e) {
    print('❌ 딥링크 처리 실패: $e');
    AuthErrorHandler.logError(e, 'deep_link_handling');
  }
}

/// 카카오 로그인 콜백 처리
void _handleKakaoCallback(Uri uri) {
  try {
    // 카카오 로그인 콜백 처리
    // 실제 구현에서는 Provider를 통해 처리
    print('카카오 로그인 콜백 처리: $uri');
  } catch (e) {
    AuthErrorHandler.logError(e, 'kakao_callback');
  }
}

/// 네이버 로그인 콜백 처리
void _handleNaverCallback(Uri uri) {
  try {
    // 네이버 로그인 콜백 처리
    print('네이버 로그인 콜백 처리: $uri');
  } catch (e) {
    AuthErrorHandler.logError(e, 'naver_callback');
  }
}

/// 구글 로그인 콜백 처리
void _handleGoogleCallback(Uri uri) {
  try {
    // 구글 로그인 콜백 처리
    print('구글 로그인 콜백 처리: $uri');
  } catch (e) {
    AuthErrorHandler.logError(e, 'google_callback');
  }
}

/// 커스텀 딥링크 처리
void _handleCustomDeepLink(Uri uri) {
  try {
    // 앱 내부 딥링크 처리
    print('커스텀 딥링크 처리: $uri');
    
    // 예: 프로필 공유, 채팅방 초대 등
    switch (uri.path) {
      case '/profile':
        // 프로필 화면으로 이동
        break;
      case '/chat':
        // 채팅방으로 이동
        break;
      case '/match':
        // 매칭 화면으로 이동
        break;
      default:
        print('알 수 없는 딥링크 경로: ${uri.path}');
    }
  } catch (e) {
    AuthErrorHandler.logError(e, 'custom_deep_link');
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  bool _isInitialized = false;
  bool _isLoading = true;
  final ScreenCaptureService _screenCaptureService = ScreenCaptureService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 빌드 완료 후 초기화 실행
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
      _initializeScreenCapture();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screenCaptureService.dispose();
    super.dispose();
  }

  /// 스크린 캡처 방지 초기화
  Future<void> _initializeScreenCapture() async {
    try {
      await _screenCaptureService.initialize();
      if (mounted) {
        _screenCaptureService.startListening(context);
      }
    } catch (e) {
      print('스크린 캡처 방지 초기화 실패: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // 앱이 포그라운드로 돌아올 때
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        // 앱이 백그라운드로 갈 때
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        // 앱이 종료될 때
        _onAppDetached();
        break;
      default:
        break;
    }
  }

  /// 앱 초기화 (MyApp 내부)
  Future<void> _initializeApp() async {
    try {
      print('✅ 앱 초기화 시작');
      
      // EnhancedAuthProvider 초기화 (타임아웃 설정)
      final authProvider = ref.read(enhancedAuthProvider.notifier);
      await authProvider.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ AuthProvider 초기화 타임아웃');
        },
      );
      
      // 권한 초기화 (앱 최초 실행 시에만)
      final permissionNotifier = ref.read(permissionProvider.notifier);
      await permissionNotifier.initializePermissions().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ 권한 초기화 타임아웃');
        },
      );
      
      // 백그라운드 서비스 초기화 (필수가 아닌 서비스들)
      _initializeBackgroundServices();
      
      // 자동 로그인 체크 (백그라운드에서 실행)
      _checkAutoLogin();
      
      // 안전한 setState 호출
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
      
    } catch (e) {
      print('❌ 앱 초기화 실패: $e');
      
      // 안전한 setState 호출
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _isLoading = false;
        });
      }
    }
  }

  /// 자동 로그인 체크 (백그라운드에서 실행)
  Future<void> _checkAutoLogin() async {
    try {
      final authProvider = ref.read(enhancedAuthProvider.notifier);
      
      // 자동 로그인 시도 (타임아웃 설정)
      final autoLoginResult = await authProvider.checkAutoLogin().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ 자동 로그인 타임아웃');
          return AutoLoginResult(success: false, user: null);
        },
      ).catchError((e) {
        print('자동 로그인 에러: $e');
        return AutoLoginResult(success: false, user: null);
      });
      
      if (autoLoginResult.success == true) {
        print('✅ 자동 로그인 성공');
        
        // 로그인 기록 추가 (백그라운드에서 실행)
        _addLoginRecord(autoLoginResult);
        
      } else {
        print('ℹ️ 자동 로그인 실패 또는 비활성화');
        
        // 의심스러운 활동 감지 (백그라운드에서 실행)
        _detectSuspiciousActivity();
      }
      
    } catch (e) {
      print('❌ 자동 로그인 체크 실패: $e');
    }
  }
  
  /// 로그인 기록 추가 (백그라운드)
  void _addLoginRecord(dynamic autoLoginResult) {
    AuthUXUtils.addLoginRecord(
      autoLoginResult.user?.username ?? 'unknown',
      'auto_login',
      true,
    ).catchError((e) {
      print('로그인 기록 추가 실패: $e');
    });
    
    // 다중 기기 로그인 감지
    if (autoLoginResult.user?.username != null) {
      AuthUXUtils.checkMultiDeviceLogin(
        autoLoginResult.user!.username!
      ).catchError((e) {
        print('다중 기기 로그인 감지 실패: $e');
        return MultiDeviceResult(isMultiDevice: false, devices: [], message: '오류가 발생했습니다');
      });
    }
  }
  
  /// 의심스러운 활동 감지 (백그라운드)
  void _detectSuspiciousActivity() {
    AuthUXUtils.detectSuspiciousActivity().catchError((e) {
      print('의심스러운 활동 감지 실패: $e');
      return <SuspiciousActivity>[]; // Return empty list as default
    });
  }

  /// 앱이 포그라운드로 돌아올 때
  Future<void> _onAppResumed() async {
    try {
      // 온라인 상태 복구
      await AuthErrorHandler.handleOnlineState();
      
      // 로그인 상태 재확인
      final authProvider = ref.read(enhancedAuthProvider.notifier);
      await authProvider.refreshAuthState();
      
    } catch (e) {
      AuthErrorHandler.logError(e, 'app_resumed');
    }
  }

  /// 앱이 백그라운드로 갈 때
  Future<void> _onAppPaused() async {
    try {
      // 현재 상태 저장
      final authProvider = ref.read(enhancedAuthProvider.notifier);
      await authProvider.saveCurrentState();
      
    } catch (e) {
      AuthErrorHandler.logError(e, 'app_paused');
    }
  }

  /// 앱이 종료될 때
  Future<void> _onAppDetached() async {
    try {
      // 정리 작업
      final authProvider = ref.read(enhancedAuthProvider.notifier);
      await authProvider.cleanup();
      
    } catch (e) {
      AuthErrorHandler.logError(e, 'app_detached');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    // final authState = ref.watch(enhancedAuthProvider); // Unused variable

    return MaterialApp.router(
      title: '사귈래',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // 로딩 화면
        if (_isLoading) {
          return _buildLoadingScreen();
        }
        
        // 초기화 실패 시 에러 화면
        if (!_isInitialized) {
          return _buildErrorScreen();
        }
        
        // 정상 화면
        return child!;
      },
    );
  }

  /// 로딩 화면
  Widget _buildLoadingScreen() {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고 (에러 처리 추가)
              Container(
                width: 120,
                height: 120,
                child: Image.asset(
                  'assets/images/splash_logo.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.apps,
                      size: 120,
                      color: Colors.grey[300],
                    );
                  },
                ),
              ),
              SizedBox(height: 32),
              
              // 로딩 인디케이터
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 16),
              
              Text(
                '앱을 시작하는 중...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 에러 화면
  Widget _buildErrorScreen() {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                SizedBox(height: 16),
                
                Text(
                  '앱 초기화 실패',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 8),
                
                Text(
                  '앱을 다시 시작해주세요.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _isLoading = true;
                      });
                      _initializeApp();
                    }
                  },
                  child: Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}