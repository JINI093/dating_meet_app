import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 스크린 캡처 방지 설정
    setupScreenshotPrevention()
    
    // 메소드 채널 설정
    setupMethodChannel()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // 메소드 채널 설정
  private func setupMethodChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    
    let channel = FlutterMethodChannel(name: "screen_capture_channel", binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "captureScreenshot":
        self?.captureScreenshot(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  // 스크린샷 방지 설정
  private func setupScreenshotPrevention() {
    // 스크린샷 및 스크린 레코딩 감지
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenshotTaken),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
    
    // 스크린 레코딩 감지
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenRecordingChanged),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    
    // 백그라운드 진입 시 보안 화면 표시
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleApplicationWillResignActive),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    
    // 포그라운드 복귀 시 보안 화면 제거
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleApplicationDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
  }
  
  @objc private func screenshotTaken() {
    // 스크린샷 감지 시 처리
    print("스크린샷이 감지되었습니다.")
    // Flutter 채널을 통해 다이얼로그 표시 요청
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "screen_capture_channel", binaryMessenger: controller.binaryMessenger)
      channel.invokeMethod("onScreenshotDetected", arguments: nil)
    }
  }
  
  @objc private func screenRecordingChanged() {
    if UIScreen.main.isCaptured {
      print("스크린 레코딩이 감지되었습니다.")
      // Flutter 채널을 통해 다이얼로그 표시 요청
      if let controller = window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: "screen_capture_channel", binaryMessenger: controller.binaryMessenger)
        channel.invokeMethod("onScreenRecordingDetected", arguments: nil)
      }
    }
  }
  
  private var securityView: UIView?
  
  @objc private func handleApplicationWillResignActive() {
    // 백그라운드 진입 시 보안 화면 표시
    showSecurityView()
  }
  
  @objc private func handleApplicationDidBecomeActive() {
    // 포그라운드 복귀 시 보안 화면 제거
    hideSecurityView()
  }
  
  private func showSecurityView() {
    guard let window = self.window else { return }
    
    securityView = UIView(frame: window.bounds)
    securityView?.backgroundColor = UIColor.white
    
    // 로고 또는 보안 메시지 추가
    let label = UILabel()
    label.text = "사귈래"
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    label.textColor = UIColor.black
    label.translatesAutoresizingMaskIntoConstraints = false
    
    securityView?.addSubview(label)
    
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: securityView!.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: securityView!.centerYAnchor)
    ])
    
    window.addSubview(securityView!)
  }
  
  private func hideSecurityView() {
    securityView?.removeFromSuperview()
    securityView = nil
  }
  
  // 스크린샷 캡처 (신고 전용)
  private func captureScreenshot(result: @escaping FlutterResult) {
    guard let window = self.window else {
      result(FlutterError(code: "NO_WINDOW", message: "Window not available", details: nil))
      return
    }
    
    // 현재 화면을 이미지로 캡처
    let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
    let image = renderer.image { context in
      window.layer.render(in: context.cgContext)
    }
    
    // 문서 디렉토리에 저장
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let timestamp = Int(Date().timeIntervalSince1970)
    let fileName = "report_screenshot_\(timestamp).png"
    let fileURL = documentsPath.appendingPathComponent(fileName)
    
    do {
      if let data = image.pngData() {
        try data.write(to: fileURL)
        result(fileURL.path)
        print("신고용 스크린샷 저장 완료: \(fileURL.path)")
      } else {
        result(FlutterError(code: "IMAGE_CONVERSION_FAILED", message: "Failed to convert image to PNG", details: nil))
      }
    } catch {
      result(FlutterError(code: "FILE_WRITE_FAILED", message: "Failed to write screenshot file", details: error.localizedDescription))
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
