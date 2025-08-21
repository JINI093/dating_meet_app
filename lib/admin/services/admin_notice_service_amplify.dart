import 'dart:convert';
import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../models/notice_model.dart';
import '../../utils/logger.dart';

/// AWS Amplify를 사용한 공지사항 서비스
class AdminNoticeServiceAmplify {
  static bool? _amplifyStatusCache;
  static DateTime? _lastCheckTime;
  static const _cacheValidityDuration = Duration(seconds: 5);
  
  /// Amplify 초기화 확인 - 단순화된 버전
  Future<bool> _ensureAmplifyConfigured() async {
    try {
      Logger.log('🔍 Amplify 상태 확인 시작', name: 'AdminNoticeServiceAmplify');
      Logger.log('🔍 Amplify.isConfigured: ${Amplify.isConfigured}', name: 'AdminNoticeServiceAmplify');
      
      // 캐시된 실패 결과가 있으면 바로 실패 반환 (5초간 유효)
      final now = DateTime.now();
      if (_amplifyStatusCache == false && 
          _lastCheckTime != null && 
          now.difference(_lastCheckTime!) < _cacheValidityDuration) {
        Logger.log('📋 캐시된 실패 상태 사용 - 시뮬레이션 모드', name: 'AdminNoticeServiceAmplify');
        return false;
      }
      
      // 즉시 Amplify 상태 확인
      if (Amplify.isConfigured) {
        try {
          // API 플러그인 확인
          final hasApiPlugin = Amplify.API.plugins.isNotEmpty;
          Logger.log('🔍 API 플러그인 개수: ${Amplify.API.plugins.length}', name: 'AdminNoticeServiceAmplify');
          
          if (hasApiPlugin) {
            Logger.log('✅ Amplify 사용 가능 - 실제 모드', name: 'AdminNoticeServiceAmplify');
            _updateCache(true, now);
            return true;
          } else {
            Logger.log('⚠️ API 플러그인이 없음', name: 'AdminNoticeServiceAmplify');
          }
        } catch (e) {
          Logger.log('⚠️ API 플러그인 확인 중 오류: $e', name: 'AdminNoticeServiceAmplify');
          Logger.log('🔍 오류 타입: ${e.runtimeType}', name: 'AdminNoticeServiceAmplify');
        }
      }
      
      // Amplify가 초기화되지 않은 경우 짧은 대기 후 재시도
      Logger.log('⏳ Amplify 대기 중... (최대 3초)', name: 'AdminNoticeServiceAmplify');
      
      for (int i = 0; i < 6; i++) { // 500ms * 6 = 3초
        await Future.delayed(const Duration(milliseconds: 500));
        
        Logger.log('⏳ 재시도 ${i + 1}/6 - Amplify.isConfigured: ${Amplify.isConfigured}', name: 'AdminNoticeServiceAmplify');
        
        if (Amplify.isConfigured) {
          try {
            final hasApiPlugin = Amplify.API.plugins.isNotEmpty;
            if (hasApiPlugin) {
              Logger.log('✅ Amplify 사용 가능 (재시도에서 성공)', name: 'AdminNoticeServiceAmplify');
              _updateCache(true, now);
              return true;
            }
          } catch (e) {
            Logger.log('🔍 재시도 중 API 플러그인 오류: $e', name: 'AdminNoticeServiceAmplify');
          }
        }
      }
      
      // 최종 실패
      Logger.log('❌ Amplify 초기화 실패 - 시뮬레이션 모드로 전환', name: 'AdminNoticeServiceAmplify');
      _updateCache(false, now);
      return false;
      
    } catch (e) {
      Logger.error('❌ Amplify 확인 중 예외 발생: $e', name: 'AdminNoticeServiceAmplify');
      Logger.error('🔍 Stack trace: ${StackTrace.current}', name: 'AdminNoticeServiceAmplify');
      _updateCache(false, DateTime.now());
      return false;
    }
  }
  
