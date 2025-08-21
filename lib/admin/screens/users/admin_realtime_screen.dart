import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/admin_theme.dart';
import '../../widgets/excel_download_button.dart';
import '../../widgets/filter_bar.dart';
import '../../services/admin_realtime_service.dart';

/// 실시간 접속 현황 화면
class AdminRealtimeScreen extends ConsumerStatefulWidget {
  const AdminRealtimeScreen({super.key});

  @override
  ConsumerState<AdminRealtimeScreen> createState() => _AdminRealtimeScreenState();
}

class _AdminRealtimeScreenState extends ConsumerState<AdminRealtimeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AdminRealtimeService _realtimeService = AdminRealtimeService();
  
  String _selectedStatus = '전체';
  
  List<Map<String, dynamic>> _onlineUsers = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  String? _error;
  bool _autoRefreshEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadRealtimeData();
    if (_autoRefreshEnabled) {
      _realtimeService.startAutoRefresh(_loadRealtimeData);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _realtimeService.dispose();
    super.dispose();
  }

  /// AWS에서 실시간 접속 데이터 로드
  Future<void> _loadRealtimeData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _realtimeService.getRealtimeConnections(
        page: 1,
        pageSize: 100,
        searchQuery: _searchController.text,
        statusFilter: _selectedStatus,
      );

      if (mounted) {
        setState(() {
          _onlineUsers = result['users'] as List<Map<String, dynamic>>;
          _statistics = result['statistics'] as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
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
            Text('실시간 접속 데이터를 불러오는 중...'),
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
              onPressed: _loadRealtimeData,
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
            Row(
              children: [
                Text(
                  '실시간 접속 현황',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _autoRefreshEnabled 
                        ? AdminTheme.successColor.withValues(alpha: 0.1)
                        : AdminTheme.secondaryTextColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _autoRefreshEnabled 
                          ? AdminTheme.successColor
                          : AdminTheme.secondaryTextColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _autoRefreshEnabled ? Icons.autorenew : Icons.pause,
                        size: 16,
                        color: _autoRefreshEnabled 
                            ? AdminTheme.successColor
                            : AdminTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _autoRefreshEnabled ? '자동 새로고침' : '일시정지',
                        style: TextStyle(
                          fontSize: 12,
                          color: _autoRefreshEnabled 
                              ? AdminTheme.successColor
                              : AdminTheme.secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _autoRefreshEnabled = !_autoRefreshEnabled;
                    });
                    if (_autoRefreshEnabled) {
                      _realtimeService.startAutoRefresh(_loadRealtimeData);
                    } else {
                      _realtimeService.stopAutoRefresh();
                    }
                  },
                  icon: Icon(_autoRefreshEnabled ? Icons.pause : Icons.play_arrow),
                  tooltip: _autoRefreshEnabled ? '자동 새로고침 중지' : '자동 새로고침 시작',
                ),
                IconButton(
                  onPressed: _loadRealtimeData,
                  icon: const Icon(Icons.refresh),
                  tooltip: '수동 새로고침',
                ),
                const SizedBox(width: 8),
                ExcelDownloadButton(
                  onPressed: () => _downloadExcel(),
                  text: '접속 현황 엑셀 다운로드',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Statistics Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '총 회원수',
                value: '${_statistics['totalUsers'] ?? 0}명',
                color: AdminTheme.primaryColor,
                icon: Icons.people,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '현재 접속',
                value: '${_statistics['onlineUsers'] ?? 0}명',
                color: AdminTheme.successColor,
                icon: Icons.online_prediction,
                subtitle: '접속률: ${_statistics['onlineRate'] ?? '0.0'}%',
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: 'VIP 접속',
                value: '${_statistics['vipOnlineUsers'] ?? 0}명',
                color: const Color(0xFFFFD700),
                icon: Icons.star,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '24시간 활성',
                value: '${_statistics['activeInLast24h'] ?? 0}명',
                color: AdminTheme.infoColor,
                icon: Icons.schedule,
              ),
            ),
            const SizedBox(width: AdminTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                title: '신규 가입',
                value: '${_statistics['todayNewUsers'] ?? 0}명',
                color: AdminTheme.warningColor,
                icon: Icons.person_add,
                subtitle: '오늘',
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Filter Bar
        FilterBar(
          searchController: _searchController,
          searchHint: '회원명, 전화번호, ID 검색',
          onSearchChanged: (value) => _loadRealtimeData(),
          filters: [
            FilterItem(
              label: '접속상태',
              value: _selectedStatus,
              items: const ['전체', '온라인', '오프라인', 'VIP', '일반'],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                _loadRealtimeData();
              },
            ),
          ],
        ),
        const SizedBox(height: AdminTheme.spacingL),
        
        // Real-time Users Table
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
                        '실시간 접속 현황 (총 ${_onlineUsers.length}명)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '마지막 업데이트: ${_formatCurrentTime()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminTheme.spacingL),
                  Expanded(
                    child: _buildRealtimeUsersTable(),
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
    String? subtitle,
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
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: AdminTheme.secondaryTextColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRealtimeUsersTable() {
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
                child: Text('회원정보', overflow: TextOverflow.ellipsis),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 80,
                child: Text('상태', overflow: TextOverflow.ellipsis),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 120,
                child: Text('접속정보', overflow: TextOverflow.ellipsis),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 100,
                child: Text('위치', overflow: TextOverflow.ellipsis),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 120,
                child: Text('디바이스', overflow: TextOverflow.ellipsis),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 120,
                child: Text('IP주소', overflow: TextOverflow.ellipsis),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 100,
                child: Text('액션', overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          rows: _onlineUsers.map((user) => _buildUserRow(user)).toList(),
        ),
      ),
    );
  }

  DataRow _buildUserRow(Map<String, dynamic> user) {
    return DataRow(
      cells: [
        // 회원정보
        DataCell(
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: user['profileImage'] != null
                          ? NetworkImage(user['profileImage'])
                          : null,
                      child: user['profileImage'] == null
                          ? const Icon(Icons.person, size: 18)
                          : null,
                    ),
                    if (user['isVip'] == true)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD700),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${user['age']}세 · ${user['gender'] == 'male' ? '남' : '여'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AdminTheme.secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 상태
        DataCell(
          SizedBox(
            width: 80,
            child: _buildStatusBadge(user['isOnline']),
          ),
        ),
        
        // 접속정보
        DataCell(
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (user['isOnline'])
                  Text(
                    user['connectionDuration'] ?? '접속중',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AdminTheme.successColor,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    '마지막: ${user['lastSeenDisplay'] ?? '알 수 없음'}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AdminTheme.secondaryTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  user['phoneNumber'] ?? '',
                  style: TextStyle(
                    fontSize: 10,
                    color: AdminTheme.secondaryTextColor,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        
        // 위치
        DataCell(
          SizedBox(
            width: 100,
            child: Text(
              user['location'] ?? '-',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        
        // 디바이스
        DataCell(
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Icon(
                  _getDeviceIcon(user['deviceType']),
                  size: 16,
                  color: AdminTheme.primaryColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    user['deviceType'] ?? 'Unknown',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // IP주소
        DataCell(
          SizedBox(
            width: 120,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AdminTheme.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user['ipAddress'] ?? '-',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        
        // 액션
        DataCell(
          SizedBox(
            width: 100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user['isOnline'])
                  ElevatedButton(
                    onPressed: () => _forceLogout(user['userId'], user['name']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.errorColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline 
            ? AdminTheme.successColor.withValues(alpha: 0.1)
            : AdminTheme.secondaryTextColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline 
              ? AdminTheme.successColor
              : AdminTheme.secondaryTextColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOnline ? AdminTheme.successColor : AdminTheme.secondaryTextColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? '온라인' : '오프라인',
            style: TextStyle(
              color: isOnline ? AdminTheme.successColor : AdminTheme.secondaryTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String? deviceType) {
    switch (deviceType) {
      case 'iOS':
        return Icons.phone_iphone;
      case 'Android':
        return Icons.phone_android;
      case 'Web':
        return Icons.web;
      default:
        return Icons.device_unknown;
    }
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  void _forceLogout(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('강제 로그아웃'),
        content: Text('$userName 사용자를 강제로 로그아웃시키겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await _realtimeService.forceLogout(userId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$userName 사용자가 강제 로그아웃되었습니다.'),
              backgroundColor: AdminTheme.successColor,
            ),
          );
          _loadRealtimeData(); // 데이터 새로고침
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$userName 사용자 로그아웃에 실패했습니다.'),
              backgroundColor: AdminTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 처리 중 오류가 발생했습니다: $e'),
            backgroundColor: AdminTheme.errorColor,
          ),
        );
      }
    }
  }

  void _downloadExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('실시간 접속 현황 엑셀 다운로드 시작')),
    );
  }
}