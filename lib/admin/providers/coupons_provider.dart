import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:convert';
import 'dart:math';
import '../../models/Coupon.dart';

// Provider for coupons
final couponsProvider = StateNotifierProvider<CouponsNotifier, CouponsState>((ref) {
  return CouponsNotifier();
});

// State class
class CouponsState {
  final List<Coupon> coupons;
  final bool isLoading;
  final String? error;

  CouponsState({
    required this.coupons,
    required this.isLoading,
    this.error,
  });

  CouponsState copyWith({
    List<Coupon>? coupons,
    bool? isLoading,
    String? error,
  }) {
    return CouponsState(
      coupons: coupons ?? this.coupons,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier class
class CouponsNotifier extends StateNotifier<CouponsState> {
  CouponsNotifier() : super(CouponsState(coupons: [], isLoading: false)) {
    loadCoupons();
  }

  // Load all coupons from AWS
  Future<void> loadCoupons() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // AWS에서 쿠폰 데이터 로드 시도
      try {
        final request = GraphQLRequest<String>(
          document: '''query ListCoupons {
            listCoupons {
              items {
                id
                couponCode
                couponType
                title
                description
                rewardType
                rewardAmount
                validUntil
                isActive
                usageCount
                maxUsage
                createdAt
                updatedAt
              }
            }
          }''',
        );
        final response = await Amplify.API.query(request: request).response;
        
        if (response.data != null && response.errors.isEmpty) {
          // JSON 문자열을 파싱
          final jsonData = json.decode(response.data!);
          final items = jsonData['listCoupons']['items'] as List?;
          
          if (items != null) {
            final coupons = items
                .map((item) => Coupon.fromJson(item as Map<String, dynamic>))
                .toList();
            
            state = state.copyWith(
              coupons: coupons,
              isLoading: false,
            );
          } else {
            // 데이터가 없으면 빈 리스트
            state = state.copyWith(
              coupons: [],
              isLoading: false,
            );
          }
        } else {
          // 데이터가 없으면 빈 리스트
          state = state.copyWith(
            coupons: [],
            isLoading: false,
          );
        }
      } catch (e) {
        // AWS 연결 실패 시 빈 리스트 표시
        print('AWS 연결 실패, 빈 테이블 표시: $e');
        state = state.copyWith(
          coupons: [],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '쿠폰을 불러오는 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Check if coupon code is duplicate
  Future<bool> isCouponCodeDuplicate(String couponCode) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''query GetCouponByCode(\$couponCode: String!) {
          listCoupons(filter: {couponCode: {eq: \$couponCode}}) {
            items {
              id
              couponCode
            }
          }
        }''',
        variables: {
          'couponCode': couponCode,
        },
      );
      final response = await Amplify.API.query(request: request).response;
      
      if (response.data != null && response.errors.isEmpty) {
        final jsonData = json.decode(response.data!);
        final items = jsonData['listCoupons']['items'] as List?;
        return items != null && items.isNotEmpty;
      }
      return false;
    } catch (e) {
      print('쿠폰 코드 중복 검사 실패: $e');
      // 로컬에서도 확인
      return state.coupons.any((coupon) => coupon.couponCode == couponCode);
    }
  }

  // Generate unique coupon code
  Future<String> generateUniqueCouponCode() async {
    String code;
    bool isDuplicate;
    int attempts = 0;
    const maxAttempts = 10;
    
    do {
      code = _generateRandomCode();
      isDuplicate = await isCouponCodeDuplicate(code);
      attempts++;
    } while (isDuplicate && attempts < maxAttempts);
    
    if (attempts >= maxAttempts) {
      throw Exception('고유한 쿠폰 코드 생성에 실패했습니다. 다시 시도해주세요.');
    }
    
    return code;
  }

  // Generate random coupon code
  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Create a new coupon
  Future<void> createCoupon({
    required String couponCode,
    required String couponType,
    required String title,
    required String description,
    String? rewardType,
    int? rewardAmount,
    required String validUntil,
    bool isActive = true,
    int maxUsage = 0,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // 쿠폰 코드 중복 검사
      if (await isCouponCodeDuplicate(couponCode)) {
        state = state.copyWith(
          isLoading: false,
          error: '이미 존재하는 쿠폰 코드입니다.',
        );
        return;
      }
      
      final newCoupon = Coupon(
        couponCode: couponCode,
        couponType: couponType,
        title: title,
        description: description,
        rewardType: rewardType,
        rewardAmount: rewardAmount,
        validUntil: validUntil,
        isActive: isActive,
        usageCount: 0,
        maxUsage: maxUsage,
      );
      
      // 먼저 로컬 상태 업데이트
      final updatedCoupons = List<Coupon>.from([...state.coupons, newCoupon]);
      state = state.copyWith(
        coupons: updatedCoupons,
        isLoading: false,
      );
      
      // AWS에 저장 시도
      try {
        final request = GraphQLRequest<Coupon>(
          document: '''mutation CreateCoupon(\$input: CreateCouponInput!) {
            createCoupon(input: \$input) {
              id
              couponCode
              couponType
              title
              description
              rewardType
              rewardAmount
              validUntil
              isActive
              usageCount
              maxUsage
              createdAt
              updatedAt
            }
          }''',
          variables: {
            'input': {
              'couponCode': newCoupon.couponCode,
              'couponType': newCoupon.couponType,
              'title': newCoupon.title,
              'description': newCoupon.description,
              'rewardType': newCoupon.rewardType,
              'rewardAmount': newCoupon.rewardAmount,
              'validUntil': newCoupon.validUntil,
              'isActive': newCoupon.isActive,
              'usageCount': newCoupon.usageCount,
              'maxUsage': newCoupon.maxUsage,
            }
          },
          decodePath: 'createCoupon',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 저장 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '쿠폰 생성 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Update an existing coupon
  Future<void> updateCoupon(Coupon coupon) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // 먼저 로컬 상태 업데이트
      final updatedCoupons = List<Coupon>.from(
        state.coupons.map((c) {
          return c.id == coupon.id ? coupon : c;
        })
      );
      
      state = state.copyWith(
        coupons: updatedCoupons,
        isLoading: false,
      );
      
      // AWS에 업데이트 시도
      try {
        final request = GraphQLRequest<Coupon>(
          document: '''mutation UpdateCoupon(\$input: UpdateCouponInput!) {
            updateCoupon(input: \$input) {
              id
              couponCode
              couponType
              title
              description
              rewardType
              rewardAmount
              validUntil
              isActive
              usageCount
              maxUsage
              createdAt
              updatedAt
            }
          }''',
          variables: {
            'input': {
              'id': coupon.id,
              'couponCode': coupon.couponCode,
              'couponType': coupon.couponType,
              'title': coupon.title,
              'description': coupon.description,
              'rewardType': coupon.rewardType,
              'rewardAmount': coupon.rewardAmount,
              'validUntil': coupon.validUntil,
              'isActive': coupon.isActive,
              'usageCount': coupon.usageCount,
              'maxUsage': coupon.maxUsage,
            }
          },
          decodePath: 'updateCoupon',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 업데이트 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '쿠폰 수정 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Delete a coupon
  Future<void> deleteCoupon(String couponId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // 먼저 로컬 상태 업데이트
      final updatedCoupons = state.coupons.where((c) => c.id != couponId).toList();
      state = state.copyWith(
        coupons: updatedCoupons,
        isLoading: false,
      );
      
      // AWS에서 삭제 시도
      try {
        final request = GraphQLRequest<Coupon>(
          document: '''mutation DeleteCoupon(\$input: DeleteCouponInput!) {
            deleteCoupon(input: \$input) {
              id
            }
          }''',
          variables: {
            'input': {
              'id': couponId,
            }
          },
          decodePath: 'deleteCoupon',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 삭제 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '쿠폰 삭제 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Toggle coupon active status
  Future<void> toggleCouponStatus(String couponId, bool isActive) async {
    try {
      final coupon = state.coupons.firstWhere((c) => c.id == couponId);
      final updatedCoupon = coupon.copyWith(isActive: isActive);
      await updateCoupon(updatedCoupon);
    } catch (e) {
      state = state.copyWith(
        error: '쿠폰 상태 변경 중 오류가 발생했습니다: $e',
      );
    }
  }
}