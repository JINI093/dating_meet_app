import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import '../models/banner_model.dart';
import '../../config/api_config.dart' as app_api_config;
import '../../utils/logger.dart';
import 'image_upload_service.dart';

/// 관리자 배너 관리 서비스 (시뮬레이션 버전)
class AdminBannerService {
  final Dio _dio = Dio();
  final ImageUploadService _imageUploadService = ImageUploadService();
  static const _uuid = Uuid();

  AdminBannerService() {
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

  /// 배너 목록 조회
  Future<List<BannerModel>> getBanners({BannerType? type}) async {
    try {
      Logger.log('📋 배너 목록 조회 시작 (시뮬레이션 모드)', name: 'AdminBannerService');
      
      // 시뮬레이션 데이터 사용
      final banners = _getSimulationBanners();
      
      // 타입별 필터링
      if (type != null) {
        return banners.where((banner) => banner.type == type).toList();
      }
      
      return banners;
    } catch (e) {
      Logger.error('배너 목록 조회 실패: $e', name: 'AdminBannerService');
      throw Exception('배너 목록 조회 실패: $e');
    }
  }

  /// 배너 상세 조회
  Future<BannerModel> getBanner(String bannerId) async {
    try {
      Logger.log('📄 배너 상세 조회: $bannerId (시뮬레이션)', name: 'AdminBannerService');

      final banners = _getSimulationBanners();
      
      BannerModel? banner;
      try {
        banner = banners.firstWhere((b) => b.id == bannerId);
      } catch (e) {
        throw Exception('배너를 찾을 수 없습니다');
      }

      return banner;
    } catch (e) {
      Logger.error('배너 상세 조회 실패: $e', name: 'AdminBannerService');
      throw Exception('배너 상세 조회 실패: $e');
    }
  }

  /// 배너 생성
  Future<BannerModel> createBanner(BannerCreateUpdateDto dto) async {
    try {
      Logger.log('✏️ 배너 생성 시작 (시뮬레이션)', name: 'AdminBannerService');

      final now = DateTime.now();
      final banner = BannerModel(
        id: 'banner_${_uuid.v4().substring(0, 8)}',
        type: dto.type,
        title: dto.title,
        description: dto.description,
        imageUrl: dto.imageUrl,
        linkUrl: dto.linkUrl,
        isActive: dto.isActive,
        order: dto.order,
        startDate: dto.startDate,
        endDate: dto.endDate,
        createdBy: 'admin_001', // TODO: 실제 관리자 ID
        createdAt: now,
        updatedAt: now,
      );

      Logger.log('📊 시뮬레이션 배너 생성 완료: ${banner.id}', name: 'AdminBannerService');

      return banner;
    } catch (e) {
      Logger.error('배너 생성 실패: $e', name: 'AdminBannerService');
      throw Exception('배너 생성 실패: $e');
    }
  }

  /// 배너 수정
  Future<BannerModel> updateBanner(String bannerId, BannerCreateUpdateDto dto) async {
    try {
      Logger.log('🔄 배너 수정: $bannerId (시뮬레이션)', name: 'AdminBannerService');

      final existingBanner = await getBanner(bannerId);
      final updatedBanner = existingBanner.copyWith(
        type: dto.type,
        title: dto.title,
        description: dto.description,
        imageUrl: dto.imageUrl,
        linkUrl: dto.linkUrl,
        isActive: dto.isActive,
        order: dto.order,
        startDate: dto.startDate,
        endDate: dto.endDate,
        updatedAt: DateTime.now(),
      );

      Logger.log('📊 시뮬레이션 배너 수정 완료: $bannerId', name: 'AdminBannerService');

      return updatedBanner;
    } catch (e) {
      Logger.error('배너 수정 실패: $e', name: 'AdminBannerService');
      throw Exception('배너 수정 실패: $e');
    }
  }

  /// 배너 삭제
  Future<void> deleteBanner(String bannerId) async {
    try {
      Logger.log('🗑️ 배너 삭제: $bannerId (시뮬레이션)', name: 'AdminBannerService');

      await getBanner(bannerId); // 존재 확인

      Logger.log('📊 시뮬레이션 배너 삭제 완료: $bannerId', name: 'AdminBannerService');
    } catch (e) {
      Logger.error('배너 삭제 실패: $e', name: 'AdminBannerService');
      throw Exception('배너 삭제 실패: $e');
    }
  }

  /// 배너 활성화/비활성화
  Future<BannerModel> toggleBannerStatus(String bannerId) async {
    try {
      Logger.log('🔄 배너 상태 토글: $bannerId (시뮬레이션)', name: 'AdminBannerService');

      final existingBanner = await getBanner(bannerId);
      final updatedBanner = existingBanner.copyWith(
        isActive: !existingBanner.isActive,
        updatedAt: DateTime.now(),
      );

      Logger.log('📊 시뮬레이션 배너 상태 변경 완료: $bannerId', name: 'AdminBannerService');

      return updatedBanner;
    } catch (e) {
      Logger.error('배너 상태 변경 실패: $e', name: 'AdminBannerService');
      throw Exception('배너 상태 변경 실패: $e');
    }
  }

  /// 이미지 파일 선택
  Future<PlatformFile?> pickImage() async {
    try {
      Logger.log('📸 이미지 파일 선택 시작', name: 'AdminBannerService');
      return await _imageUploadService.pickImage();
    } catch (e) {
      Logger.error('이미지 파일 선택 실패: $e', name: 'AdminBannerService');
      throw Exception('이미지 파일 선택 실패: $e');
    }
  }

  /// 이미지 업로드 (실제 AWS S3)
  Future<String> uploadImage(PlatformFile file) async {
    try {
      Logger.log('📸 배너 이미지 업로드 시작: ${file.name}', name: 'AdminBannerService');

      final imageUrl = await _imageUploadService.uploadBannerImage(file);

      Logger.log('✅ 배너 이미지 업로드 완료: $imageUrl', name: 'AdminBannerService');

      return imageUrl;
    } catch (e) {
      Logger.error('이미지 업로드 실패: $e', name: 'AdminBannerService');
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  /// 이미지 삭제
  Future<void> deleteImage(String imageUrl) async {
    try {
      Logger.log('🗑️ 배너 이미지 삭제 시작: $imageUrl', name: 'AdminBannerService');
      await _imageUploadService.deleteFromS3(imageUrl);
      Logger.log('✅ 배너 이미지 삭제 완료', name: 'AdminBannerService');
    } catch (e) {
      Logger.error('이미지 삭제 실패: $e', name: 'AdminBannerService');
      // 삭제 실패는 치명적이지 않으므로 예외를 다시 던지지 않음
    }
  }

  /// 시뮬레이션 배너 데이터 생성
  List<BannerModel> _getSimulationBanners() {
    final now = DateTime.now();
    
    return [
      BannerModel(
        id: 'banner_001',
        type: BannerType.mainAd,
        title: '신규 회원 혜택',
        description: '지금 가입하면 포인트 1000P 지급!',
        imageUrl: 'https://picsum.photos/800/400?random=1',
        linkUrl: 'https://example.com/signup',
        isActive: true,
        order: 1,
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 30)),
        createdBy: 'admin_001',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      BannerModel(
        id: 'banner_002',
        type: BannerType.pointStore,
        title: '포인트 상점 할인 이벤트',
        description: '모든 상품 20% 할인!',
        imageUrl: 'https://picsum.photos/800/400?random=2',
        linkUrl: 'https://example.com/store',
        isActive: true,
        order: 1,
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 14)),
        createdBy: 'admin_002',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      BannerModel(
        id: 'banner_003',
        type: BannerType.terms,
        title: '이용약관 변경 안내',
        description: '2024년 1월 1일부터 새로운 이용약관이 적용됩니다.',
        imageUrl: 'https://picsum.photos/800/400?random=3',
        linkUrl: 'https://example.com/terms',
        isActive: true,
        order: 1,
        createdBy: 'admin_001',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      BannerModel(
        id: 'banner_004',
        type: BannerType.mainAd,
        title: 'VIP 회원 모집',
        description: 'VIP 회원만의 특별한 혜택을 누려보세요',
        imageUrl: 'https://picsum.photos/800/400?random=4',
        isActive: false,
        order: 2,
        createdBy: 'admin_003',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}