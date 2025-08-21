import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';
import '../../widgets/admin_data_table.dart';
import '../../widgets/excel_download_button.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/user_detail_card.dart';
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
  String? _selectedUserId; // 상세보기가 열린 사용자 ID

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(adminUsersProvider);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User detail view (if selected)
          if (_selectedUserId != null) ...[
            _buildUserDetailView(usersState),
            const SizedBox(height: AdminTheme.spacingL),
          ],
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
        SizedBox(
          height: _selectedUserId != null ? 400 : 600, // Reduced height when detail view is shown
          child: Card(
            child: Column(
              children: [
                // Table Header
                Padding(
                  padding: const EdgeInsets.all(AdminTheme.spacingL),
                  child: Row(
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
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                
                // Table
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AdminTheme.spacingL),
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
                ),
                
                // Pagination
                Padding(
                  padding: const EdgeInsets.all(AdminTheme.spacingL),
                  child: _buildPagination(usersState),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
        label: const Text('회원이름'),
        onSort: (index, ascending) => _onSort(index, ascending, 'name'),
      ),
      const DataColumn(
        label: Text('성별'),
      ),
      DataColumn(
        label: const Text('나이'),
        numeric: true,
        onSort: (index, ascending) => _onSort(index, ascending, 'age'),
      ),
      const DataColumn(
        label: Text('전화번호'),
      ),
      DataColumn(
        label: const Text('보유 포인트'),
        numeric: true,
      ),
      const DataColumn(
        label: Text('승인여부'),
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
        label: Text('상세보기'),
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
          DataCell(Text('${user.age}세')),
          DataCell(Text(user.phoneNumber)),
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${user.points.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} P',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AdminTheme.primaryColor,
                  ),
                ),
                Text(
                  '사용가능',
                  style: TextStyle(
                    fontSize: 10,
                    color: AdminTheme.successColor,
                  ),
                ),
              ],
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user.isPhoneVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AdminTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminTheme.successColor),
                    ),
                    child: Text(
                      '본인인증',
                      style: TextStyle(
                        color: AdminTheme.successColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (user.isJobVerified)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AdminTheme.infoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminTheme.infoColor),
                    ),
                    child: Text(
                      '직업인증',
                      style: TextStyle(
                        color: AdminTheme.infoColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (!user.isPhoneVerified && !user.isJobVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AdminTheme.warningColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminTheme.warningColor),
                    ),
                    child: Text(
                      '미인증',
                      style: TextStyle(
                        color: AdminTheme.warningColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
          DataCell(
            ElevatedButton(
              onPressed: () => _viewUserDetail(user),
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
    }).toList();
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

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isRecentlyActive(DateTime? lastLogin) {
    if (lastLogin == null) return false;
    return DateTime.now().difference(lastLogin).inMinutes < 5;
  }

  void _onSearchChanged(String value) {
    ref.read(adminUsersProvider.notifier).search(value);
  }

  void _applyFilters() {
    String? statusFilter;
    if (_selectedStatus != '전체') {
      switch (_selectedStatus) {
        case '활성':
          statusFilter = 'active';
          break;
        case '정지':
          statusFilter = 'suspended';
          break;
        case '탈퇴':
          statusFilter = 'deleted';
          break;
        default:
          statusFilter = null;
      }
    }

    ref.read(adminUsersProvider.notifier).applyFilters({
      'gender': _selectedGender == '전체' ? null : (_selectedGender == '남성' ? 'male' : 'female'),
      'isVip': _selectedVipStatus == '전체' ? null : (_selectedVipStatus == 'VIP' ? true : false),
      'location': _selectedRegion == '전체' ? null : _selectedRegion,
      'status': statusFilter,
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
    setState(() {
      _selectedUserId = _selectedUserId == user.id ? null : user.id;
    });
  }


  void _downloadExcel() {
    // TODO: Implement excel download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('엑셀 다운로드 시작')),
    );
  }

  Widget _buildUserDetailView(AdminUsersState usersState) {
    final selectedUser = usersState.users.firstWhere(
      (user) => user.id == _selectedUserId,
      orElse: () => usersState.users.first, // fallback
    );

    return UserDetailCard(
      user: selectedUser,
      onClose: () {
        setState(() {
          _selectedUserId = null;
        });
      },
    );
  }
}