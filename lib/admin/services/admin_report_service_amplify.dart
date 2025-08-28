import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/report_model.dart';
import '../../utils/logger.dart';

/// 관리자 신고 관리 서비스 (AWS Amplify)
class AdminReportServiceAmplify {
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
      Logger.log('📋 신고 목록 조회 시작 (AWS)', name: 'AdminReportServiceAmplify');

      List<ReportModel> allReports = [];

      // AWS에서 데이터 조회 시도
      try {
        String nextToken = '';
        bool hasMoreData = true;

        // 전체 신고 데이터를 가져오기 (필터링을 위해)
        do {
          const graphQLDocument = '''
            query ListReports(\$limit: Int, \$nextToken: String) {
              listReports(limit: \$limit, nextToken: \$nextToken) {
                items {
                  id
                  reporterUserId
                  reporterName
                  reportedUserId
                  reportedName
                  reportType
                  reportReason
                  reportContent
                  evidence
                  status
                  priority
                  adminNotes
                  processedBy
                  processedAt
                  createdAt
                  updatedAt
                }
                nextToken
              }
            }
          ''';

          final request = GraphQLRequest<String>(
            document: graphQLDocument,
            variables: {
              'limit': 100, // 한 번에 많은 데이터 가져오기
              if (nextToken.isNotEmpty) 'nextToken': nextToken,
            },
          );

          final response = await Amplify.API.query(request: request).response;

          if (response.hasErrors) {
            Logger.error('신고 목록 조회 에러: ${response.errors}', name: 'AdminReportServiceAmplify');
            throw Exception('신고 목록 조회 실패: ${response.errors.first.message}');
          }

          final data = response.data;
          if (data != null) {
            final jsonResponse = json.decode(data);
            final reports = jsonResponse['listReports']['items'] as List;
            
            for (final reportJson in reports) {
              try {
                final report = _parseReportFromGraphQL(reportJson);
                allReports.add(report);
              } catch (e) {
                Logger.error('신고 파싱 에러: $e', name: 'AdminReportServiceAmplify');
              }
            }

            nextToken = jsonResponse['listReports']['nextToken'] ?? '';
            hasMoreData = nextToken.isNotEmpty;
          } else {
            hasMoreData = false;
          }
        } while (hasMoreData);

        Logger.log('📊 총 ${allReports.length}개 신고 가져옴 (AWS)', name: 'AdminReportServiceAmplify');
      } catch (e) {
        // AWS 연결 실패 시 빈 리스트 반환 (권한 에러 포함)
        Logger.log('AWS 연결 실패, 빈 데이터 반환: $e', name: 'AdminReportServiceAmplify');
        allReports = [];
      }

      // 필터링 적용
      List<ReportModel> filteredReports = allReports;

      if (reportType != null) {
        filteredReports = filteredReports.where((r) => r.reportType == reportType).toList();
      }
      if (status != null) {
        filteredReports = filteredReports.where((r) => r.status == status).toList();
      }
      if (priority != null) {
        filteredReports = filteredReports.where((r) => r.priority == priority).toList();
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filteredReports = filteredReports.where((r) => 
          r.reporterName.toLowerCase().contains(query) ||
          r.reportedName.toLowerCase().contains(query) ||
          r.reportContent.toLowerCase().contains(query) ||
          r.reportReason.toLowerCase().contains(query)
        ).toList();
      }

