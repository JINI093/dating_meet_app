import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';
import '../../models/admin_user.dart';

/// 관리자 관리 화면
class AdminAdminsScreen extends ConsumerStatefulWidget {
  const AdminAdminsScreen({super.key});

  @override
  ConsumerState<AdminAdminsScreen> createState() => _AdminAdminsScreenState();
}

class _AdminAdminsScreenState extends ConsumerState<AdminAdminsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = '전체';
  String _selectedStatus = '전체';
  final List<Map<String, dynamic>> _adminUsers = [];

  @override
  void initState() {
    super.initState();
    _generateAdminUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _generateAdminUsers() {
    _adminUsers.addAll([
      {
        'id': 'admin_1',
        'name': '김관리자',
        'username': 'admin_kim',
        'phoneNumber': '+82-10-1111-2222',
        'role': AdminRole.superAdmin,
        'isActive': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 365)),
        'lastLoginAt': DateTime.now().subtract(const Duration(minutes: 30)),
        'profileImage': null,
      },
      {
        'id': 'admin_2',
        'name': '이사용자',
        'username': 'user_manager_lee',
        'phoneNumber': '+82-10-3333-4444',
        'role': AdminRole.userManager,
        'isActive': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 200)),
        'lastLoginAt': DateTime.now().subtract(const Duration(hours: 2)),
        'profileImage': null,
      },
      {
        'id': 'admin_3',
        'name': '박콘텐츠',
        'username': 'content_park',
        'phoneNumber': '+82-10-5555-6666',
        'role': AdminRole.contentManager,
        'isActive': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 150)),
        'lastLoginAt': DateTime.now().subtract(const Duration(days: 1)),
        'profileImage': null,
      },
      {
        'id': 'admin_4',
        'name': '정결제자',
        'username': 'finance_jung',
        'phoneNumber': '+82-10-7777-8888',
        'role': AdminRole.financeManager,
        'isActive': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 100)),
        'lastLoginAt': DateTime.now().subtract(const Duration(days: 7)),
        'profileImage': null,
      },
      {
        'id': 'admin_5',
        'name': '최분석가',
        'username': 'analyst_choi',
        'phoneNumber': '+82-10-9999-0000',
        'role': AdminRole.analyst,
        'isActive': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 50)),
        'lastLoginAt': DateTime.now().subtract(const Duration(hours: 6)),
        'profileImage': null,
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '관리자 관리',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddAdminDialog,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                '관리자 추가',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminTheme.spacingL,
                  vertical: AdminTheme.spacingM,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Statistics Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '전체 관리자',
                value: '${_adminUsers.length}명',
                color: AdminTheme.primaryColor,
                icon: Icons.admin_panel_settings,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '활성 관리자',
                value: '${_adminUsers.where((a) => a['isActive']).length}명',
                color: AdminTheme.successColor,
                icon: Icons.check_circle,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '비활성 관리자',
                value: '${_adminUsers.where((a) => !a['isActive']).length}명',
                color: AdminTheme.warningColor,
                icon: Icons.pause_circle,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '최고 관리자',
                value: '${_adminUsers.where((a) => a['role'] == AdminRole.superAdmin).length}명',
                color: AdminTheme.infoColor,
                icon: Icons.security,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Search and Filter Bar
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AdminTheme.spacingL),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '관리자명, ID, 전화번호 검색',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: AdminTheme.spacingM),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: '관리자 등급',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      '전체',
                      '최고 관리자',
                      '회원 관리자',
                      '콘텐츠 관리자',
                      '결제 관리자',
                      '고객지원 관리자',
                      '분석가',
                      '열람자'
                    ].map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedRole = value!);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: AdminTheme.spacingM),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: '활성 상태',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['전체', '활성', '비활성'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedStatus = value!);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Admin Table
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminTheme.spacingL),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '관리자 목록 (총 ${_adminUsers.length}명)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminTheme.spacingL),
                  Expanded(
                    child: _buildAdminTable(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

  Widget _buildAdminTable() {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('관리자이름')),
          DataColumn(label: Text('관리자ID')),
          DataColumn(label: Text('전화번호')),
          DataColumn(label: Text('관리자 등급')),
          DataColumn(label: Text('활성 상태')),
          DataColumn(label: Text('가입일')),
          DataColumn(label: Text('마지막 접속')),
          DataColumn(label: Text('액션')),
        ],
        rows: _adminUsers.map((admin) => _buildAdminRow(admin)).toList(),
      ),
    );
  }

  DataRow _buildAdminRow(Map<String, dynamic> admin) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: admin['profileImage'] != null
                    ? NetworkImage(admin['profileImage'])
                    : null,
                child: admin['profileImage'] == null
                    ? const Icon(Icons.admin_panel_settings, size: 16)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                admin['name'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        DataCell(Text(admin['username'])),
        DataCell(Text(admin['phoneNumber'])),
        DataCell(_buildRoleToggle(admin)),
        DataCell(_buildStatusSwitch(admin)),
        DataCell(Text(_formatDate(admin['createdAt']))),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_formatDate(admin['lastLoginAt'])),
              if (_isRecentlyActive(admin['lastLoginAt']))
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AdminTheme.successColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '온라인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _editAdmin(admin),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '수정',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: admin['role'] != AdminRole.superAdmin
                    ? () => _deleteAdmin(admin)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.errorColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '삭제',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleToggle(Map<String, dynamic> admin) {
    final role = admin['role'] as AdminRole;
    final roleDisplayName = role.displayName;
    
    Color roleColor;
    switch (role) {
      case AdminRole.superAdmin:
        roleColor = AdminTheme.errorColor;
        break;
      case AdminRole.userManager:
      case AdminRole.financeManager:
        roleColor = AdminTheme.warningColor;
        break;
      case AdminRole.contentManager:
      case AdminRole.supportManager:
        roleColor = AdminTheme.infoColor;
        break;
      default:
        roleColor = AdminTheme.secondaryColor;
    }
    
    return PopupMenuButton<AdminRole>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: roleColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: roleColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              roleDisplayName,
              style: TextStyle(
                color: roleColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: roleColor,
              size: 16,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => AdminRole.values.map((newRole) {
        return PopupMenuItem(
          value: newRole,
          child: Text(newRole.displayName),
        );
      }).toList(),
      onSelected: (newRole) {
        if (admin['role'] != AdminRole.superAdmin || newRole == AdminRole.superAdmin) {
          _updateAdminRole(admin, newRole);
        }
      },
    );
  }

  Widget _buildStatusSwitch(Map<String, dynamic> admin) {
    return Switch(
      value: admin['isActive'],
      activeColor: AdminTheme.successColor,
      onChanged: admin['role'] != AdminRole.superAdmin
          ? (value) {
              setState(() {
                admin['isActive'] = value;
              });
              _updateAdminStatus(admin, value);
            }
          : null,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isRecentlyActive(DateTime? lastLogin) {
    if (lastLogin == null) return false;
    return DateTime.now().difference(lastLogin).inMinutes < 5;
  }

  void _onSearchChanged(String value) {
    // TODO: Implement search functionality
  }

  void _applyFilters() {
    // TODO: Implement filter functionality
  }

  void _updateAdminRole(Map<String, dynamic> admin, AdminRole newRole) {
    setState(() {
      admin['role'] = newRole;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${admin['name']} 관리자 등급이 ${newRole.displayName}(으)로 변경되었습니다')),
    );
  }

  void _updateAdminStatus(Map<String, dynamic> admin, bool isActive) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${admin['name']} 관리자가 ${isActive ? '활성화' : '비활성화'}되었습니다')),
    );
  }

  void _editAdmin(Map<String, dynamic> admin) {
    _showEditAdminDialog(admin);
  }

  void _deleteAdmin(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('관리자 삭제'),
        content: Text('${admin['name']} 관리자를 정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _adminUsers.remove(admin);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${admin['name']} 관리자가 삭제되었습니다')),
              );
            },
            child: Text(
              '삭제',
              style: TextStyle(color: AdminTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAdminDialog() {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final phoneController = TextEditingController();
    AdminRole selectedRole = AdminRole.viewer;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('관리자 추가'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '관리자 이름',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AdminTheme.spacingM),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: '관리자 ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AdminTheme.spacingM),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AdminTheme.spacingM),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<AdminRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: '관리자 등급',
                    border: OutlineInputBorder(),
                  ),
                  items: AdminRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedRole = value!);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  usernameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                Navigator.pop(context);
                _addNewAdmin(
                  nameController.text,
                  usernameController.text,
                  phoneController.text,
                  selectedRole,
                );
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showEditAdminDialog(Map<String, dynamic> admin) {
    final nameController = TextEditingController(text: admin['name']);
    final usernameController = TextEditingController(text: admin['username']);
    final phoneController = TextEditingController(text: admin['phoneNumber']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('관리자 정보 수정'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '관리자 이름',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AdminTheme.spacingM),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: '관리자 ID',
                  border: OutlineInputBorder(),
                ),
                enabled: false, // ID는 수정 불가
              ),
              const SizedBox(height: AdminTheme.spacingM),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateAdmin(admin, nameController.text, phoneController.text);
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }

  void _addNewAdmin(String name, String username, String phone, AdminRole role) {
    setState(() {
      _adminUsers.add({
        'id': 'admin_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'username': username,
        'phoneNumber': phone,
        'role': role,
        'isActive': true,
        'createdAt': DateTime.now(),
        'lastLoginAt': null,
        'profileImage': null,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name 관리자가 추가되었습니다')),
    );
  }

  void _updateAdmin(Map<String, dynamic> admin, String name, String phone) {
    setState(() {
      admin['name'] = name;
      admin['phoneNumber'] = phone;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${admin['name']} 관리자 정보가 수정되었습니다')),
    );
  }
}