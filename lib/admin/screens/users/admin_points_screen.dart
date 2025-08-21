import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';
import '../../widgets/excel_download_button.dart';
import '../../widgets/filter_bar.dart';
import '../../services/admin_points_service.dart';

/// 포인트 전환 관리 화면
class AdminPointsScreen extends ConsumerStatefulWidget {
  const AdminPointsScreen({super.key});

  @override
  ConsumerState<AdminPointsScreen> createState() => _AdminPointsScreenState();
}

class _AdminPointsScreenState extends ConsumerState<AdminPointsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AdminPointsService _pointsService = AdminPointsService();
  
  String _selectedStatus = '전체';
  String _selectedGender = '전체';
  
  List<Map<String, dynamic>> _pointRequests = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPointRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// AWS에서 포인트 전환 요청 데이터 로드
  Future<void> _loadPointRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _pointsService.getPointExchangeRequests(
        page: 1,
        pageSize: 1000,
        searchQuery: _searchController.text,
        filters: {
          'status': _selectedStatus,
          'gender': _selectedGender,
        },
      );

      setState(() {
        _pointRequests = result['requests'] as List<Map<String, dynamic>>;
        _statistics = result['statistics'] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
            Text('포인트 전환 데이터를 불러오는 중...'),
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
              onPressed: _loadPointRequests,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '포인트 전환 관리',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ExcelDownloadButton(
              onPressed: () => _downloadExcel(),
              text: '포인트 전환 엑셀 다운로드',
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Statistics Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '전체 신청건',
                value: '${_statistics['totalRequests'] ?? 0}건',
                color: AdminTheme.primaryColor,
                icon: Icons.receipt_long,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '처리 대기',
                value: '${_statistics['pendingRequests'] ?? 0}건',
                color: AdminTheme.warningColor,
                icon: Icons.schedule,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '처리 완료',
                value: '${_statistics['completedRequests'] ?? 0}건',
                color: AdminTheme.successColor,
                icon: Icons.check_circle,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '총 전환 금액',
                value: '${(_statistics['totalConversionAmount'] ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                color: AdminTheme.infoColor,
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
          onSearchChanged: (value) => _loadPointRequests(),
          filters: [
            FilterItem(
              label: '처리상태',
              value: _selectedStatus,
              items: const ['전체', '처리대기', '검토중', '처리완료', '처리거절'],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                _loadPointRequests();
              },
            ),
            FilterItem(
              label: '성별',
              value: _selectedGender,
              items: const ['전체', '남성', '여성'],
              onChanged: (value) {
                setState(() => _selectedGender = value);
                _loadPointRequests();
              },
            ),
          ],
          onDateRangeChanged: (start, end) {
            // Date range filtering will be implemented later
            _loadPointRequests();
          },
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Point Conversion Table
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
                        '포인트 전환 신청 목록 (총 ${_pointRequests.length}건)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminTheme.spacingL),
                  Expanded(
                    child: _buildPointRequestsTable(),
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

  Widget _buildPointRequestsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: DataTable(
          columnSpacing: 16,
          horizontalMargin: 12,
          columns: const [
            DataColumn(
              label: SizedBox(
                width: 120,
                child: Text('회원이름', overflow: TextOverflow.ellipsis),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 60,
                child: Text('나이', overflow: TextOverflow.ellipsis),
              ),
              numeric: true,
            ),
            DataColumn(
              label: SizedBox(
                width: 140,
                child: Text('전화번호', overflow: TextOverflow.ellipsis),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 120,
                child: Text('접속IP', overflow: TextOverflow.ellipsis),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 100,
                child: Text('신청포인트', overflow: TextOverflow.ellipsis),
              ),
              numeric: true,
            ),
            DataColumn(
              label: SizedBox(
                width: 100,
                child: Text('신청일', overflow: TextOverflow.ellipsis),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 100,
                child: Text('전환금액', overflow: TextOverflow.ellipsis),
              ),
              numeric: true,
            ),
            DataColumn(
              label: SizedBox(
                width: 80,
                child: Text('상태', overflow: TextOverflow.ellipsis),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 140,
                child: Text('액션', overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          rows: _pointRequests.map((request) => _buildPointRequestRow(request)).toList(),
        ),
      ),
    );
  }

  DataRow _buildPointRequestRow(Map<String, dynamic> request) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 120,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: request['profileImage'] != null
                      ? NetworkImage(request['profileImage'])
                      : null,
                  child: request['profileImage'] == null
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request['name'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 60,
            child: Text(
              '${request['age']}세',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 140,
            child: Text(
              request['phoneNumber'],
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 120,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AdminTheme.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AdminTheme.infoColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                request['ipAddress'],
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${request['requestedPoints'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} P',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AdminTheme.primaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '포인트',
                  style: TextStyle(
                    fontSize: 10,
                    color: AdminTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatDate(request['requestDate']),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatTime(request['requestDate']),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AdminTheme.secondaryTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${request['conversionAmount'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AdminTheme.successColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '전환금액',
                  style: TextStyle(
                    fontSize: 10,
                    color: AdminTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 80,
            child: _buildStatusChip(request['status']),
          ),
        ),
        DataCell(
          SizedBox(
            width: 140,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (request['status'] == '처리대기' || request['status'] == '검토중')
                  ElevatedButton(
                    onPressed: () => _processRequest(request['id'], request['userId'], request['name'], '승인'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.successColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '승인',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                if (request['status'] == '처리대기' || request['status'] == '검토중') ...[
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () => _processRequest(request['id'], request['userId'], request['name'], '거절'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.errorColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '거절',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
                if (request['status'] == '처리완료') ...[
                  ElevatedButton(
                    onPressed: () => _viewDetails(request['id'], request['name']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '상세보기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    Color bgColor;
    
    switch (status) {
      case '처리완료':
        color = AdminTheme.successColor;
        bgColor = AdminTheme.successColor.withValues(alpha: 0.1);
        break;
      case '처리대기':
        color = AdminTheme.warningColor;
        bgColor = AdminTheme.warningColor.withValues(alpha: 0.1);
        break;
      case '검토중':
        color = AdminTheme.infoColor;
        bgColor = AdminTheme.infoColor.withValues(alpha: 0.1);
        break;
      case '처리거절':
        color = AdminTheme.errorColor;
        bgColor = AdminTheme.errorColor.withValues(alpha: 0.1);
        break;
      default:
        color = AdminTheme.secondaryTextColor;
        bgColor = AdminTheme.secondaryTextColor.withValues(alpha: 0.1);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _processRequest(String requestId, String userId, String userName, String action) async {
    try {
      bool success = false;
      
      if (action == '승인') {
        success = await _pointsService.approveRequest(requestId, userId);
      } else if (action == '거절') {
        success = await _pointsService.rejectRequest(requestId, '관리자 거절');
      }
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$userName 포인트 전환 요청 $action 처리 완료'),
              backgroundColor: AdminTheme.successColor,
            ),
          );
          _loadPointRequests(); // 데이터 새로고침
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$userName 포인트 전환 요청 $action 처리 실패'),
              backgroundColor: AdminTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('처리 중 오류가 발생했습니다: $e'),
            backgroundColor: AdminTheme.errorColor,
          ),
        );
      }
    }
  }

  void _viewDetails(String requestId, String userName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$userName (ID: $requestId) 포인트 전환 상세보기')),
    );
  }

  void _downloadExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('포인트 전환 엑셀 다운로드 시작')),
    );
  }
}