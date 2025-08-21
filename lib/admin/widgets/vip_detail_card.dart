import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/admin_theme.dart';
import '../services/admin_users_service.dart';

/// VIP 회원 상세 정보 카드 위젯
class VipDetailCard extends StatefulWidget {
  final UserModel user;
  final VoidCallback? onClose;
  final VoidCallback? onUpdate;

  const VipDetailCard({
    super.key,
    required this.user,
    this.onClose,
    this.onUpdate,
  });

  @override
  State<VipDetailCard> createState() => _VipDetailCardState();
}

class _VipDetailCardState extends State<VipDetailCard> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late String _selectedVipGrade;
  late String _originalVipGrade; // 원래 등급 저장
  final AdminUsersService _usersService = AdminUsersService();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    // 기존 VIP 등급이 있으면 사용, 없으면 포인트 기반으로 설정
    if (widget.user.vipGrade != null) {
      _selectedVipGrade = widget.user.vipGrade!;
    } else if (widget.user.points >= 3000) {
      _selectedVipGrade = '골드';
    } else if (widget.user.points >= 1000) {
      _selectedVipGrade = '실버';
    } else {
      _selectedVipGrade = '브론즈';
    }
    _originalVipGrade = _selectedVipGrade; // 원래 등급 저장
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(AdminTheme.spacingL),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(AdminTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with buttons
            _buildHeader(),
            const SizedBox(height: AdminTheme.spacingL),
            
            // VIP detail content
            Flexible(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // VIP 등급 및 상태 섹션
                    _buildVipStatusSection(),
                    const SizedBox(width: AdminTheme.spacingXL),
                    
                    // 상세 정보 섹션
                    Expanded(
                      child: _buildDetailInfoSection(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'VIP 회원 상세 정보',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AdminTheme.primaryColor,
          ),
        ),
        Row(
          children: [
            if (!_isEditing) ...[
              // 수정 버튼
              ElevatedButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('수정'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.warningColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ] else ...[
              // 완료 버튼
              ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('완료'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: AdminTheme.spacingS),
              // 취소 버튼
              ElevatedButton.icon(
                onPressed: _cancelEditing,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('취소'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.errorColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
            const SizedBox(width: AdminTheme.spacingS),
            // 닫기 버튼
            IconButton(
              onPressed: widget.onClose,
              icon: const Icon(Icons.close),
              tooltip: '닫기',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVipStatusSection() {
    final vipExpiryDate = widget.user.createdAt.add(const Duration(days: 30));
    final daysRemaining = vipExpiryDate.difference(DateTime.now()).inDays;
    
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AdminTheme.radiusL),
            border: Border.all(
              color: AdminTheme.primaryColor,
              width: 3,
            ),
            gradient: LinearGradient(
              colors: [
                AdminTheme.primaryColor.withValues(alpha: 0.1),
                AdminTheme.secondaryColor.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AdminTheme.radiusL - 3),
            child: widget.user.profileImage != null
                ? Image.network(
                    widget.user.profileImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                  )
                : _buildDefaultAvatar(),
          ),
        ),
        const SizedBox(height: AdminTheme.spacingM),
        
        // VIP 배지
        if (!_isEditing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getGradeColor(_selectedVipGrade),
              borderRadius: BorderRadius.circular(AdminTheme.radiusM),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_selectedVipGrade VIP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else
          // 수정 모드에서는 드롭다운으로 선택
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AdminTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AdminTheme.radiusM),
              border: Border.all(color: AdminTheme.borderColor),
            ),
            child: DropdownButton<String>(
              value: _selectedVipGrade,
              items: ['골드', '실버', '브론즈'].map((grade) {
                return DropdownMenuItem(
                  value: grade,
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: _getGradeColor(grade),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$grade VIP',
                        style: TextStyle(
                          color: _getGradeColor(grade),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedVipGrade = value;
                  });
                }
              },
              isDense: true,
              underline: const SizedBox(),
            ),
          ),
        const SizedBox(height: AdminTheme.spacingS),
        
        // VIP 남은 기간
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: daysRemaining > 30
                ? AdminTheme.successColor.withValues(alpha: 0.1)
                : daysRemaining > 7
                    ? AdminTheme.warningColor.withValues(alpha: 0.1)
                    : AdminTheme.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AdminTheme.radiusS),
            border: Border.all(
              color: daysRemaining > 30
                  ? AdminTheme.successColor
                  : daysRemaining > 7
                      ? AdminTheme.warningColor
                      : AdminTheme.errorColor,
            ),
          ),
          child: Text(
            '남은 기간: $daysRemaining일',
            style: TextStyle(
              color: daysRemaining > 30
                  ? AdminTheme.successColor
                  : daysRemaining > 7
                      ? AdminTheme.warningColor
                      : AdminTheme.errorColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AdminTheme.surfaceColor,
      child: const Icon(
        Icons.person,
        size: 60,
        color: AdminTheme.secondaryTextColor,
      ),
    );
  }

  Widget _buildDetailInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 기본 정보 행
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                '회원 이름',
                _isEditing ? null : widget.user.name,
                Icons.person,
                AdminTheme.primaryColor,
                controller: _isEditing ? _nameController : null,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildInfoCard(
                '나이',
                '${widget.user.age}세',
                Icons.cake,
                AdminTheme.warningColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingM),
        
        // 연락처 정보 행
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                '전화번호',
                _isEditing ? null : widget.user.phoneNumber,
                Icons.phone,
                AdminTheme.successColor,
                controller: _isEditing ? _phoneController : null,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildInfoCard(
                'VIP 구매일',
                _formatDateTime(widget.user.createdAt),
                Icons.shopping_cart,
                AdminTheme.infoColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingM),
        
        // 활동 정보 행 1
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                '받은 좋아요',
                '${widget.user.receivedLikes}개',
                Icons.favorite,
                AdminTheme.errorColor,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildInfoCard(
                '받은 슈퍼챗',
                '${widget.user.successfulMatches}개',
                Icons.star,
                AdminTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingM),
        
        // 활동 정보 행 2
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                '보낸 좋아요',
                '${widget.user.sentLikes}개',
                Icons.favorite_border,
                AdminTheme.warningColor,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildInfoCard(
                '보낸 슈퍼챗',
                '${widget.user.successfulMatches}개', // 실제로는 별도 필드가 필요
                Icons.chat,
                AdminTheme.infoColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingM),
        
        // 접속 정보
        _buildInfoCard(
          '접속 IP',
          '192.168.1.100', // 실제로는 별도 필드가 필요
          Icons.computer,
          AdminTheme.secondaryTextColor,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String label,
    String? value,
    IconData icon,
    Color iconColor, {
    bool isWide = false,
    TextEditingController? controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(AdminTheme.spacingM),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AdminTheme.radiusM),
        border: Border.all(color: AdminTheme.borderColor),
      ),
      child: Column(
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
          if (controller != null)
            TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 14,
                color: AdminTheme.primaryTextColor,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AdminTheme.radiusS),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AdminTheme.spacingS,
                  vertical: AdminTheme.spacingXS,
                ),
                isDense: true,
              ),
            )
          else
            Text(
              value ?? '-',
              style: TextStyle(
                fontSize: 14,
                color: AdminTheme.primaryTextColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: isWide ? 3 : 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case '골드':
        return const Color(0xFFFFD700); // 금색
      case '실버':
        return const Color(0xFFC0C0C0); // 은색
      case '브론즈':
        return const Color(0xFFCD7F32); // 동색
      default:
        return AdminTheme.secondaryColor;
    }
  }

  void _saveChanges() async {
    // 먼저 편집 모드 해제
    setState(() {
      _isEditing = false;
    });

    try {
      // VIP 등급이 변경되었을 때만 AWS 업데이트
      if (_selectedVipGrade != _originalVipGrade) {
        // 스낵바로 진행 상황 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('VIP 정보를 저장하는 중...'),
            duration: Duration(seconds: 1),
          ),
        );
        
        await _usersService.updateVipGrade(
          widget.user.id,
          widget.user.id, // userId와 profileId가 같다고 가정
          _selectedVipGrade,
        );
        
        setState(() {
          _originalVipGrade = _selectedVipGrade; // 새 등급을 원래 등급으로 설정
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('VIP 회원 정보가 수정되었습니다. (등급: $_selectedVipGrade)'),
            backgroundColor: AdminTheme.successColor,
          ),
        );
      }
      
      widget.onUpdate?.call();
    } catch (e) {
      setState(() {
        _isEditing = true; // 에러 시 편집 모드로 복원
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('VIP 정보 저장 실패: $e'),
            backgroundColor: AdminTheme.errorColor,
          ),
        );
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      // 원래 값으로 복원
      _nameController.text = widget.user.name;
      _phoneController.text = widget.user.phoneNumber;
      // VIP 등급도 원래대로 복원
      _selectedVipGrade = _originalVipGrade;
    });
  }
}