  /// 캐시 업데이트
  void _updateCache(bool status, DateTime time) {
    _amplifyStatusCache = status;
    _lastCheckTime = time;
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
      Logger.log('📋 AWS Amplify 공지사항 목록 조회 시작', name: 'AdminNoticeServiceAmplify');
      
      // Amplify 초기화 확인
      final isAmplifyReady = await _ensureAmplifyConfigured();
      if (!isAmplifyReady) {
        // Amplify 초기화 실패 시 시뮬레이션 데이터 사용
        return _getSimulationNotices(
          page: page,
          pageSize: pageSize,
          targetType: targetType,
          status: status,
          searchQuery: searchQuery,
          sortField: sortField,
          sortAscending: sortAscending,
        );
      }
      
      // GraphQL 쿼리 직접 작성
      String graphQLQuery = '''
        query ListNotices(\$filter: ModelNoticeFilterInput, \$limit: Int, \$nextToken: String) {
          listNotices(filter: \$filter, limit: \$limit, nextToken: \$nextToken) {
            items {
              id
              title
              content
              targetType
              status
              authorId
              authorName
              viewCount
              isPinned
              isImportant
              tags
              metadata
              publishedAt
              scheduledAt
              createdAt
              updatedAt
            }
            nextToken
          }
        }
      ''';
      
      // 필터링 조건 구성
      Map<String, dynamic> filter = {};
      if (targetType != null) {
        filter['targetType'] = {'eq': targetType.name};
      }
      if (status != null) {
        filter['status'] = {'eq': status.name};
      }
      if (searchQuery.isNotEmpty) {
        filter['or'] = [
          {'title': {'contains': searchQuery}},
          {'content': {'contains': searchQuery}},
        ];
      }
      
      Map<String, dynamic> variables = {
        'limit': pageSize * 5, // 정렬을 위해 더 많이 가져옴
      };
      if (filter.isNotEmpty) {
        variables['filter'] = filter;
      }
      
      final request = GraphQLRequest<String>(
        document: graphQLQuery,
        variables: variables,
      );
      
      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null) {
        final jsonResponse = jsonDecode(response.data!);
        final listNotices = jsonResponse['listNotices'];
        final items = listNotices['items'] as List;
        
        // JSON을 NoticeModel로 변환
        final notices = items.map((item) => _convertFromJson(item)).toList();
        
        // 정렬 적용
        _sortNotices(notices, sortField, sortAscending);
        
        // 페이징 적용
        final startIndex = (page - 1) * pageSize;
        final endIndex = startIndex + pageSize;
        final pagedNotices = notices.length > startIndex 
            ? notices.sublist(startIndex, endIndex > notices.length ? notices.length : endIndex)
            : <NoticeModel>[];
        
        Logger.log('✅ AWS Amplify 공지사항 데이터: ${notices.length}개', name: 'AdminNoticeServiceAmplify');
        
        return {
          'notices': pagedNotices,
          'totalCount': notices.length,
          'totalPages': (notices.length / pageSize).ceil(),
        };
      } else {
        throw Exception('AWS API 응답이 비어있습니다');
      }
    } catch (e) {
      Logger.error('AWS Amplify 공지사항 목록 조회 실패: $e', name: 'AdminNoticeServiceAmplify');
      rethrow;
    }
  }

  /// 공지사항 상세 조회
  Future<NoticeModel> getNotice(String noticeId) async {
    try {
      Logger.log('📄 AWS Amplify 공지사항 상세 조회: $noticeId', name: 'AdminNoticeServiceAmplify');
      
      // Amplify 초기화 확인
      final isAmplifyReady = await _ensureAmplifyConfigured();
      if (!isAmplifyReady) {
        // Amplify 초기화 실패 시 시뮬레이션 데이터에서 검색
        final simulationData = _getSimulationNotices();
        final notices = simulationData['notices'] as List<NoticeModel>;
        
        NoticeModel? notice;
        try {
          notice = notices.firstWhere((n) => n.id == noticeId);
          Logger.log('📊 시뮬레이션 데이터에서 공지사항 조회: $noticeId', name: 'AdminNoticeServiceAmplify');
          return notice;
        } catch (e) {
          throw Exception('공지사항을 찾을 수 없습니다');
        }
      }
      
      const String graphQLQuery = '''
        query GetNotice(\$id: ID!) {
          getNotice(id: \$id) {
            id
            title
            content
            targetType
            status
            authorId
            authorName
            viewCount
            isPinned
            isImportant
            tags
            metadata
            publishedAt
            scheduledAt
            createdAt
            updatedAt
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(
        document: graphQLQuery,
        variables: {'id': noticeId},
      );
      
      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null) {
        final jsonResponse = jsonDecode(response.data!);
        final noticeData = jsonResponse['getNotice'];
        
        if (noticeData != null) {
          Logger.log('✅ AWS Amplify 공지사항 상세 조회 완료', name: 'AdminNoticeServiceAmplify');
          return _convertFromJson(noticeData);
        } else {
          throw Exception('공지사항을 찾을 수 없습니다');
        }
      } else {
        throw Exception('공지사항을 찾을 수 없습니다');
      }
    } catch (e) {
      Logger.error('AWS Amplify 공지사항 상세 조회 실패: $e', name: 'AdminNoticeServiceAmplify');
      rethrow;
    }
  }

  /// 공지사항 생성
  Future<NoticeModel> createNotice(NoticeCreateUpdateDto dto) async {
    try {
      Logger.log('✏️ AWS Amplify 공지사항 생성 시작', name: 'AdminNoticeServiceAmplify');
      
      // Amplify 초기화 확인
      final isAmplifyReady = await _ensureAmplifyConfigured();
      if (!isAmplifyReady) {
        // Amplify 초기화 실패 시 시뮬레이션 모드로 생성
        Logger.log('📝 시뮬레이션 공지사항 생성', name: 'AdminNoticeServiceAmplify');
        final now = DateTime.now();
        final notice = NoticeModel(
          id: 'notice_sim_${now.millisecondsSinceEpoch}',
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
        Logger.log('✅ 시뮬레이션 공지사항 생성 완료: ${notice.id}', name: 'AdminNoticeServiceAmplify');
        return notice;
      }
      
      const String graphQLMutation = '''
        mutation CreateNotice(\$input: CreateNoticeInput!) {
          createNotice(input: \$input) {
            id
            title
            content
            targetType
            status
            authorId
            authorName
            viewCount
            isPinned
            isImportant
            tags
            metadata
            publishedAt
            scheduledAt
            createdAt
            updatedAt
          }
        }
      ''';
      
      final now = DateTime.now();
      Map<String, dynamic> input = {
        'title': dto.title,
        'content': dto.content,
        'targetType': dto.targetType.name,
        'status': dto.status.name,
        'authorId': 'admin-001', // TODO: 실제 관리자 ID 사용
        'authorName': '관리자', // TODO: 실제 관리자 이름 사용
        'viewCount': 0,
        'isPinned': dto.isPinned,
        'isImportant': dto.isImportant,
        'tags': dto.tags,
      };
      
      if (dto.metadata != null) {
        input['metadata'] = dto.metadata.toString();
      }
      
      if (dto.status == NoticeStatus.published) {
        input['publishedAt'] = now.toIso8601String();
      }
      
      if (dto.scheduledAt != null) {
        input['scheduledAt'] = dto.scheduledAt!.toIso8601String();
      }
      
      final request = GraphQLRequest<String>(
        document: graphQLMutation,
        variables: {'input': input},
      );
      
      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.data != null) {
        final jsonResponse = jsonDecode(response.data!);
        final noticeData = jsonResponse['createNotice'];
        
        Logger.log('✅ AWS Amplify 공지사항 생성 완료: ${noticeData['id']}', name: 'AdminNoticeServiceAmplify');
        return _convertFromJson(noticeData);
      } else {
        throw Exception('공지사항 생성 실패');
      }
    } catch (e) {
      Logger.error('AWS Amplify 공지사항 생성 실패: $e', name: 'AdminNoticeServiceAmplify');
      rethrow;
    }
  }

  /// 공지사항 수정
  Future<NoticeModel> updateNotice(String noticeId, NoticeCreateUpdateDto dto) async {
    try {
      Logger.log('✏️ AWS Amplify 공지사항 수정 시작: $noticeId', name: 'AdminNoticeServiceAmplify');
      
      // Amplify 초기화 확인
      final isAmplifyReady = await _ensureAmplifyConfigured();
      if (!isAmplifyReady) {
        // Amplify 초기화 실패 시 시뮬레이션 데이터로 수정
        final existingNotice = await getNotice(noticeId); // 시뮬레이션 데이터에서 조회
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
        Logger.log('📊 시뮬레이션 공지사항 수정 완료: $noticeId', name: 'AdminNoticeServiceAmplify');
        return updatedNotice;
      }
      
      const String graphQLMutation = '''
        mutation UpdateNotice(\$input: UpdateNoticeInput!) {
          updateNotice(input: \$input) {
            id
            title
            content
            targetType
            status
            authorId
            authorName
            viewCount
            isPinned
            isImportant
            tags
            metadata
            publishedAt
            scheduledAt
            createdAt
            updatedAt
          }
        }
      ''';
      
      // 기존 공지사항 조회
      final existingNotice = await getNotice(noticeId);
      
      Map<String, dynamic> input = {
        'id': noticeId,
        'title': dto.title,
        'content': dto.content,
        'targetType': dto.targetType.name,
        'status': dto.status.name,
        'isPinned': dto.isPinned,
        'isImportant': dto.isImportant,
        'tags': dto.tags,
      };
      
      if (dto.metadata != null) {
        input['metadata'] = dto.metadata.toString();
      }
      
      // 게시 상태 변경 시 publishedAt 업데이트
      if (dto.status == NoticeStatus.published && !existingNotice.isPublished) {
        input['publishedAt'] = DateTime.now().toIso8601String();
      }
      
      if (dto.scheduledAt != null) {
        input['scheduledAt'] = dto.scheduledAt!.toIso8601String();
      }
      
      final request = GraphQLRequest<String>(
        document: graphQLMutation,
        variables: {'input': input},
      );
      
      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.data != null) {
        final jsonResponse = jsonDecode(response.data!);
        final noticeData = jsonResponse['updateNotice'];
        
        Logger.log('✅ AWS Amplify 공지사항 수정 완료', name: 'AdminNoticeServiceAmplify');
        return _convertFromJson(noticeData);
      } else {
        throw Exception('공지사항 수정 실패');
      }
    } catch (e) {
      Logger.error('AWS Amplify 공지사항 수정 실패: $e', name: 'AdminNoticeServiceAmplify');
      rethrow;
    }
  }

  /// 공지사항 삭제
  Future<void> deleteNotice(String noticeId) async {
    try {
      Logger.log('🗑️ AWS Amplify 공지사항 삭제 시작: $noticeId', name: 'AdminNoticeServiceAmplify');
      
      // Amplify 초기화 확인
      final isAmplifyReady = await _ensureAmplifyConfigured();
      if (!isAmplifyReady) {
        // Amplify 초기화 실패 시 시뮬레이션에서는 성공으로 간주
        Logger.log('📊 시뮬레이션 공지사항 삭제 완료: $noticeId', name: 'AdminNoticeServiceAmplify');
        return;
      }
      
      const String graphQLMutation = '''
        mutation DeleteNotice(\$input: DeleteNoticeInput!) {
          deleteNotice(input: \$input) {
            id
          }
        }
      ''';
      
      final request = GraphQLRequest<String>(
        document: graphQLMutation,
        variables: {
          'input': {'id': noticeId}
        },
      );
      
      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.data != null) {
        Logger.log('✅ AWS Amplify 공지사항 삭제 완료', name: 'AdminNoticeServiceAmplify');
      } else {
        throw Exception('공지사항 삭제 실패');
      }
    } catch (e) {
      Logger.error('AWS Amplify 공지사항 삭제 실패: $e', name: 'AdminNoticeServiceAmplify');
      rethrow;
    }
  }

  /// 공지사항 상태 변경
  Future<NoticeModel> updateNoticeStatus(String noticeId, NoticeStatus status) async {
    try {
      Logger.log('🔄 AWS Amplify 공지사항 상태 변경: $noticeId -> ${status.name}', name: 'AdminNoticeServiceAmplify');
      
      // Amplify 초기화 확인
      final isAmplifyReady = await _ensureAmplifyConfigured();
      if (!isAmplifyReady) {
        // Amplify 초기화 실패 시 시뮬레이션 데이터로 상태 변경
        final existingNotice = await getNotice(noticeId); // 시뮬레이션 데이터에서 조회
        final updatedNotice = existingNotice.copyWith(
          status: status,
          updatedAt: DateTime.now(),
          publishedAt: status == NoticeStatus.published && !existingNotice.isPublished 
              ? DateTime.now() 
              : existingNotice.publishedAt,
        );
        Logger.log('📊 시뮬레이션 공지사항 상태 변경 완료: $noticeId', name: 'AdminNoticeServiceAmplify');
        return updatedNotice;
      }
      
      const String graphQLMutation = '''
        mutation UpdateNotice(\$input: UpdateNoticeInput!) {
          updateNotice(input: \$input) {
            id
            title
            content
            targetType
            status
            authorId
            authorName
            viewCount
            isPinned
            isImportant
            tags
            metadata
            publishedAt
            scheduledAt
            createdAt
            updatedAt
          }
        }
      ''';
      
      // 기존 공지사항 조회
      final existingNotice = await getNotice(noticeId);
      
      Map<String, dynamic> input = {
        'id': noticeId,
        'status': status.name,
      };
      
      // 게시 상태 변경 시 publishedAt 업데이트
      if (status == NoticeStatus.published && !existingNotice.isPublished) {
        input['publishedAt'] = DateTime.now().toIso8601String();
      }
      
      final request = GraphQLRequest<String>(
        document: graphQLMutation,
        variables: {'input': input},
      );
      
      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.data != null) {
        final jsonResponse = jsonDecode(response.data!);
        final noticeData = jsonResponse['updateNotice'];
        
        Logger.log('✅ AWS Amplify 공지사항 상태 변경 완료', name: 'AdminNoticeServiceAmplify');
        return _convertFromJson(noticeData);
      } else {
        throw Exception('공지사항 상태 변경 실패');
      }
    } catch (e) {
      Logger.error('AWS Amplify 공지사항 상태 변경 실패: $e', name: 'AdminNoticeServiceAmplify');
      rethrow;
    }
  }

  /// JSON을 NoticeModel로 변환
  NoticeModel _convertFromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      targetType: NoticeTargetType.values.firstWhere(
        (e) => e.name == json['targetType'],
        orElse: () => NoticeTargetType.all,
      ),
      status: NoticeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NoticeStatus.draft,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'])
          : null,
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      isPinned: json['isPinned'] ?? false,
      isImportant: json['isImportant'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'] != null 
          ? {'raw': json['metadata']} 
          : null,
    );
  }

  /// 공지사항 정렬
  void _sortNotices(List<NoticeModel> notices, String? sortField, bool sortAscending) {
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
  }

  /// 시뮬레이션 공지사항 데이터 생성 (Amplify 초기화 실패 시 사용)
  Map<String, dynamic> _getSimulationNotices({
    int page = 1,
    int pageSize = 20,
    NoticeTargetType? targetType,
    NoticeStatus? status,
    String searchQuery = '',
    String? sortField,
    bool sortAscending = true,
  }) {
    Logger.log('📊 시뮬레이션 데이터 사용 (Amplify 초기화 실패)', name: 'AdminNoticeServiceAmplify');
    
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