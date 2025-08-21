import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';
import '../../widgets/excel_download_button.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/vip_detail_card.dart';
import '../../services/admin_users_service.dart';
import '../../models/user_model.dart';

/// VIP 회원 관리 화면
class AdminVipScreen extends ConsumerStatefulWidget {
  const AdminVipScreen({super.key});

  @override
  ConsumerState<AdminVipScreen> createState() => _AdminVipScreenState();
}

class _AdminVipScreenState extends ConsumerState<AdminVipScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AdminUsersService _usersService = AdminUsersService();
  
  String _selectedGender = '전체';
  String _selectedVipType = '전체';
  DateTime? _startDate;
  DateTime? _endDate;
  
  List<UserModel> _vipUsers = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedUserId; // 상세보기가 열린 사용자 ID

  @override
  void initState() {
    super.initState();
    _loadVipUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// AWS에서 VIP 회원 데이터 로드
  Future<void> _loadVipUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // VIP 필터를 적용해서 사용자 데이터 가져오기
      final result = await _usersService.getUsers(
        page: 1,
        pageSize: 1000, // 모든 VIP 회원 가져오기
        searchQuery: '',
        filters: {'isVip': true}, // VIP 회원만 필터링
      );

      setState(() {
        _vipUsers = result['users'] as List<UserModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 평균 포인트 계산
  int _calculateAveragePoints() {
    if (_vipUsers.isEmpty) return 0;
    final totalPoints = _vipUsers.fold<int>(0, (sum, user) => sum + user.points);
    return (totalPoints / _vipUsers.length).round();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('VIP 회원 데이터를 불러오는 중...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: AdminTheme.errorColor),
            const SizedBox(height: 16),
            Text('데이터 로드 실패: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVipUsers,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User detail view (if selected)
          if (_selectedUserId != null) ...[ 
            _buildVipDetailView(),
            const SizedBox(height: AdminTheme.spacingL),
          ],
          // Page Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'VIP 회원 관리',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ExcelDownloadButton(
              onPressed: () => _downloadExcel(),
              text: 'VIP 회원 엑셀 다운로드',
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Statistics Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '전체 VIP 회원',
                value: '${_vipUsers.length}명',
                color: AdminTheme.secondaryColor,
                icon: Icons.star,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '골드 VIP',
                value: '${_vipUsers.where((u) => u.vipGrade == '골드').length}명',
                color: const Color(0xFFFFD700),
                icon: Icons.star,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '실버 VIP',
                value: '${_vipUsers.where((u) => u.vipGrade == '실버').length}명',
                color: const Color(0xFFC0C0C0),
                icon: Icons.star_half,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '브론즈 VIP',
                value: '${_vipUsers.where((u) => u.vipGrade == '브론즈').length}명',
                color: const Color(0xFFCD7F32),
                icon: Icons.star_outline,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '평균 포인트',
                value: '${_calculateAveragePoints()}P',
                color: AdminTheme.successColor,
                icon: Icons.monetization_on,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Filter Bar
        FilterBar(
          searchController: _searchController,
          searchHint: '회원명, 전화번호 검색',
          onSearchChanged: _onSearchChanged,
          filters: [
            FilterItem(
              label: '성별',
              value: _selectedGender,
              items: const ['전체', '남성', '여성'],
              onChanged: (value) {
                setState(() => _selectedGender = value);
                _applyFilters();
              },
            ),
            FilterItem(
              label: 'VIP 등급',
              value: _selectedVipType,
              items: const ['전체', '골드 VIP', '실버 VIP', '브론즈 VIP'],
              onChanged: (value) {
                setState(() => _selectedVipType = value);
                _applyFilters();
              },
            ),
          ],
          onDateRangeChanged: (start, end) {
            setState(() {
              _startDate = start;
              _endDate = end;
            });
            _applyFilters();
          },
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // VIP Users Table
        SizedBox(
          height: _selectedUserId != null ? 400 : 600, // 상세보기가 열리면 높이 조정
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminTheme.spacingL),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'VIP 회원 목록 (총 ${_vipUsers.length}명)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminTheme.spacingL),
                  Expanded(
                    child: _buildVipUsersTable(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AdminTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminTheme.spacingS),
            Text(
              title,
              style: const TextStyle(
                color: AdminTheme.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVipUsersTable() {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('회원이름')),
          DataColumn(label: Text('성별')),
          DataColumn(label: Text('전화번호')),
          DataColumn(label: Text('VIP 구매일')),
          DataColumn(label: Text('VIP 남은기간')),
          DataColumn(label: Text('VIP 종류')),
          DataColumn(label: Text('상세보기')),
        ],
        rows: _vipUsers.map((user) => _buildVipUserRow(user)).toList(),
      ),
    );
  }

  DataRow _buildVipUserRow(UserModel user) {
    // VIP 회원이므로 가입일부터 30일간 VIP라고 가정 (실제로는 VIP 만료일 필드가 있어야 함)
    final vipExpiryDate = user.createdAt.add(const Duration(days: 30));
    final daysRemaining = vipExpiryDate.difference(DateTime.now()).inDays;
    
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.gender == 'male' 
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.pink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: user.gender == 'male' ? Colors.blue : Colors.pink,
              ),
            ),
            child: Text(
              user.gender == 'male' ? '남성' : '여성',
              style: TextStyle(
                color: user.gender == 'male' ? Colors.blue : Colors.pink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(Text(user.phoneNumber)),
        DataCell(Text(_formatDate(user.createdAt))), // VIP 구매일 대신 가입일 사용
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$daysRemaining일',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: daysRemaining > 30
                      ? AdminTheme.successColor
                      : daysRemaining > 7
                          ? AdminTheme.warningColor
                          : AdminTheme.errorColor,
                ),
              ),
              Text(
                '만료: ${_formatDate(vipExpiryDate)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AdminTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getUserGradeColor(user).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getUserGradeColor(user)),
            ),
            child: Text(
              _getUserGrade(user),
              style: TextStyle(
                color: _getUserGradeColor(user),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          ElevatedButton(
            onPressed: () => _viewUserDetail(user.name),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              '상세보기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _onSearchChanged(String value) {
    _loadVipUsers(); // 실제로는 검색어를 포함해서 다시 로드
  }

  void _applyFilters() {
    _loadVipUsers(); // 실제로는 필터를 포함해서 다시 로드
  }

  void _viewUserDetail(String userName) {
    final user = _vipUsers.firstWhere((u) => u.name == userName);
    setState(() {
      _selectedUserId = _selectedUserId == user.id ? null : user.id;
    });
  }

  Widget _buildVipDetailView() {
    final selectedUser = _vipUsers.firstWhere(
      (user) => user.id == _selectedUserId,
      orElse: () => _vipUsers.first, // fallback
    );

    return VipDetailCard(
      user: selectedUser,
      onClose: () {
        setState(() {
          _selectedUserId = null;
        });
      },
      onUpdate: () {
        _loadVipUsers(); // 데이터 새로고침
      },
    );
  }

  void _downloadExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('VIP 회원 엑셀 다운로드 시작')),
    );
  }

  Color _getGradeColor(int points) {
    if (points >= 3000) {
      return const Color(0xFFFFD700); // 금색
    } else if (points >= 1000) {
      return const Color(0xFFC0C0C0); // 은색
    } else {
      return const Color(0xFFCD7F32); // 동색
    }
  }

  String _getGradeText(int points) {
    if (points >= 3000) {
      return '골드 VIP';
    } else if (points >= 1000) {
      return '실버 VIP';
    } else {
      return '브론즈 VIP';
    }
  }

  String _getUserGrade(UserModel user) {
    // vipGrade가 있으면 그것을 사용, 없으면 포인트 기반 계산
    if (user.vipGrade != null && user.vipGrade!.isNotEmpty) {
      return '${user.vipGrade} VIP';
    }
    return _getGradeText(user.points);
  }

  Color _getUserGradeColor(UserModel user) {
    // vipGrade가 있으면 그것을 사용, 없으면 포인트 기반 계산
    if (user.vipGrade != null && user.vipGrade!.isNotEmpty) {
      switch (user.vipGrade) {
        case '골드':
          return const Color(0xFFFFD700);
        case '실버':
          return const Color(0xFFC0C0C0);
        case '브론즈':
          return const Color(0xFFCD7F32);
      }
    }
    return _getGradeColor(user.points);
  }
}