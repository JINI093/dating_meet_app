import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/screen_capture_service.dart';

class ReportDialog extends StatefulWidget {
  final String userName;
  final VoidCallback? onReportSubmitted;

  const ReportDialog({
    super.key,
    required this.userName,
    this.onReportSubmitted,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? selectedReason;
  bool hasScreenshot = false;

  final List<String> reportReasons = [
    '성희롱, 모욕적인 단어를 사용해요',
    '홍보 및 광고 목적이에요',
    '불쾌한 사진을 보냈어요',
    '다른 메신저로 유도해요',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Title
            const Text(
              '불쾌함을 느끼셨다면\n신고해주세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            
            // Subtitle
            const Text(
              '사랑래는 언제나 쾌적한 환경을 만들기 위해\n회원님들을 관리하고 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // Report reasons
            ...reportReasons.map((reason) => _buildReasonButton(reason)),
            
            const SizedBox(height: 20),
            
            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonButton(String reason) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () => _selectReason(reason),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF357B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: Text(
          reason,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _selectReason(String reason) {
    setState(() {
      selectedReason = reason;
    });
    Navigator.of(context).pop();
    _showCaptureIntroDialog();
  }

  void _showCaptureIntroDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReportCaptureIntroDialog(
        userName: widget.userName,
        selectedReason: selectedReason!,
        onReportSubmitted: widget.onReportSubmitted,
      ),
    );
  }
}

class ReportCaptureIntroDialog extends StatelessWidget {
  final String userName;
  final String selectedReason;
  final VoidCallback? onReportSubmitted;

  const ReportCaptureIntroDialog({
    super.key,
    required this.userName,
    required this.selectedReason,
    this.onReportSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Title
            const Text(
              '불쾌함을 느끼셨다면\n신고해주세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 32),
            
            // Capture button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showCaptureDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF357B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '캡처하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCaptureDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReportCaptureDialog(
        userName: userName,
        selectedReason: selectedReason,
        onReportSubmitted: onReportSubmitted,
      ),
    );
  }
}

class ReportCaptureDialog extends StatefulWidget {
  final String userName;
  final String selectedReason;
  final VoidCallback? onReportSubmitted;
  final bool initialHasScreenshot;
  final String? initialScreenshotPath;

  const ReportCaptureDialog({
    super.key,
    required this.userName,
    required this.selectedReason,
    this.onReportSubmitted,
    this.initialHasScreenshot = false,
    this.initialScreenshotPath,
  });

  @override
  State<ReportCaptureDialog> createState() => _ReportCaptureDialogState();
}

class _ReportCaptureDialogState extends State<ReportCaptureDialog> {
  bool hasScreenshot = false;
  String? screenshotPath;

  @override
  void initState() {
    super.initState();
    hasScreenshot = widget.initialHasScreenshot;
    screenshotPath = widget.initialScreenshotPath;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Title
            const Text(
              '불쾌함을 느끼셨다면\n신고해주세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            
            // Subtitle
            const Text(
              '사랑래는 언제나 쾌적한 환경을 만들기 위해\n회원님들을 관리하고 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            
            // Selected reason
            Text(
              '신고사유 : ${widget.selectedReason}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 24),
            
            // Screenshot capture button
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFFF357B),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _captureScreenshot,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Text(
                      hasScreenshot ? '캡처완료' : '캡처할 사진',
                      style: TextStyle(
                        fontSize: 16,
                        color: hasScreenshot ? const Color(0xFFFF357B) : const Color(0xFF999999),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF999999),
                ),
              ),
            ),
            
            if (hasScreenshot) ...[
              const SizedBox(height: 8),
              // Confirm button (only shown after screenshot)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF357B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '컵쳐하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _captureScreenshot() async {
    try {
      // 먼저 다이얼로그를 숨김
      Navigator.of(context).pop();
      
      // 잠시 대기 후 스크린샷 캡처 (다이얼로그가 완전히 사라질 때까지)
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 스크린 캡처 서비스를 통해 신고용 스크린샷 캡처
      final capturedPath = await ScreenCaptureService().captureForReport();
      
      if (capturedPath != null) {
        // 캡처 성공 시 다이얼로그를 다시 표시하고 상태 업데이트
        if (mounted) {
          setState(() {
            hasScreenshot = true;
            screenshotPath = capturedPath;
          });
          
          _showCaptureDialogWithScreenshot();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('스크린샷이 캡처되었습니다.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // 캡처 실패 시 다이얼로그를 다시 표시
        if (mounted) {
          _showCaptureDialogWithScreenshot();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('스크린샷 캡처에 실패했습니다.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showCaptureDialogWithScreenshot();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('스크린샷 캡처 중 오류가 발생했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  void _showCaptureDialogWithScreenshot() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReportCaptureDialog(
        userName: widget.userName,
        selectedReason: widget.selectedReason,
        onReportSubmitted: widget.onReportSubmitted,
        initialHasScreenshot: hasScreenshot,
        initialScreenshotPath: screenshotPath,
      ),
    );
  }

  void _submitReport() {
    Navigator.of(context).pop();
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '불쾌함을 느끼셨다면\n신고해주세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onReportSubmitted?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('신고가 접수되었습니다.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF357B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '컵쳐하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}