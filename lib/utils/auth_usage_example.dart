import 'package:flutter/material.dart';
import 'auth_error_handler.dart';
import 'auth_validators.dart';
import 'auth_ux_utils.dart';

/// 인증 유틸리티 사용 예시
/// 이 파일은 실제 구현 시 참고용이며, 실제 앱에서는 삭제하거나 별도 문서로 관리하세요.
class AuthUsageExample {
  
  /// 1. 에러 처리 예시
  static Future<void> handleLoginError(dynamic error, String context) async {
    // 에러 로깅
    await AuthErrorHandler.logError(error, context);
    
    // 에러 타입별 처리
    final errorType = AuthErrorHandler.classifyError(error);
    
    switch (errorType) {
      case AuthErrorType.network:
        // 네트워크 에러 시 자동 재시도
        await _retryLogin();
        break;
      case AuthErrorType.timeout:
        // 타임아웃 에러 시 사용자에게 알림
        _showTimeoutDialog();
        break;
      case AuthErrorType.cancelled:
        // 취소된 경우 무시
        break;
      case AuthErrorType.invalidInput:
        // 잘못된 입력 시 사용자에게 안내
        _showInvalidInputDialog();
        break;
      case AuthErrorType.quotaExceeded:
        // 할당량 초과 시 대기 시간 안내
        _showQuotaExceededDialog();
        break;
      case AuthErrorType.unknown:
        // 알 수 없는 에러 시 일반적인 에러 메시지
        _showGenericErrorDialog();
        break;
    }
  }

  /// 2. 실시간 검증 예시
  static void setupRealTimeValidation(TextEditingController controller, ValidationType type) {
    controller.addListener(() {
      final value = controller.text;
      final result = AuthValidators.validateRealTime(value, type);
      
      if (!result.isValid) {
        // 실시간 에러 표시
        _showValidationError(result.message);
      }
    });
  }

