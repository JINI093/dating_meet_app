import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:file_picker/file_picker.dart';
import '../models/banner_model.dart';
import '../../utils/logger.dart';
import 'image_upload_service.dart';

/// 관리자 배너 관리 서비스 (AWS Amplify 실제 버전)
class AdminBannerServiceAmplify {
  final ImageUploadService _imageUploadService = ImageUploadService();
  
  // 캐시 설정
  static bool? _amplifyStatusCache;
  static DateTime? _lastCheckTime;
  static const Duration _cacheValidityDuration = Duration(seconds: 30);

  /// 캐시 초기화 (앱 시작 시 호출)
  static void resetCache() {
    _amplifyStatusCache = null;
    _lastCheckTime = null;
  }

  /// Amplify 설정 확인
  Future<bool> _ensureAmplifyConfigured() async {
    try {
      Logger.log('🔍 Amplify 상태 확인 시작', name: 'AdminBannerServiceAmplify');
      
      // 캐시된 성공 결과가 있으면 바로 성공 반환 (30초간 유효)
      final now = DateTime.now();
      if (_amplifyStatusCache == true && 
          _lastCheckTime != null && 
          now.difference(_lastCheckTime!) < _cacheValidityDuration) {
        Logger.log('📋 캐시된 성공 상태 사용', name: 'AdminBannerServiceAmplify');
        return true;
      }

      // Amplify 설정 상태 확인 (여러 번 재시도)
      for (int i = 0; i < 3; i++) {
        if (Amplify.isConfigured) {
          break;
        }
        Logger.log('⏳ Amplify 초기화 대기 중... (${i + 1}/3)', name: 'AdminBannerServiceAmplify');
        await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
      }

      if (!Amplify.isConfigured) {
        Logger.log('❌ Amplify가 설정되지 않음', name: 'AdminBannerServiceAmplify');
        _amplifyStatusCache = false;
        _lastCheckTime = DateTime.now();
        return false;
      }

      // API 플러그인 확인
      try {
        await Amplify.API.query(request: GraphQLRequest<String>(
          document: '''
            query ListBanners {
              listBanners(limit: 1) {
                items {
                  id
                }
              }
            }
          '''
        )).response;
        
        Logger.log('✅ Amplify API 연결 성공', name: 'AdminBannerServiceAmplify');
        _amplifyStatusCache = true;
        _lastCheckTime = DateTime.now();
        return true;
      } catch (apiError) {
        Logger.log('❌ Amplify API 연결 실패: $apiError', name: 'AdminBannerServiceAmplify');
        _amplifyStatusCache = false;
        _lastCheckTime = DateTime.now();
        return false;
      }
    } catch (e) {
      Logger.error('Amplify 상태 확인 실패: $e', name: 'AdminBannerServiceAmplify');
      _amplifyStatusCache = false;
      _lastCheckTime = DateTime.now();
      return false;
    }
  }

  /// 배너 목록 조회
  Future<List<BannerModel>> getBanners({BannerType? type}) async {
    try {
      Logger.log('📋 AWS 배너 목록 조회 시작', name: 'AdminBannerServiceAmplify');
      
      if (!await _ensureAmplifyConfigured()) {
        Logger.log('📊 Amplify 미설정으로 빈 목록 반환', name: 'AdminBannerServiceAmplify');
        return [];
      }

      String query = '''
        query ListBanners(\$filter: ModelBannerFilterInput) {
          listBanners(filter: \$filter) {
            items {
              id
              type
              title
              description
              imageUrl
              linkUrl
              isActive
              order
              startDate
              endDate
              createdBy
              createdAt
              updatedAt
            }
          }
        }
      ''';

      Map<String, dynamic>? variables;
      if (type != null) {
        variables = {
          'filter': {
            'type': {'eq': type.name}
          }
        };
      }

      final request = GraphQLRequest<String>(
        document: query,
        variables: variables ?? {},
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final data = response.data!;
        final items = _parseGraphQLResponse(data)['listBanners']['items'] as List;
        
        final banners = items.map((item) => BannerModel.fromJson(item)).toList();
        
        // 순서와 생성일 기준으로 정렬
        banners.sort((a, b) {
          int orderComparison = a.order.compareTo(b.order);
          if (orderComparison != 0) return orderComparison;
          return b.createdAt.compareTo(a.createdAt);
        });
        
        Logger.log('✅ AWS 배너 목록 조회 완료: ${banners.length}개', name: 'AdminBannerServiceAmplify');
        return banners;
      }

      throw Exception('응답 데이터가 없습니다');
    } catch (e) {
      Logger.error('AWS 배너 목록 조회 실패: $e', name: 'AdminBannerServiceAmplify');
      return []; // 에러 시 빈 목록 반환
    }
  }

