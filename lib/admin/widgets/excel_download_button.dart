import 'package:flutter/material.dart';
import '../utils/admin_theme.dart';

/// 엑셀 다운로드 버튼
class ExcelDownloadButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;

  const ExcelDownloadButton({
    super.key,
    required this.onPressed,
    this.text = '엑셀 다운로드',
    this.isLoading = false,
  });

  @override
  State<ExcelDownloadButton> createState() => _ExcelDownloadButtonState();
}

class _ExcelDownloadButtonState extends State<ExcelDownloadButton>
    with SingleTickerProviderStateMixin {
  bool _isDownloading = false;

  Future<void> _handleDownload() async {
    if (_isDownloading) return;
    
    setState(() => _isDownloading = true);
    
    try {
      widget.onPressed();
      
      // 2초 후 완료 표시
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AdminTheme.successColor,
                ),
                const SizedBox(width: AdminTheme.spacingS),
                const Text('다운로드가 완료되었습니다'),
              ],
            ),
            backgroundColor: AdminTheme.surfaceColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminTheme.radiusM),
              side: BorderSide(color: AdminTheme.successColor.withOpacity(0.3)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isDownloading || widget.isLoading ? null : _handleDownload,
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminTheme.successColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AdminTheme.spacingL,
          vertical: AdminTheme.spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTheme.radiusM),
        ),
      ),
      icon: _isDownloading || widget.isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.file_download_outlined),
      label: Text(
        _isDownloading ? '다운로드 중...' : widget.text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}