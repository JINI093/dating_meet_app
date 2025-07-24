package com.example.dating_meet_app

import android.graphics.Bitmap
import android.graphics.Canvas
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "screen_capture_channel"
    private var isScreenCaptureAllowed = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 스크린 캡처 방지 - FLAG_SECURE 적용
        enableScreenCapturePrevention()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "captureScreenshot" -> {
                        captureScreenshot(result)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun enableScreenCapturePrevention() {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
        isScreenCaptureAllowed = false
    }

    private fun disableScreenCapturePrevention() {
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        isScreenCaptureAllowed = true
    }

    private fun captureScreenshot(result: MethodChannel.Result) {
        try {
            // 일시적으로 스크린 캡처 방지 해제
            disableScreenCapturePrevention()
            
            // 50ms 지연 후 캡처 실행 (FLAG_SECURE 해제가 적용되도록)
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                try {
                    val view = findViewById<View>(android.R.id.content)
                    val bitmap = Bitmap.createBitmap(view.width, view.height, Bitmap.Config.ARGB_8888)
                    val canvas = Canvas(bitmap)
                    view.draw(canvas)

                    // 파일로 저장
                    val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
                    val fileName = "report_screenshot_$timestamp.png"
                    val file = File(filesDir, fileName)
                    
                    FileOutputStream(file).use { out ->
                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
                    }
                    
                    // 스크린 캡처 방지 재활성화
                    enableScreenCapturePrevention()
                    
                    result.success(file.absolutePath)
                    println("신고용 스크린샷 저장 완료: ${file.absolutePath}")
                    
                } catch (e: Exception) {
                    enableScreenCapturePrevention()
                    result.error("CAPTURE_FAILED", "스크린샷 캡처 실패", e.message)
                }
            }, 50)
            
        } catch (e: Exception) {
            enableScreenCapturePrevention()
            result.error("CAPTURE_ERROR", "스크린샷 캡처 오류", e.message)
        }
    }
}
