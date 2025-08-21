import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../models/notice_model.dart';
import '../../config/api_config.dart' as app_api_config;
import '../../utils/logger.dart';

/// 관리자 공지사항 서비스
class AdminNoticeService {
  final Dio _dio = Dio();
  static const _uuid = Uuid();

  AdminNoticeService() {
    _dio.options = BaseOptions(
      baseUrl: '${app_api_config.ApiConfig.baseUrl}/admin',
      connectTimeout: const Duration(seconds: 5),  // 더 빠른 타임아웃
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  /// 공지사항 목록 조회
  Future<Map<String, dynamic>> getNotices({
    int page = 1,
    int pageSize = 20,
    NoticeTargetType? targetType,
    NoticeStatus? status,
    String searchQuery = '',
    String? sortField,
    bool sortAscending = true,
  }) async {
    try {
      Logger.log('📋 공지사항 목록 조회 시작 (시뮬레이션 모드)', name: 'AdminNoticeService');
      
      // AWS DynamoDB 테이블은 준비되었으나, 현재는 시뮬레이션 데이터 사용
      Logger.log('📊 시뮬레이션 공지사항 데이터 사용 (AWS 준비 완료)', name: 'AdminNoticeService');
      return _getSimulationNotices(
        page: page,
        pageSize: pageSize,
        targetType: targetType,
        status: status,
        searchQuery: searchQuery,
        sortField: sortField,
        sortAscending: sortAscending,
      );

    } catch (e) {
      Logger.error('공지사항 목록 조회 실패: $e', name: 'AdminNoticeService');
      throw Exception('공지사항 목록 조회 실패: $e');
    }
  }

  /// 공지사항 상세 조회
  Future<NoticeModel> getNotice(String noticeId) async {
    try {
      Logger.log('📄 공지사항 상세 조회: $noticeId (시뮬레이션)', name: 'AdminNoticeService');

      // 시뮬레이션 데이터에서 검색
      final simulationData = _getSimulationNotices();
      final notices = simulationData['notices'] as List<NoticeModel>;
      
      NoticeModel? notice;
      try {
        notice = notices.firstWhere((n) => n.id == noticeId);
      } catch (e) {
        throw Exception('공지사항을 찾을 수 없습니다');
      }

      return notice;
    } catch (e) {
      Logger.error('공지사항 상세 조회 실패: $e', name: 'AdminNoticeService');
      throw Exception('공지사항 상세 조회 실패: $e');
    }
  }

  /// 공지사항 생성
  Future<NoticeModel> createNotice(NoticeCreateUpdateDto dto) async {
    try {
      Logger.log('✏️ 공지사항 생성 시작 (시뮬레이션)', name: 'AdminNoticeService');

      // 시뮬레이션 데이터 생성
      Logger.log('📝 시뮬레이션 공지사항 생성', name: 'AdminNoticeService');
      final now = DateTime.now();
      final notice = NoticeModel(
        id: _uuid.v4(),
        title: dto.title,
        content: dto.content,
        targetType: dto.targetType,
        status: dto.status,
        createdAt: now,
        updatedAt: now,
        publishedAt: dto.status == NoticeStatus.published ? now : null,
        scheduledAt: dto.scheduledAt,
        authorId: 'admin-001',
        authorName: '관리자',
        viewCount: 0,
        isPinned: dto.isPinned,
        isImportant: dto.isImportant,
        tags: dto.tags,
        metadata: dto.metadata,
      );

      // TODO: 실제 AWS DynamoDB에 저장 (준비 완료)
      Logger.log('📊 시뮬레이션 생성 완료: ${notice.id}', name: 'AdminNoticeService');
      
      return notice;
    } catch (e) {
      Logger.error('공지사항 생성 실패: $e', name: 'AdminNoticeService');
      throw Exception('공지사항 생성 실패: $e');
    }
  }

  /// 공지사항 수정
  Future<NoticeModel> updateNotice(String noticeId, NoticeCreateUpdateDto dto) async {
    try {
      Logger.log('✏️ 공지사항 수정 시작: $noticeId (시뮬레이션)', name: 'AdminNoticeService');

      // 기존 공지사항 조회 후 수정된 내용으로 업데이트
      final existingNotice = await getNotice(noticeId);
      final updatedNotice = existingNotice.copyWith(
        title: dto.title,
        content: dto.content,
        targetType: dto.targetType,
        status: dto.status,
        updatedAt: DateTime.now(),
        publishedAt: dto.status == NoticeStatus.published && !existingNotice.isPublished 
            ? DateTime.now() 
            : existingNotice.publishedAt,
        scheduledAt: dto.scheduledAt,
        isPinned: dto.isPinned,
        isImportant: dto.isImportant,
        tags: dto.tags,
        metadata: dto.metadata,
      );

      // TODO: 실제 AWS DynamoDB에 업데이트 (준비 완료)
      Logger.log('📊 시뮬레이션 수정 완료: $noticeId', name: 'AdminNoticeService');

      return updatedNotice;
    } catch (e) {
      Logger.error('공지사항 수정 실패: $e', name: 'AdminNoticeService');
      throw Exception('공지사항 수정 실패: $e');
    }
  }

  /// 공지사항 삭제
  Future<void> deleteNotice(String noticeId) async {
    try {
      Logger.log('🗑️ 공지사항 삭제 시작: $noticeId (시뮬레이션)', name: 'AdminNoticeService');

      // TODO: 실제 AWS DynamoDB에서 삭제 (준비 완료)
      
      // 시뮬레이션에서는 성공으로 간주
      Logger.log('✅ 시뮬레이션 공지사항 삭제 완료', name: 'AdminNoticeService');
      
    } catch (e) {
      Logger.error('공지사항 삭제 실패: $e', name: 'AdminNoticeService');
      throw Exception('공지사항 삭제 실패: $e');
    }
  }

  /// 공지사항 상태 변경 (게시/게시중단)
  Future<NoticeModel> updateNoticeStatus(String noticeId, NoticeStatus status) async {
    try {
      Logger.log('🔄 공지사항 상태 변경: $noticeId -> ${status.name} (시뮬레이션)', name: 'AdminNoticeService');

      // 기존 공지사항 조회 후 상태만 변경
      final existingNotice = await getNotice(noticeId);
      final updatedNotice = existingNotice.copyWith(
        status: status,
        updatedAt: DateTime.now(),
        publishedAt: status == NoticeStatus.published && !existingNotice.isPublished 
            ? DateTime.now() 
            : existingNotice.publishedAt,
      );

      // TODO: 실제 AWS DynamoDB에 상태 업데이트 (준비 완료)
      Logger.log('📊 시뮬레이션 상태 변경 완료: $noticeId', name: 'AdminNoticeService');

      return updatedNotice;
    } catch (e) {
      Logger.error('공지사항 상태 변경 실패: $e', name: 'AdminNoticeService');
      throw Exception('공지사항 상태 변경 실패: $e');
    }
  }

  /// 시뮬레이션 공지사항 데이터 생성
  Map<String, dynamic> _getSimulationNotices({
    int page = 1,
    int pageSize = 20,
    NoticeTargetType? targetType,
    NoticeStatus? status,
    String searchQuery = '',
    String? sortField,
    bool sortAscending = true,
  }) {
    final now = DateTime.now();
    
    List<NoticeModel> notices = [
      NoticeModel(
        id: 'notice_001',
        title: '서비스 이용약관 변경 안내',
        content: '안녕하세요. 더 나은 서비스 제공을 위해 이용약관이 일부 변경됩니다.\n\n주요 변경사항:\n1. 개인정보 처리방침 업데이트\n2. 서비스 이용 규칙 명확화\n3. 환불 정책 개선\n\n변경된 약관은 2024년 1월 1일부터 적용됩니다.',
        targetType: NoticeTargetType.all,
        status: NoticeStatus.published,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        publishedAt: now.subtract(const Duration(days: 2)),
        authorId: 'admin_001',
        authorName: '운영팀',
        viewCount: 1205,
        isPinned: true,
        isImportant: true,
        tags: ['약관', '정책'],
      ),
      NoticeModel(
        id: 'notice_002',
        title: '남성회원 프로필 사진 가이드라인',
        content: '매력적인 프로필 작성을 위한 사진 가이드라인을 안내드립니다.\n\n권장 사항:\n• 밝고 선명한 사진\n• 자연스러운 표정\n• 전신 사진 1장 이상 포함\n\n금지 사항:\n• 과도한 보정\n• 타인과 함께 찍은 사진\n• 부적절한 내용',
        targetType: NoticeTargetType.male,
        status: NoticeStatus.published,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
        publishedAt: now.subtract(const Duration(days: 5)),
        authorId: 'admin_002',
        authorName: '컨텐츠팀',
        viewCount: 892,
        isPinned: false,
        isImportant: false,
        tags: ['프로필', '사진', '가이드'],
      ),
      NoticeModel(
        id: 'notice_003',
        title: '여성회원 안전 가이드',
        content: '안전한 만남을 위한 가이드를 안내드립니다.\n\n만남 전:\n• 공개된 장소에서 만나기\n• 지인에게 만남 일정 공유\n• 개인정보 과도한 공개 금지\n\n만남 중:\n• 직감을 믿고 행동\n• 불편하면 즉시 자리 이석\n• 24시간 고객센터 이용 가능\n\n문제 상황시 신고 기능을 적극 이용해주세요.',
        targetType: NoticeTargetType.female,
        status: NoticeStatus.published,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
        publishedAt: now.subtract(const Duration(days: 7)),
        authorId: 'admin_003',
        authorName: '안전팀',
        viewCount: 1456,
        isPinned: true,
        isImportant: true,
        tags: ['안전', '가이드', '신고'],
      ),
      NoticeModel(
        id: 'notice_004',
        title: 'VIP 회원 혜택 업데이트',
        content: 'VIP 회원님들을 위한 새로운 혜택이 추가되었습니다!\n\n신규 혜택:\n• 무제한 슈퍼라이크 (기존 월 10개 → 무제한)\n• 프리미엄 매칭 알고리즘 적용\n• 전용 고객센터 우선 연결\n• 오프라인 이벤트 우선 초대\n\n기존 VIP 회원님께는 자동으로 적용됩니다.',
        targetType: NoticeTargetType.vip,
        status: NoticeStatus.published,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        publishedAt: now.subtract(const Duration(days: 1)),
        authorId: 'admin_004',
        authorName: 'VIP팀',
        viewCount: 234,
        isPinned: false,
        isImportant: true,
        tags: ['VIP', '혜택', '업데이트'],
      ),
      NoticeModel(
        id: 'notice_005',
        title: '시스템 점검 안내',
        content: '더 안정적인 서비스 제공을 위한 시스템 점검을 실시합니다.\n\n점검 일시: 2024년 1월 15일(월) 오전 2:00 ~ 6:00\n점검 내용:\n• 서버 성능 최적화\n• 보안 업데이트\n• 새 기능 배포 준비\n\n점검 시간 중에는 서비스 이용이 제한될 수 있습니다.\n이용에 불편을 드려 죄송합니다.',
        targetType: NoticeTargetType.all,
        status: NoticeStatus.scheduled,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        scheduledAt: DateTime(2024, 1, 10, 9, 0),
        authorId: 'admin_005',
        authorName: '개발팀',
        viewCount: 0,
        isPinned: false,
        isImportant: false,
        tags: ['점검', '시스템'],
      ),
    ];

    // 필터링 적용
    if (targetType != null) {
      notices = notices.where((n) => n.targetType == targetType).toList();
    }
    if (status != null) {
      notices = notices.where((n) => n.status == status).toList();
    }
    if (searchQuery.isNotEmpty) {
      notices = notices.where((n) => 
        n.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        n.content.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    // 정렬 적용
    if (sortField != null) {
      notices.sort((a, b) {
        int comparison = 0;
        switch (sortField) {
          case 'createdAt':
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
          case 'updatedAt':
            comparison = a.updatedAt.compareTo(b.updatedAt);
            break;
          case 'viewCount':
            comparison = a.viewCount.compareTo(b.viewCount);
            break;
          case 'title':
            comparison = a.title.compareTo(b.title);
            break;
          default:
            // 우선순위 정렬 (고정 > 중요 > 일반, 그 다음 최신순)
            comparison = b.displayPriority.compareTo(a.displayPriority);
            if (comparison == 0) {
              comparison = b.createdAt.compareTo(a.createdAt);
            }
        }
        return sortAscending ? comparison : -comparison;
      });
    } else {
      // 기본 정렬: 우선순위 > 최신순
      notices.sort((a, b) {
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
    final pagedNotices = notices.length > startIndex 
        ? notices.sublist(startIndex, endIndex > notices.length ? notices.length : endIndex)
        : <NoticeModel>[];

    return {
      'notices': pagedNotices,
      'totalCount': notices.length,
      'totalPages': (notices.length / pageSize).ceil(),
    };
  }
}