      // 정렬 적용
      if (sortField != null) {
        filteredReports.sort((a, b) {
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
        filteredReports.sort((a, b) {
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
      final pagedReports = filteredReports.length > startIndex 
          ? filteredReports.sublist(startIndex, endIndex > filteredReports.length ? filteredReports.length : endIndex)
          : <ReportModel>[];

      return {
        'reports': pagedReports,
        'totalCount': filteredReports.length,
        'totalPages': (filteredReports.length / pageSize).ceil(),
      };
    } catch (e) {
      Logger.error('신고 목록 조회 실패: $e', name: 'AdminReportServiceAmplify');
      throw Exception('신고 목록 조회 실패: $e');
    }
  }

  /// 신고 상세 조회
  Future<ReportModel> getReport(String reportId) async {
    try {
      Logger.log('📄 신고 상세 조회: $reportId (AWS)', name: 'AdminReportServiceAmplify');

      const graphQLDocument = '''
        query GetReport(\$id: ID!) {
          getReport(id: \$id) {
            id
            reporterUserId
            reporterName
            reportedUserId
            reportedName
            reportType
            reportReason
            reportContent
            evidence
            status
            priority
            adminNotes
            processedBy
            processedAt
            createdAt
            updatedAt
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {'id': reportId},
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.hasErrors) {
        Logger.error('신고 상세 조회 에러: ${response.errors}', name: 'AdminReportServiceAmplify');
        throw Exception('신고 상세 조회 실패: ${response.errors.first.message}');
      }

      final data = response.data;
      if (data != null) {
        final jsonResponse = json.decode(data);
        final reportJson = jsonResponse['getReport'];
        
        if (reportJson == null) {
          throw Exception('신고를 찾을 수 없습니다');
        }

        return _parseReportFromGraphQL(reportJson);
      } else {
        throw Exception('신고를 찾을 수 없습니다');
      }
    } catch (e) {
      Logger.error('신고 상세 조회 실패: $e', name: 'AdminReportServiceAmplify');
      throw Exception('신고 상세 조회 실패: $e');
    }
  }

  /// 신고 처리
  Future<ReportModel> processReport(String reportId, ReportProcessDto dto) async {
    try {
      Logger.log('✏️ 신고 처리 시작: $reportId (AWS)', name: 'AdminReportServiceAmplify');

      const graphQLDocument = '''
        mutation UpdateReport(\$input: UpdateReportInput!) {
          updateReport(input: \$input) {
            id
            reporterUserId
            reporterName
            reportedUserId
            reportedName
            reportType
            reportReason
            reportContent
            evidence
            status
            priority
            adminNotes
            processedBy
            processedAt
            createdAt
            updatedAt
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {
          'input': {
            'id': reportId,
            'status': dto.status.name,
            'adminNotes': dto.adminNotes,
            'processedBy': dto.processedBy,
            'processedAt': DateTime.now().toIso8601String(),
          },
        },
      );

      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        Logger.error('신고 처리 에러: ${response.errors}', name: 'AdminReportServiceAmplify');
        throw Exception('신고 처리 실패: ${response.errors.first.message}');
      }

      final data = response.data;
      if (data != null) {
        final jsonResponse = json.decode(data);
        final reportJson = jsonResponse['updateReport'];
        
        Logger.log('📊 신고 처리 완료: $reportId', name: 'AdminReportServiceAmplify');
        return _parseReportFromGraphQL(reportJson);
      } else {
        throw Exception('신고 처리 실패');
      }
    } catch (e) {
      Logger.error('신고 처리 실패: $e', name: 'AdminReportServiceAmplify');
      throw Exception('신고 처리 실패: $e');
    }
  }

  /// 신고 상태 변경
  Future<ReportModel> updateReportStatus(String reportId, ReportStatus status) async {
    try {
      Logger.log('🔄 신고 상태 변경: $reportId -> ${status.name} (AWS)', name: 'AdminReportServiceAmplify');

      const graphQLDocument = '''
        mutation UpdateReport(\$input: UpdateReportInput!) {
          updateReport(input: \$input) {
            id
            reporterUserId
            reporterName
            reportedUserId
            reportedName
            reportType
            reportReason
            reportContent
            evidence
            status
            priority
            adminNotes
            processedBy
            processedAt
            createdAt
            updatedAt
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {
          'input': {
            'id': reportId,
            'status': status.name,
            if (status != ReportStatus.pending) 'processedAt': DateTime.now().toIso8601String(),
          },
        },
      );

      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        Logger.error('신고 상태 변경 에러: ${response.errors}', name: 'AdminReportServiceAmplify');
        throw Exception('신고 상태 변경 실패: ${response.errors.first.message}');
      }

      final data = response.data;
      if (data != null) {
        final jsonResponse = json.decode(data);
        final reportJson = jsonResponse['updateReport'];
        
        Logger.log('📊 신고 상태 변경 완료: $reportId', name: 'AdminReportServiceAmplify');
        return _parseReportFromGraphQL(reportJson);
      } else {
        throw Exception('신고 상태 변경 실패');
      }
    } catch (e) {
      Logger.error('신고 상태 변경 실패: $e', name: 'AdminReportServiceAmplify');
      throw Exception('신고 상태 변경 실패: $e');
    }
  }

  /// GraphQL 응답을 ReportModel로 파싱
  ReportModel _parseReportFromGraphQL(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      reporterUserId: json['reporterUserId'] ?? '',
      reporterName: json['reporterName'] ?? '',
      reportedUserId: json['reportedUserId'] ?? '',
      reportedName: json['reportedName'] ?? '',
      reportType: ReportType.values.firstWhere(
        (type) => type.name == json['reportType'],
        orElse: () => ReportType.other,
      ),
      reportReason: json['reportReason'] ?? '',
      reportContent: json['reportContent'] ?? '',
      evidence: List<String>.from(json['evidence'] ?? []),
      status: ReportStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      priority: ReportPriority.values.firstWhere(
        (priority) => priority.name == json['priority'],
        orElse: () => ReportPriority.normal,
      ),
      adminNotes: json['adminNotes'],
      processedBy: json['processedBy'],
      processedAt: json['processedAt'] != null 
          ? DateTime.tryParse(json['processedAt'])
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// 신고 통계 조회
  Future<Map<String, int>> getReportStats() async {
    try {
      Logger.log('📊 신고 통계 조회 시작 (AWS)', name: 'AdminReportServiceAmplify');

      // 전체 신고 가져와서 통계 계산
      final result = await getReports(page: 1, pageSize: 1000); // 충분히 큰 수로 전체 가져오기
      final reports = result['reports'] as List<ReportModel>;

      final stats = {
        'total': reports.length,
        'pending': reports.where((r) => r.status == ReportStatus.pending).length,
        'inProgress': reports.where((r) => r.status == ReportStatus.inProgress).length,
        'resolved': reports.where((r) => r.status == ReportStatus.resolved).length,
        'rejected': reports.where((r) => r.status == ReportStatus.rejected).length,
        'urgent': reports.where((r) => r.priority == ReportPriority.urgent).length,
      };

      Logger.log('📊 신고 통계: $stats', name: 'AdminReportServiceAmplify');
      return stats;
    } catch (e) {
      Logger.log('신고 통계 조회 실패, 기본값 반환: $e', name: 'AdminReportServiceAmplify');
      // 실패 시 기본값 반환
      return {
        'total': 0,
        'pending': 0,
        'inProgress': 0,
        'resolved': 0,
        'rejected': 0,
        'urgent': 0,
      };
    }
  }
}