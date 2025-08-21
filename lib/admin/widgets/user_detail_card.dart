import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/admin_theme.dart';
import '../services/push_notification_service.dart';

/// 사용자 상세 정보 카드 위젯
class UserDetailCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onClose;

  const UserDetailCard({
    super.key,
    required this.user,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(AdminTheme.spacingL),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500), // Limit maximum height
        padding: const EdgeInsets.all(AdminTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '회원 상세 정보',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AdminTheme.primaryColor,
                  ),
                ),
                Row(
                  children: [
                    // Push notification button
                    ElevatedButton.icon(
                      onPressed: () => _sendPushNotification(context),
                      icon: const Icon(Icons.notifications_active, size: 18),
                      label: const Text('푸시 알림'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: AdminTheme.spacingS),
                    // Close button
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                      tooltip: '닫기',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AdminTheme.spacingL),
            
            // User detail content
            Flexible(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile image section
                    _buildProfileImageSection(),
                    const SizedBox(width: AdminTheme.spacingXL),
                    
                    // User information section
                    Expanded(
                      child: _buildUserInfoSection(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AdminTheme.radiusL),
            border: Border.all(
              color: AdminTheme.borderColor,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AdminTheme.radiusL - 2),
            child: user.profileImage != null
                ? Image.network(
                    user.profileImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                  )
                : _buildDefaultAvatar(),
          ),
        ),
        const SizedBox(height: AdminTheme.spacingM),
        _buildProfileBadges(),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AdminTheme.surfaceColor,
      child: Icon(
        Icons.person,
        size: 60,
        color: AdminTheme.secondaryTextColor,
      ),
    );
  }

  Widget _buildProfileBadges() {
    return Column(
      children: [
        if (user.isVip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AdminTheme.primaryColor,
              borderRadius: BorderRadius.circular(AdminTheme.radiusM),
            ),
            child: const Text(
              'VIP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: AdminTheme.spacingS),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.isPhoneVerified)
              _buildVerificationBadge('본인인증', AdminTheme.successColor),
            if (user.isJobVerified)
              _buildVerificationBadge('직업인증', AdminTheme.infoColor),
            if (user.isPhotoVerified)
              _buildVerificationBadge('사진인증', AdminTheme.warningColor),
          ],
        ),
      ],
    );
  }

  Widget _buildVerificationBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AdminTheme.radiusS),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic info row
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                '회원 이름',
                user.name,
                Icons.person,
                AdminTheme.primaryColor,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildInfoCard(
                '성별',
                user.gender == 'male' ? '남성' : '여성',
                user.gender == 'male' ? Icons.male : Icons.female,
                user.gender == 'male' ? Colors.blue : Colors.pink,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingM),
        
        // Age and birth date row
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                '나이',
                '${user.age}세',
                Icons.cake,
                AdminTheme.warningColor,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildInfoCard(
                '생년월일',
                _calculateBirthYear(user.age),
                Icons.calendar_today,
                AdminTheme.infoColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingM),
        
        // Contact info row
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                '전화번호',
                _formatPhoneNumber(user.phoneNumber),
                Icons.phone,
                AdminTheme.successColor,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildInfoCard(
                '지역',
                user.location.isNotEmpty ? user.location : '미설정',
                Icons.location_on,
                AdminTheme.errorColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingM),
        
        // VIP and points row
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'VIP 등급',
                user.isVip ? 'VIP 회원' : '일반 회원',
                Icons.star,
                user.isVip ? AdminTheme.primaryColor : AdminTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildInfoCard(
                '보유 포인트',
                '${_formatNumber(user.points)} P',
                Icons.monetization_on,
                AdminTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingM),
        
        // Verification status row
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                '승인 여부',
                _getVerificationStatus(),
                Icons.verified,
                _getVerificationColor(),
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildInfoCard(
                '계정 상태',
                user.status.displayName,
                Icons.account_circle,
                _getStatusColor(user.status),
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingM),
        
        // Date info row
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                '최근 접속일',
                user.lastLoginAt != null 
                    ? _formatDateTime(user.lastLoginAt!)
                    : '접속 기록 없음',
                Icons.access_time,
                AdminTheme.infoColor,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildInfoCard(
                '가입 날짜',
                _formatDateTime(user.createdAt),
                Icons.person_add,
                AdminTheme.successColor,
              ),
            ),
          ],
        ),
        
        // Additional info if available
        if (user.bio?.isNotEmpty == true) ...[
          const SizedBox(height: AdminTheme.spacingM),
          _buildInfoCard(
            '자기소개',
            user.bio!,
            Icons.description,
            AdminTheme.primaryTextColor,
            isWide: true,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color iconColor, {
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.spacingM),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AdminTheme.radiusM),
        border: Border.all(color: AdminTheme.borderColor),
      ),
      child: isWide 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: AdminTheme.spacingS),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AdminTheme.secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdminTheme.spacingS),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: AdminTheme.primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: AdminTheme.spacingS),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminTheme.secondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AdminTheme.spacingS),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: AdminTheme.primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
    );
  }

  String _calculateBirthYear(int age) {
    final currentYear = DateTime.now().year;
    final birthYear = currentYear - age;
    return '$birthYear년생 (만 $age세)';
  }

  String _formatPhoneNumber(String phone) {
    if (phone.length >= 11) {
      // Format: +82 10-1234-5678
      if (phone.startsWith('+82')) {
        final number = phone.substring(3);
        if (number.length >= 10) {
          return '+82 ${number.substring(0, 2)}-${number.substring(2, 6)}-${number.substring(6)}';
        }
      }
      // Format: 010-1234-5678
      return '${phone.substring(0, 3)}-${phone.substring(3, 7)}-${phone.substring(7)}';
    }
    return phone;
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]!},',
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getVerificationStatus() {
    final verifications = <String>[];
    if (user.isPhoneVerified) verifications.add('본인인증');
    if (user.isJobVerified) verifications.add('직업인증');
    if (user.isPhotoVerified) verifications.add('사진인증');
    
    if (verifications.isEmpty) return '미인증';
    return verifications.join(', ');
  }

  Color _getVerificationColor() {
    if (user.isPhoneVerified && user.isJobVerified && user.isPhotoVerified) {
      return AdminTheme.successColor;
    } else if (user.isPhoneVerified || user.isJobVerified || user.isPhotoVerified) {
      return AdminTheme.warningColor;
    }
    return AdminTheme.errorColor;
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return AdminTheme.successColor;
      case UserStatus.suspended:
        return AdminTheme.warningColor;
      case UserStatus.deleted:
        return AdminTheme.errorColor;
    }
  }

  /// 푸시 알림 전송
  Future<void> _sendPushNotification(BuildContext context) async {
    // 확인 다이얼로그 표시
    final shouldSend = await _showNotificationConfirmDialog(context);
    if (!shouldSend) return;

    // Context를 저장하고 mounted 상태 추적
    if (!context.mounted) return;
    
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false, // 뒤로가기 차단
        child: const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('푸시 알림을 전송하고 있습니다...'),
              SizedBox(height: 8),
              Text(
                '잠시만 기다려주세요',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // 푸시 알림 전송 (타임아웃 추가)
      final success = await PushNotificationService.sendSimulatedNotification(
        user: user,
        customMessage: "인연은 타이밍, 지금 사귈래~ 🤍",
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('알림 전송 시간이 초과되었습니다');
        },
      );

      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (popError) {
          // Dialog가 이미 닫혔거나 context 문제가 있는 경우 무시
          debugPrint('Dialog close error (ignored): $popError');
        }
        
        // 잠시 대기 후 결과 표시 (UI 안정화)
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (context.mounted) {
          _showResultDialog(context, success);
        }
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (popError) {
          // Dialog가 이미 닫혔거나 context 문제가 있는 경우 무시
          debugPrint('Dialog close error (ignored): $popError');
        }
        
        // 잠시 대기 후 에러 표시
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (context.mounted) {
          _showResultDialog(context, false, error: e.toString());
        }
      }
    }
  }

  /// 알림 전송 확인 다이얼로그
  Future<bool> _showNotificationConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.orange),
            SizedBox(width: 8),
            Text('푸시 알림 전송'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user.name}님에게 푸시 알림을 전송하시겠습니까?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminTheme.primaryColor.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '전송될 메시지:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '"인연은 타이밍, 지금 사귈래~ 🤍"',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('전송'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// 결과 다이얼로그 표시
  void _showResultDialog(BuildContext context, bool success, {String? error}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? AdminTheme.successColor : AdminTheme.errorColor,
            ),
            const SizedBox(width: 8),
            Text(success ? '전송 완료' : '전송 실패'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (success) ...[
              Text('${user.name}님에게 푸시 알림이 성공적으로 전송되었습니다.'),
              const SizedBox(height: 8),
              const Text(
                '💌 사용자가 알림을 받으면 앱으로 돌아올 가능성이 높아집니다!',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ] else ...[
              Text('${user.name}님에게 푸시 알림 전송에 실패했습니다.'),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  '오류: $error',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: success ? AdminTheme.successColor : AdminTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}