  /// 배너 상세 조회
  Future<BannerModel> getBanner(String bannerId) async {
    try {
      Logger.log('📄 AWS 배너 상세 조회: $bannerId', name: 'AdminBannerServiceAmplify');
      
      if (!await _ensureAmplifyConfigured()) {
        throw Exception('Amplify가 설정되지 않았습니다');
      }

      const query = '''
        query GetBanner(\$id: ID!) {
          getBanner(id: \$id) {
            id
            type
            title
            description
            imageUrl
            linkUrl
            isActive
            order
            startDate
            endDate
            createdBy
            createdAt
            updatedAt
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: query,
        variables: {'id': bannerId},
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.data != null) {
        final data = response.data!;
        final bannerData = _parseGraphQLResponse(data)['getBanner'];
        
        if (bannerData != null) {
          final banner = BannerModel.fromJson(bannerData);
          Logger.log('✅ AWS 배너 상세 조회 완료', name: 'AdminBannerServiceAmplify');
          return banner;
        }
      }

      throw Exception('배너를 찾을 수 없습니다');
    } catch (e) {
      Logger.error('AWS 배너 상세 조회 실패: $e', name: 'AdminBannerServiceAmplify');
      throw Exception('배너 상세 조회 실패: $e');
    }
  }

  /// 배너 생성
  Future<BannerModel> createBanner(BannerCreateUpdateDto dto) async {
    try {
      Logger.log('✏️ AWS 배너 생성 시작', name: 'AdminBannerServiceAmplify');
      
      if (!await _ensureAmplifyConfigured()) {
        throw Exception('Amplify가 설정되지 않았습니다');
      }

      const mutation = '''
        mutation CreateBanner(\$input: CreateBannerInput!) {
          createBanner(input: \$input) {
            id
            type
            title
            description
            imageUrl
            linkUrl
            isActive
            order
            startDate
            endDate
            createdBy
            createdAt
            updatedAt
          }
        }
      ''';

      final input = {
        'type': dto.type.name,
        'title': dto.title,
        'description': dto.description,
        'imageUrl': dto.imageUrl,
        'linkUrl': dto.linkUrl,
        'isActive': dto.isActive,
        'order': dto.order,
        'startDate': dto.startDate?.toIso8601String(),
        'endDate': dto.endDate?.toIso8601String(),
        'createdBy': 'admin_001', // TODO: 실제 관리자 ID
      };

      final request = GraphQLRequest<String>(
        document: mutation,
        variables: {'input': input},
      );

      final response = await Amplify.API.mutate(request: request).response;

      if (response.data != null) {
        final data = response.data!;
        final bannerData = _parseGraphQLResponse(data)['createBanner'];
        final banner = BannerModel.fromJson(bannerData);
        
        Logger.log('✅ AWS 배너 생성 완료: ${banner.id}', name: 'AdminBannerServiceAmplify');
        return banner;
      }

      throw Exception('배너 생성 응답이 없습니다');
    } catch (e) {
      Logger.error('AWS 배너 생성 실패: $e', name: 'AdminBannerServiceAmplify');
      throw Exception('배너 생성 실패: $e');
    }
  }

  /// 배너 수정
  Future<BannerModel> updateBanner(String bannerId, BannerCreateUpdateDto dto) async {
    try {
      Logger.log('🔄 AWS 배너 수정: $bannerId', name: 'AdminBannerServiceAmplify');
      
      if (!await _ensureAmplifyConfigured()) {
        throw Exception('Amplify가 설정되지 않았습니다');
      }

      const mutation = '''
        mutation UpdateBanner(\$input: UpdateBannerInput!) {
          updateBanner(input: \$input) {
            id
            type
            title
            description
            imageUrl
            linkUrl
            isActive
            order
            startDate
            endDate
            createdBy
            createdAt
            updatedAt
          }
        }
      ''';

      final input = {
        'id': bannerId,
        'type': dto.type.name,
        'title': dto.title,
        'description': dto.description,
        'imageUrl': dto.imageUrl,
        'linkUrl': dto.linkUrl,
        'isActive': dto.isActive,
        'order': dto.order,
        'startDate': dto.startDate?.toIso8601String(),
        'endDate': dto.endDate?.toIso8601String(),
      };

      final request = GraphQLRequest<String>(
        document: mutation,
        variables: {'input': input},
      );

      final response = await Amplify.API.mutate(request: request).response;

      if (response.data != null) {
        final data = response.data!;
        final bannerData = _parseGraphQLResponse(data)['updateBanner'];
        final banner = BannerModel.fromJson(bannerData);
        
        Logger.log('✅ AWS 배너 수정 완료: $bannerId', name: 'AdminBannerServiceAmplify');
        return banner;
      }

      throw Exception('배너 수정 응답이 없습니다');
    } catch (e) {
      Logger.error('AWS 배너 수정 실패: $e', name: 'AdminBannerServiceAmplify');
      throw Exception('배너 수정 실패: $e');
    }
  }

  /// 배너 삭제
  Future<void> deleteBanner(String bannerId) async {
    try {
      Logger.log('🗑️ AWS 배너 삭제: $bannerId', name: 'AdminBannerServiceAmplify');
      
      if (!await _ensureAmplifyConfigured()) {
        throw Exception('Amplify가 설정되지 않았습니다');
      }

      // 삭제 전 배너 정보 조회하여 이미지 삭제
      try {
        final banner = await getBanner(bannerId);
        if (banner.imageUrl.isNotEmpty) {
          await _imageUploadService.deleteFromS3(banner.imageUrl);
        }
      } catch (e) {
        Logger.log('⚠️ 배너 이미지 삭제 실패 (계속 진행): $e', name: 'AdminBannerServiceAmplify');
      }

      const mutation = '''
        mutation DeleteBanner(\$input: DeleteBannerInput!) {
          deleteBanner(input: \$input) {
            id
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: mutation,
        variables: {
          'input': {'id': bannerId}
        },
      );

      await Amplify.API.mutate(request: request).response;
      
      Logger.log('✅ AWS 배너 삭제 완료: $bannerId', name: 'AdminBannerServiceAmplify');
    } catch (e) {
      Logger.error('AWS 배너 삭제 실패: $e', name: 'AdminBannerServiceAmplify');
      throw Exception('배너 삭제 실패: $e');
    }
  }

  /// 배너 활성화/비활성화
  Future<BannerModel> toggleBannerStatus(String bannerId) async {
    try {
      Logger.log('🔄 AWS 배너 상태 토글: $bannerId', name: 'AdminBannerServiceAmplify');
      
      // 현재 배너 조회
      final currentBanner = await getBanner(bannerId);
      
      // 상태 토글하여 수정
      final dto = BannerCreateUpdateDto(
        type: currentBanner.type,
        title: currentBanner.title,
        description: currentBanner.description,
        imageUrl: currentBanner.imageUrl,
        linkUrl: currentBanner.linkUrl,
        isActive: !currentBanner.isActive,
        order: currentBanner.order,
        startDate: currentBanner.startDate,
        endDate: currentBanner.endDate,
      );

      return await updateBanner(bannerId, dto);
    } catch (e) {
      Logger.error('AWS 배너 상태 변경 실패: $e', name: 'AdminBannerServiceAmplify');
      throw Exception('배너 상태 변경 실패: $e');
    }
  }

  /// 이미지 파일 선택
  Future<PlatformFile?> pickImage() async {
    try {
      Logger.log('📸 이미지 파일 선택 시작', name: 'AdminBannerServiceAmplify');
      return await _imageUploadService.pickImage();
    } catch (e) {
      Logger.error('이미지 파일 선택 실패: $e', name: 'AdminBannerServiceAmplify');
      throw Exception('이미지 파일 선택 실패: $e');
    }
  }

  /// 이미지 업로드
  Future<String> uploadImage(PlatformFile file) async {
    try {
      Logger.log('📸 배너 이미지 업로드 시작: ${file.name}', name: 'AdminBannerServiceAmplify');
      return await _imageUploadService.uploadBannerImage(file);
    } catch (e) {
      Logger.error('이미지 업로드 실패: $e', name: 'AdminBannerServiceAmplify');
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  /// 이미지 삭제
  Future<void> deleteImage(String imageUrl) async {
    try {
      Logger.log('🗑️ 배너 이미지 삭제 시작: $imageUrl', name: 'AdminBannerServiceAmplify');
      await _imageUploadService.deleteFromS3(imageUrl);
      Logger.log('✅ 배너 이미지 삭제 완료', name: 'AdminBannerServiceAmplify');
    } catch (e) {
      Logger.error('이미지 삭제 실패: $e', name: 'AdminBannerServiceAmplify');
      // 삭제 실패는 치명적이지 않으므로 예외를 다시 던지지 않음
    }
  }

  /// GraphQL 응답 파싱
  Map<String, dynamic> _parseGraphQLResponse(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw Exception('GraphQL 응답 형식이 올바르지 않습니다');
    } catch (e) {
      Logger.error('GraphQL 응답 파싱 실패: $e', name: 'AdminBannerServiceAmplify');
      throw Exception('응답 파싱 실패: $e');
    }
  }
}