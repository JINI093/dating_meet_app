import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../models/report_model.dart';
import '../../config/api_config.dart' as app_api_config;
import '../../utils/logger.dart';

/// 관리자 신고 관리 서비스 (시뮬레이션 버전)
class AdminReportService {
  final Dio _dio = Dio();
  static const _uuid = Uuid();

  AdminReportService() {
    _dio.options = BaseOptions(
      baseUrl: '${app_api_config.ApiConfig.baseUrl}/admin',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  /// 신고 목록 조회
  Future<Map<String, dynamic>> getReports({
    int page = 1,
    int pageSize = 20,
    ReportType? reportType,
    ReportStatus? status,
    ReportPriority? priority,
    String searchQuery = '',
    String? sortField,
    bool sortAscending = true,
  }) async {
    try {
      Logger.log('📋 신고 목록 조회 시작 (시뮬레이션 모드)', name: 'AdminReportService');
      
      // 시뮬레이션 데이터 사용
      Logger.log('📊 시뮬레이션 신고 데이터 사용', name: 'AdminReportService');
      return _getSimulationReports(
        page: page,
        pageSize: pageSize,
        reportType: reportType,
        status: status,
        priority: priority,
        searchQuery: searchQuery,
        sortField: sortField,
        sortAscending: sortAscending,
      );

    } catch (e) {
      Logger.error('신고 목록 조회 실패: $e', name: 'AdminReportService');
      throw Exception('신고 목록 조회 실패: $e');
    }
  }

  /// 신고 상세 조회
  Future<ReportModel> getReport(String reportId) async {
    try {
      Logger.log('📄 신고 상세 조회: $reportId (시뮬레이션)', name: 'AdminReportService');

      // 시뮬레이션 데이터에서 검색
      final simulationData = _getSimulationReports();
      final reports = simulationData['reports'] as List<ReportModel>;
      
      ReportModel? report;
      try {
        report = reports.firstWhere((r) => r.id == reportId);
      } catch (e) {
        throw Exception('신고를 찾을 수 없습니다');
      }

      return report;
    } catch (e) {
      Logger.error('신고 상세 조회 실패: $e', name: 'AdminReportService');
      throw Exception('신고 상세 조회 실패: $e');
    }
  }

  /// 신고 처리
  Future<ReportModel> processReport(String reportId, ReportProcessDto dto) async {
    try {
      Logger.log('✏️ 신고 처리 시작: $reportId (시뮬레이션)', name: 'AdminReportService');

      // 기존 신고 조회 후 처리 정보로 업데이트
      final existingReport = await getReport(reportId);
      final processedReport = existingReport.copyWith(
        status: dto.status,
        action: dto.action,
        adminNotes: dto.adminNotes,
        processedBy: dto.processedBy,
        processedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Logger.log('📊 시뮬레이션 신고 처리 완료: $reportId', name: 'AdminReportService');

      return processedReport;
    } catch (e) {
      Logger.error('신고 처리 실패: $e', name: 'AdminReportService');
      throw Exception('신고 처리 실패: $e');
    }
  }

  /// 신고 상태 변경
  Future<ReportModel> updateReportStatus(String reportId, ReportStatus status) async {
    try {
      Logger.log('🔄 신고 상태 변경: $reportId -> ${status.name} (시뮬레이션)', name: 'AdminReportService');

      // 기존 신고 조회 후 상태만 변경
      final existingReport = await getReport(reportId);
      final updatedReport = existingReport.copyWith(
        status: status,
        updatedAt: DateTime.now(),
        processedAt: status.name != 'pending' ? DateTime.now() : null,
      );

      Logger.log('📊 시뮬레이션 상태 변경 완료: $reportId', name: 'AdminReportService');

      return updatedReport;
    } catch (e) {
      Logger.error('신고 상태 변경 실패: $e', name: 'AdminReportService');
      throw Exception('신고 상태 변경 실패: $e');
    }
  }

  /// 시뮬레이션 신고 데이터 생성
  Map<String, dynamic> _getSimulationReports({
    int page = 1,
    int pageSize = 20,
    ReportType? reportType,
    ReportStatus? status,
    ReportPriority? priority,
    String searchQuery = '',
    String? sortField,
    bool sortAscending = true,
  }) {
    final now = DateTime.now();
    
    List<ReportModel> reports = [
      ReportModel(
        id: 'report_001',
        reporterUserId: 'user_001',
        reporterName: '신고자A',
        reportedUserId: 'user_101',
        reportedName: '피신고자B',
        reportType: ReportType.inappropriateContent,
        reportReason: '부적절한 프로필 사진',
        reportContent: '해당 사용자가 부적절한 프로필 사진을 사용하고 있습니다. 성적인 내용이 포함되어 있어 신고합니다.',
        evidence: ['image1.jpg', 'screenshot.png'],
        status: ReportStatus.pending,
        priority: ReportPriority.high,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      ReportModel(
        id: 'report_002',
        reporterUserId: 'user_002',
        reporterName: '신고자C',
        reportedUserId: 'user_102',
        reportedName: '피신고자D',
        reportType: ReportType.harassment,
        reportReason: '지속적인 괴롭힘',
        reportContent: '해당 사용자가 지속적으로 불쾌한 메시지를 보내고 있습니다. 차단했음에도 불구하고 계속해서 연락을 시도합니다.',
        evidence: ['chat_log.txt'],
        status: ReportStatus.inProgress,
        priority: ReportPriority.urgent,
        adminNotes: '확인중입니다.',
        processedBy: 'admin_001',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      ReportModel(
        id: 'report_003',
        reporterUserId: 'user_003',
        reporterName: '신고자E',
        reportedUserId: 'user_103',
        reportedName: '피신고자F',
        reportType: ReportType.fakeProfile,
        reportReason: '가짜 프로필 사용',
        reportContent: '해당 사용자가 유명인의 사진을 도용하여 프로필을 만들었습니다. 실제 본인이 아닌 것이 확실합니다.',
        evidence: ['original_photo.jpg', 'comparison.jpg'],
        status: ReportStatus.resolved,
        priority: ReportPriority.high,
        action: ReportAction.suspendedPermanent,
        adminNotes: '가짜 프로필 확인 후 계정 정지 처리',
        processedBy: 'admin_002',
        processedAt: now.subtract(const Duration(hours: 8)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),
      ReportModel(
        id: 'report_004',
        reporterUserId: 'user_004',
        reporterName: '신고자G',
        reportedUserId: 'user_104',
        reportedName: '피신고자H',
        reportType: ReportType.spam,
        reportReason: '스팸 메시지 발송',
        reportContent: '해당 사용자가 광고성 메시지를 계속 보내고 있습니다. 상업적 목적의 메시지로 추정됩니다.',
        evidence: ['spam_messages.txt'],
        status: ReportStatus.pending,
        priority: ReportPriority.normal,
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      ReportModel(
        id: 'report_005',
        reporterUserId: 'user_005',
        reporterName: '신고자I',
        reportedUserId: 'user_105',
        reportedName: '피신고자J',
        reportType: ReportType.scam,
        reportReason: '금전 요구',
        reportContent: '해당 사용자가 만남을 핑계로 금전을 요구하고 있습니다. 사기 의심됩니다.',
        evidence: ['conversation.png'],
        status: ReportStatus.rejected,
        priority: ReportPriority.high,
        action: ReportAction.rejected,
        adminNotes: '증거 불충분으로 반려',
        processedBy: 'admin_001',
        processedAt: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ReportModel(
        id: 'report_006',
        reporterUserId: 'user_006',
        reporterName: '신고자K',
        reportedUserId: 'user_106',
        reportedName: '피신고자L',
        reportType: ReportType.underage,
        reportReason: '미성년자 의심',
        reportContent: '해당 사용자가 미성년자인 것 같습니다. 나이를 속이고 있는 것으로 보입니다.',
        evidence: ['profile_analysis.pdf'],
        status: ReportStatus.inProgress,
        priority: ReportPriority.urgent,
        adminNotes: '신분 확인 요청함',
        processedBy: 'admin_003',
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];

    // 필터링 적용
    if (reportType != null) {
      reports = reports.where((r) => r.reportType == reportType).toList();
    }
    if (status != null) {
      reports = reports.where((r) => r.status == status).toList();
    }
    if (priority != null) {
      reports = reports.where((r) => r.priority == priority).toList();
    }
    if (searchQuery.isNotEmpty) {
      reports = reports.where((r) => 
        r.reporterName.toLowerCase().contains(searchQuery.toLowerCase()) ||
        r.reportedName.toLowerCase().contains(searchQuery.toLowerCase()) ||
        r.reportContent.toLowerCase().contains(searchQuery.toLowerCase()) ||
        r.reportReason.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    // 정렬 적용
    if (sortField != null) {
      reports.sort((a, b) {
        int comparison = 0;
        switch (sortField) {
          case 'createdAt':
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
          case 'updatedAt':
            comparison = a.updatedAt.compareTo(b.updatedAt);
            break;
          case 'reporterName':
            comparison = a.reporterName.compareTo(b.reporterName);
            break;
          case 'reportedName':
            comparison = a.reportedName.compareTo(b.reportedName);
            break;
          case 'priority':
            comparison = a.displayPriority.compareTo(b.displayPriority);
            break;
          default:
            // 기본 정렬: 우선순위 > 최신순
            comparison = b.displayPriority.compareTo(a.displayPriority);
            if (comparison == 0) {
              comparison = b.createdAt.compareTo(a.createdAt);
            }
        }
        return sortAscending ? comparison : -comparison;
      });
    } else {
      // 기본 정렬: 우선순위 > 최신순
      reports.sort((a, b) {
        int comparison = b.displayPriority.compareTo(a.displayPriority);
        if (comparison == 0) {
          comparison = b.createdAt.compareTo(a.createdAt);
        }
        return comparison;
      });
    }

    // 페이징 적용
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    final pagedReports = reports.length > startIndex 
        ? reports.sublist(startIndex, endIndex > reports.length ? reports.length : endIndex)
        : <ReportModel>[];

    return {
      'reports': pagedReports,
      'totalCount': reports.length,
      'totalPages': (reports.length / pageSize).ceil(),
    };
  }
}