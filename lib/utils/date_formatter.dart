import 'package:intl/intl.dart';

/// 날짜 포맷팅 유틸리티 클래스
class DateFormatter {
  /// 날짜와 시간을 포맷팅 (yyyy.MM.dd HH:mm)
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy.MM.dd HH:mm');
    return formatter.format(dateTime);
  }

  /// 날짜만 포맷팅 (yyyy.MM.dd)
  static String formatDate(DateTime dateTime) {
    final formatter = DateFormat('yyyy.MM.dd');
    return formatter.format(dateTime);
  }

  /// 시간만 포맷팅 (HH:mm)
  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  /// 상대적 시간 표시 (방금 전, N분 전, N시간 전, N일 전)
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}일 전';
    } else {
      return formatDate(dateTime);
    }
  }

  /// 한국어 날짜 포맷 (2024년 1월 15일)
  static String formatKoreanDate(DateTime dateTime) {
    final formatter = DateFormat('yyyy년 M월 d일');
    return formatter.format(dateTime);
  }

  /// 한국어 날짜와 시간 포맷 (2024년 1월 15일 오후 3:30)
  static String formatKoreanDateTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy년 M월 d일 a h:mm', 'ko');
    return formatter.format(dateTime);
  }
}