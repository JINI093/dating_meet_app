import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';
import '../../widgets/admin_data_table.dart';
import '../../widgets/excel_download_button.dart';
import '../../widgets/filter_bar.dart';
import '../../models/user_model.dart';
import '../../providers/users_provider.dart';

/// 회원정보 관리 화면
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGender = '전체';
  String _selectedVipStatus = '전체';
  String _selectedRegion = '전체';
  String _selectedStatus = '전체';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(adminUsersProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '회원정보',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ExcelDownloadButton(
              onPressed: () => _downloadExcel(),
              text: '엑셀 다운로드',
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Filter Bar
        FilterBar(
          searchController: _searchController,
          searchHint: '이름, 전화번호, 이메일 검색',
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
              label: 'VIP 상태',
              value: _selectedVipStatus,
              items: const ['전체', 'VIP', '일반'],
              onChanged: (value) {
                setState(() => _selectedVipStatus = value);
                _applyFilters();
              },
            ),
            FilterItem(
              label: '지역',
              value: _selectedRegion,
              items: const ['전체', '서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산', '세종'],
              onChanged: (value) {
                setState(() => _selectedRegion = value);
                _applyFilters();
              },
            ),
            FilterItem(
              label: '계정 상태',
              value: _selectedStatus,
              items: const ['전체', '활성', '정지', '탈퇴'],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
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
        
        // Data Table
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AdminTheme.spacingL),
              child: Column(
                children: [
                  // Table Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '총 ${usersState.totalCount}명',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (usersState.selectedUsers.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              '${usersState.selectedUsers.length}명 선택됨',
                              style: const TextStyle(
                                color: AdminTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AdminTheme.spacingM),
                            PopupMenuButton<String>(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AdminTheme.spacingM,
                                  vertical: AdminTheme.spacingS,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AdminTheme.primaryColor),
                                  borderRadius: BorderRadius.circular(AdminTheme.radiusM),
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      '일괄 작업',
                                      style: TextStyle(color: AdminTheme.primaryColor),
                                    ),
                                    SizedBox(width: AdminTheme.spacingS),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: AdminTheme.primaryColor,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'vip',
                                  child: Text('VIP 부여'),
                                ),
                                const PopupMenuItem(
                                  value: 'suspend',
                                  child: Text('계정 정지'),
                                ),
                                const PopupMenuItem(
                                  value: 'activate',
                                  child: Text('계정 활성화'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('계정 삭제'),
                                ),
                              ],
                              onSelected: _onBulkAction,
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: AdminTheme.spacingM),
                  
                  // Table
                  Expanded(
                    child: AdminDataTable(
                      columns: _buildColumns(),
                      rows: _buildRows(usersState.users),
                      isLoading: usersState.isLoading,
                      onSelectAll: (selected) {
                        ref.read(adminUsersProvider.notifier).toggleSelectAll(selected ?? false);
                      },
                      sortColumnIndex: usersState.sortColumnIndex,
                      sortAscending: usersState.sortAscending,
                    ),
                  ),
                  
                  // Pagination
                  const SizedBox(height: AdminTheme.spacingM),
                  _buildPagination(usersState),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
        label: const Text('회원번호'),
        onSort: (index, ascending) => _onSort(index, ascending, 'id'),
      ),
      const DataColumn(
        label: Text('프로필'),
      ),
      DataColumn(
        label: const Text('이름/나이/성별'),
        onSort: (index, ascending) => _onSort(index, ascending, 'name'),
      ),
      const DataColumn(
        label: Text('전화번호'),
      ),
      const DataColumn(
        label: Text('이메일'),
      ),
      DataColumn(
        label: const Text('가입일'),
        onSort: (index, ascending) => _onSort(index, ascending, 'createdAt'),
      ),
      DataColumn(
        label: const Text('마지막 접속'),
        onSort: (index, ascending) => _onSort(index, ascending, 'lastLoginAt'),
      ),
      const DataColumn(
        label: Text('지역'),
      ),
      const DataColumn(
        label: Text('VIP'),
      ),
      const DataColumn(
        label: Text('인증'),
      ),
      DataColumn(
        label: const Text('활동점수'),
        numeric: true,
        onSort: (index, ascending) => _onSort(index, ascending, 'activityScore'),
      ),
      const DataColumn(
        label: Text('상태'),
      ),
      const DataColumn(
        label: Text('관리'),
      ),
    ];
  }

  List<DataRow> _buildRows(List<UserModel> users) {
    return users.map((user) {
      final isSelected = ref.read(adminUsersProvider).selectedUsers.contains(user.id);
      
      return DataRow(
        selected: isSelected,
        onSelectChanged: (selected) {
          ref.read(adminUsersProvider.notifier).toggleSelectUser(user.id);
        },
        cells: [
          DataCell(Text(user.id)),
          DataCell(
            CircleAvatar(
              radius: 16,
              backgroundImage: user.profileImage != null
                  ? NetworkImage(user.profileImage!)
                  : null,
              child: user.profileImage == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
          ),
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${user.age}세 / ${user.gender}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AdminTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          DataCell(Text(user.phoneNumber)),
          DataCell(Text(user.email)),
          DataCell(Text(_formatDate(user.createdAt))),
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_formatDate(user.lastLoginAt)),
                if (_isRecentlyActive(user.lastLoginAt))
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
          DataCell(Text(user.location)),
          DataCell(
            user.isVip
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AdminTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'VIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const Text('-'),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user.isPhoneVerified)
                  Tooltip(
                    message: '본인인증',
                    child: Icon(
                      Icons.verified_user,
                      size: 16,
                      color: AdminTheme.successColor,
                    ),
                  ),
                if (user.isJobVerified)
                  Tooltip(
                    message: '직업인증',
                    child: Icon(
                      Icons.work,
                      size: 16,
                      color: AdminTheme.infoColor,
                    ),
                  ),
                if (user.isPhotoVerified)
                  Tooltip(
                    message: '사진인증',
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: AdminTheme.warningColor,
                    ),
                  ),
              ],
            ),
          ),
          DataCell(Text('${user.activityScore}')),
          DataCell(
            _buildStatusChip(user.status),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  onPressed: () => _viewUserDetail(user),
                  tooltip: '상세보기',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _editUser(user),
                  tooltip: '수정',
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildStatusChip(UserStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case UserStatus.active:
        color = AdminTheme.successColor;
        text = '활성';
        break;
      case UserStatus.suspended:
        color = AdminTheme.warningColor;
        text = '정지';
        break;
      case UserStatus.deleted:
        color = AdminTheme.errorColor;
        text = '탈퇴';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPagination(AdminUsersState state) {
    final totalPages = (state.totalCount / state.pageSize).ceil();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('페이지당 표시: '),
            DropdownButton<int>(
              value: state.pageSize,
              items: [10, 20, 50, 100].map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text('$size'),
                );
              }).toList(),
              onChanged: (size) {
                if (size != null) {
                  ref.read(adminUsersProvider.notifier).setPageSize(size);
                }
              },
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: state.currentPage > 1
                  ? () => ref.read(adminUsersProvider.notifier).goToPage(1)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: state.currentPage > 1
                  ? () => ref.read(adminUsersProvider.notifier).previousPage()
                  : null,
            ),
            Text('${state.currentPage} / $totalPages'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: state.currentPage < totalPages
                  ? () => ref.read(adminUsersProvider.notifier).nextPage()
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: state.currentPage < totalPages
                  ? () => ref.read(adminUsersProvider.notifier).goToPage(totalPages)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isRecentlyActive(DateTime lastLogin) {
    return DateTime.now().difference(lastLogin).inMinutes < 5;
  }

  void _onSearchChanged(String value) {
    ref.read(adminUsersProvider.notifier).search(value);
  }

  void _applyFilters() {
    ref.read(adminUsersProvider.notifier).applyFilters({
      'gender': _selectedGender,
      'vipStatus': _selectedVipStatus,
      'region': _selectedRegion,
      'status': _selectedStatus,
      'startDate': _startDate,
      'endDate': _endDate,
    });
  }

  void _onSort(int columnIndex, bool ascending, String field) {
    ref.read(adminUsersProvider.notifier).sort(columnIndex, ascending, field);
  }

  void _onBulkAction(String action) {
    // TODO: Implement bulk action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('일괄 작업: $action')),
    );
  }

  void _viewUserDetail(UserModel user) {
    // TODO: Navigate to user detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.name} 상세보기')),
    );
  }

  void _editUser(UserModel user) {
    // TODO: Navigate to user edit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.name} 수정')),
    );
  }

  void _downloadExcel() {
    // TODO: Implement excel download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('엑셀 다운로드 시작')),
    );
  }
}