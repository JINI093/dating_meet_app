import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:convert';
import 'dart:math';
import '../../models/DiscountCoupon.dart';

// Provider for discount coupons
final discountCouponsProvider = StateNotifierProvider<DiscountCouponsNotifier, DiscountCouponsState>((ref) {
  return DiscountCouponsNotifier();
});

// State class
class DiscountCouponsState {
  final List<DiscountCoupon> coupons;
  final bool isLoading;
  final String? error;

  DiscountCouponsState({
    required this.coupons,
    required this.isLoading,
    this.error,
  });

  DiscountCouponsState copyWith({
    List<DiscountCoupon>? coupons,
    bool? isLoading,
    String? error,
  }) {
    return DiscountCouponsState(
      coupons: coupons ?? this.coupons,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier class
class DiscountCouponsNotifier extends StateNotifier<DiscountCouponsState> {
  DiscountCouponsNotifier() : super(DiscountCouponsState(coupons: [], isLoading: false)) {
    loadDiscountCoupons();
  }

  // Load all discount coupons from AWS
  Future<void> loadDiscountCoupons() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // AWS에서 할인쿠폰 데이터 로드 시도
      try {
        final request = GraphQLRequest<String>(
          document: '''query ListDiscountCoupons {
            listDiscountCoupons {
              items {
                id
                couponName
                recipientUserId
                discountRate
                couponCode
                validUntil
                isUsed
                isActive
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
          final items = jsonData['listDiscountCoupons']['items'] as List?;
          
          if (items != null) {
            final coupons = items
                .map((item) => DiscountCoupon.fromJson(item as Map<String, dynamic>))
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
        error: '할인쿠폰을 불러오는 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Check if coupon code is duplicate
  Future<bool> isCouponCodeDuplicate(String couponCode) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''query GetDiscountCouponByCode(\$couponCode: String!) {
          listDiscountCoupons(filter: {couponCode: {eq: \$couponCode}}) {
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
        final items = jsonData['listDiscountCoupons']['items'] as List?;
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

  // Create a new discount coupon
  Future<void> createDiscountCoupon({
    required String couponName,
    required String recipientUserId,
    required int discountRate,
    required String couponCode,
    required String validUntil,
    bool isActive = true,
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
      
      final newCoupon = DiscountCoupon(
        couponName: couponName,
        recipientUserId: recipientUserId,
        discountRate: discountRate,
        couponCode: couponCode,
        validUntil: validUntil,
        isUsed: false,
        isActive: isActive,
      );
      
      // 먼저 로컬 상태 업데이트
      final updatedCoupons = List<DiscountCoupon>.from([...state.coupons, newCoupon]);
      state = state.copyWith(
        coupons: updatedCoupons,
        isLoading: false,
      );
      
      // AWS에 저장 시도
      try {
        final request = GraphQLRequest<DiscountCoupon>(
          document: '''mutation CreateDiscountCoupon(\$input: CreateDiscountCouponInput!) {
            createDiscountCoupon(input: \$input) {
              id
              couponName
              recipientUserId
              discountRate
              couponCode
              validUntil
              isUsed
              isActive
              createdAt
              updatedAt
            }
          }''',
          variables: {
            'input': {
              'couponName': newCoupon.couponName,
              'recipientUserId': newCoupon.recipientUserId,
              'discountRate': newCoupon.discountRate,
              'couponCode': newCoupon.couponCode,
              'validUntil': newCoupon.validUntil,
              'isUsed': newCoupon.isUsed,
              'isActive': newCoupon.isActive,
            }
          },
          decodePath: 'createDiscountCoupon',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 저장 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '할인쿠폰 생성 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Update an existing discount coupon
  Future<void> updateDiscountCoupon(DiscountCoupon coupon) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // 먼저 로컬 상태 업데이트
      final updatedCoupons = List<DiscountCoupon>.from(
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
        final request = GraphQLRequest<DiscountCoupon>(
          document: '''mutation UpdateDiscountCoupon(\$input: UpdateDiscountCouponInput!) {
            updateDiscountCoupon(input: \$input) {
              id
              couponName
              recipientUserId
              discountRate
              couponCode
              validUntil
              isUsed
              isActive
              createdAt
              updatedAt
            }
          }''',
          variables: {
            'input': {
              'id': coupon.id,
              'couponName': coupon.couponName,
              'recipientUserId': coupon.recipientUserId,
              'discountRate': coupon.discountRate,
              'couponCode': coupon.couponCode,
              'validUntil': coupon.validUntil,
              'isUsed': coupon.isUsed,
              'isActive': coupon.isActive,
            }
          },
          decodePath: 'updateDiscountCoupon',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 업데이트 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '할인쿠폰 수정 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Delete a discount coupon
  Future<void> deleteDiscountCoupon(String couponId) async {
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
        final request = GraphQLRequest<DiscountCoupon>(
          document: '''mutation DeleteDiscountCoupon(\$input: DeleteDiscountCouponInput!) {
            deleteDiscountCoupon(input: \$input) {
              id
            }
          }''',
          variables: {
            'input': {
              'id': couponId,
            }
          },
          decodePath: 'deleteDiscountCoupon',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 삭제 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '할인쿠폰 삭제 중 오류가 발생했습니다: $e',
      );
    }
  }
}