  /// 3. 비밀번호 강도 검증 예시
  static Widget buildPasswordStrengthIndicator(String password) {
    final result = AuthValidators.validatePassword(password);
    
    Color strengthColor;
    String strengthText;
    
    switch (result.strength) {
      case PasswordStrength.weak:
        strengthColor = Colors.red;
        strengthText = '약함';
        break;
      case PasswordStrength.medium:
        strengthColor = Colors.orange;
        strengthText = '보통';
        break;
      case PasswordStrength.strong:
        strengthColor = Colors.green;
        strengthText = '강함';
        break;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('비밀번호 강도: '),
            Text(
              strengthText,
              style: TextStyle(color: strengthColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (result.details.isNotEmpty)
          ...result.details.map((detail) => Text(
            '• $detail',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          )),
      ],
    );
  }

  /// 4. 자동 완성 예시
  static Future<Widget> buildAccountAutocomplete() async {
    final accounts = await AuthUXUtils.getSavedAccounts();
    
    return Autocomplete<SavedAccount>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return accounts;
        }
        return accounts.where((account) =>
            account.username.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
            account.email.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      displayStringForOption: (SavedAccount account) => account.username,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: '아이디 또는 이메일',
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          elevation: 4.0,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final account = options.elementAt(index);
              return ListTile(
                title: Text(account.username),
                subtitle: Text(account.email),
                trailing: Text(account.loginType),
                onTap: () => onSelected(account),
              );
            },
          ),
        );
      },
    );
  }

  /// 5. 생체 인증 예시
  static Future<void> setupBiometricAuth() async {
    // 생체 인증 지원 확인
    final support = await AuthUXUtils.checkBiometricSupport();
    
    if (support.isSupported) {
      // 생체 인증 활성화
      await AuthUXUtils.enableBiometric();
      
      // 생체 인증으로 로그인 시도
      final result = await AuthUXUtils.authenticateWithBiometric();
      
      if (result.success) {
        // 생체 인증 성공 시 자동 로그인
        await _performAutoLogin();
      } else {
        // 생체 인증 실패 시 일반 로그인으로 전환
        _showBiometricError(result.message);
      }
    } else {
      // 생체 인증 미지원 시 일반 로그인
      _showBiometricNotSupported(support.message);
    }
  }

  /// 6. 다중 기기 로그인 감지 예시
  static Future<void> checkMultiDeviceLogin(String username) async {
    final result = await AuthUXUtils.checkMultiDeviceLogin(username);
    
    if (result.isMultiDevice) {
      // 다중 기기 로그인 감지 시 보안 알림
      await AuthUXUtils.addSecurityAlert(
        SecurityAlertType.newDevice,
        '새로운 기기에서 로그인이 감지되었습니다.',
        {
          'deviceCount': result.devices.length,
          'devices': result.devices.map((d) => d.toJson()).toList(),
        },
      );
      
      // 사용자에게 알림
      _showMultiDeviceAlert(result);
    }
  }

  /// 7. 의심스러운 활동 감지 예시
  static Future<void> monitorSuspiciousActivity() async {
    final activities = await AuthUXUtils.detectSuspiciousActivity();
    
    for (final activity in activities) {
      // 심각도에 따른 처리
      switch (activity.severity) {
        case SuspiciousActivitySeverity.high:
          // 높은 심각도: 즉시 보안 알림 및 추가 인증 요구
          await _handleHighSeverityActivity(activity);
          break;
        case SuspiciousActivitySeverity.medium:
          // 중간 심각도: 보안 알림
          await _handleMediumSeverityActivity(activity);
          break;
        case SuspiciousActivitySeverity.low:
          // 낮은 심각도: 로그만 기록
          await _handleLowSeverityActivity(activity);
          break;
      }
    }
  }

  /// 8. 종합 검증 예시
  static Future<bool> validateSignupForm({
    required String username,
    required String password,
    required String email,
    String? phoneNumber,
  }) async {
    // 종합 검증
    final summary = AuthValidators.validateAll(
      username: username,
      password: password,
      email: email,
      phoneNumber: phoneNumber,
    );
    
    if (!summary.isValid) {
      // 에러 메시지 표시
      _showValidationErrors(summary.errorMessages);
      return false;
    }
    
    // 중복 확인
    final usernameAvailable = await AuthValidators.checkUsernameAvailability(username);
    final emailAvailable = await AuthValidators.checkEmailAvailability(email);
    
    if (!usernameAvailable || !emailAvailable) {
      _showDuplicateError(usernameAvailable, emailAvailable);
      return false;
    }
    
    return true;
  }

  /// 9. 로그인 통계 예시
  static Future<Widget> buildLoginStatistics() async {
    final stats = await AuthUXUtils.getLoginStatistics();
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '로그인 통계',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('총 시도: ${stats.totalAttempts}'),
            Text('성공: ${stats.successfulLogins}'),
            Text('실패: ${stats.failedLogins}'),
            Text('성공률: ${stats.successRate.toStringAsFixed(1)}%'),
            Text('최근 활동: ${stats.recentActivity}'),
            SizedBox(height: 8),
            Text('로그인 방식별:'),
            ...stats.loginTypes.entries.map((entry) =>
                Text('  ${entry.key}: ${entry.value}회')),
          ],
        ),
      ),
    );
  }

  /// 10. 보안 알림 관리 예시
  static Future<Widget> buildSecurityAlerts() async {
    final alerts = await AuthUXUtils.getSecurityAlerts();
    final unreadCount = await AuthUXUtils.getUnreadAlertCount();
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '보안 알림',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (unreadCount > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        if (alerts.isEmpty)
          Text('보안 알림이 없습니다.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return ListTile(
                leading: Icon(
                  _getAlertIcon(alert.type),
                  color: alert.isRead ? Colors.grey : Colors.red,
                ),
                title: Text(
                  alert.message,
                  style: TextStyle(
                    fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  _formatTimestamp(alert.timestamp),
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () async {
                  await AuthUXUtils.markAlertAsRead(alert.id);
                  // 알림 상세 보기
                  _showAlertDetails(alert);
                },
              );
            },
          ),
      ],
    );
  }

  // 헬퍼 메서드들
  static Future<void> _retryLogin() async {
    // 자동 재시도 로직
    await AuthErrorHandler.retryOperation(
      operation: () async {
        // 실제 로그인 로직
        return true;
      },
      shouldRetry: (error) => error.toString().contains('network'),
    );
  }

  static void _showTimeoutDialog() {
    // 타임아웃 다이얼로그 표시
  }

  static void _showInvalidInputDialog() {
    // 잘못된 입력 다이얼로그 표시
  }

  static void _showQuotaExceededDialog() {
    // 할당량 초과 다이얼로그 표시
  }

  static void _showGenericErrorDialog() {
    // 일반 에러 다이얼로그 표시
  }

  static void _showValidationError(String message) {
    // 검증 에러 표시
  }

  static Future<void> _performAutoLogin() async {
    // 자동 로그인 수행
  }

  static void _showBiometricError(String message) {
    // 생체 인증 에러 표시
  }

  static void _showBiometricNotSupported(String message) {
    // 생체 인증 미지원 표시
  }

  static void _showMultiDeviceAlert(MultiDeviceResult result) {
    // 다중 기기 알림 표시
  }

  static Future<void> _handleHighSeverityActivity(SuspiciousActivity activity) async {
    // 높은 심각도 활동 처리
  }

  static Future<void> _handleMediumSeverityActivity(SuspiciousActivity activity) async {
    // 중간 심각도 활동 처리
  }

  static Future<void> _handleLowSeverityActivity(SuspiciousActivity activity) async {
    // 낮은 심각도 활동 처리
  }

  static void _showValidationErrors(List<String> errors) {
    // 검증 에러들 표시
  }

  static void _showDuplicateError(bool usernameAvailable, bool emailAvailable) {
    // 중복 에러 표시
  }

  static IconData _getAlertIcon(SecurityAlertType type) {
    switch (type) {
      case SecurityAlertType.loginFailure:
        return Icons.error;
      case SecurityAlertType.newDevice:
        return Icons.devices;
      case SecurityAlertType.unusualTime:
        return Icons.access_time;
      case SecurityAlertType.multipleFailures:
        return Icons.warning;
      case SecurityAlertType.unknown:
        return Icons.info;
    }
  }

  static String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  static void _showAlertDetails(SecurityAlert alert) {
    // 알림 상세 보기
  }
} 