import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../models/banner_model.dart';
import '../services/admin_banner_service_amplify.dart';

/// 배너 상태
class AdminBannerState {
  final List<BannerModel> banners;
  final bool isLoading;
  final String? error;
  final BannerType? selectedType;

  AdminBannerState({
    this.banners = const [],
    this.isLoading = false,
    this.error,
    this.selectedType,
  });

  AdminBannerState copyWith({
    List<BannerModel>? banners,
    bool? isLoading,
    String? error,
    BannerType? selectedType,
  }) {
    return AdminBannerState(
      banners: banners ?? this.banners,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

/// 배너 노티파이어
class AdminBannerNotifier extends StateNotifier<AdminBannerState> {
  final AdminBannerServiceAmplify _service;

  AdminBannerNotifier(this._service) : super(AdminBannerState()) {
    loadBanners();
  }

  /// 배너 목록 로드
  Future<void> loadBanners({BannerType? type}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final banners = await _service.getBanners(type: type);
      
      state = state.copyWith(
        banners: banners,
        selectedType: type,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 타입별 필터링
  Future<void> filterByType(BannerType? type) async {
    await loadBanners(type: type);
  }

  /// 배너 생성
  Future<BannerModel> createBanner(BannerCreateUpdateDto dto) async {
    try {
      final banner = await _service.createBanner(dto);
      await refresh(); // 목록 새로고침
      return banner;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 배너 수정
  Future<BannerModel> updateBanner(String bannerId, BannerCreateUpdateDto dto) async {
    try {
      final banner = await _service.updateBanner(bannerId, dto);
      await refresh(); // 목록 새로고침
      return banner;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 배너 삭제
  Future<void> deleteBanner(String bannerId) async {
    try {
      await _service.deleteBanner(bannerId);
      await refresh(); // 목록 새로고침
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 배너 상태 토글
  Future<void> toggleBannerStatus(String bannerId) async {
    try {
      await _service.toggleBannerStatus(bannerId);
      await refresh(); // 목록 새로고침
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 이미지 파일 선택
  Future<PlatformFile?> pickImage() async {
    try {
      return await _service.pickImage();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 이미지 업로드
  Future<String> uploadImage(PlatformFile file) async {
    try {
      return await _service.uploadImage(file);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 이미지 삭제
  Future<void> deleteImage(String imageUrl) async {
    try {
      await _service.deleteImage(imageUrl);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadBanners(type: state.selectedType);
  }

  /// 배너 상세 조회
  Future<BannerModel> getBanner(String bannerId) async {
    try {
      return await _service.getBanner(bannerId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

/// 배너 서비스 프로바이더
final adminBannerServiceProvider = Provider<AdminBannerServiceAmplify>((ref) {
  return AdminBannerServiceAmplify();
});

/// 배너 관리 프로바이더
final adminBannerProvider = StateNotifierProvider<AdminBannerNotifier, AdminBannerState>((ref) {
  final service = ref.watch(adminBannerServiceProvider);
  return AdminBannerNotifier(service);
});

/// 특정 배너 상세 프로바이더
final bannerDetailProvider = FutureProvider.family<BannerModel, String>((ref, bannerId) async {
  final service = ref.watch(adminBannerServiceProvider);
  return service.getBanner(bannerId);
});

/// 타입별 배너 통계 프로바이더
final bannerStatsProvider = Provider<Map<String, int>>((ref) {
  final bannerState = ref.watch(adminBannerProvider);
  final banners = bannerState.banners;
  
  final stats = <String, int>{
    'total': banners.length,
    'active': banners.where((b) => b.isActive).length,
    'inactive': banners.where((b) => !b.isActive).length,
    'mainAd': banners.where((b) => b.type == BannerType.mainAd).length,
    'pointStore': banners.where((b) => b.type == BannerType.pointStore).length,
    'terms': banners.where((b) => b.type == BannerType.terms).length,
  };
  
  return stats;
});