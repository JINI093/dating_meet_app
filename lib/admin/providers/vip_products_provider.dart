import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:convert';
import '../../models/VipProduct.dart';
import '../../models/ModelProvider.dart';

// Provider for VIP products
final vipProductsProvider = StateNotifierProvider<VipProductsNotifier, VipProductsState>((ref) {
  return VipProductsNotifier();
});

// State class
class VipProductsState {
  final List<VipProduct> products;
  final bool isLoading;
  final String? error;

  VipProductsState({
    required this.products,
    required this.isLoading,
    this.error,
  });

  VipProductsState copyWith({
    List<VipProduct>? products,
    bool? isLoading,
    String? error,
  }) {
    return VipProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier class
class VipProductsNotifier extends StateNotifier<VipProductsState> {
  VipProductsNotifier() : super(VipProductsState(products: [], isLoading: false)) {
    loadProducts();
  }

  // Mock data for initial display
  List<VipProduct> _getMockProducts() {
    return [
      VipProduct(
        id: '1',
        title: 'VIP GOLD',
        subtitle: '최고급 VIP 서비스를 경험하세요!',
        description: '모든 프리미엄 기능을 무제한으로 이용할 수 있습니다.\n\n• 무제한 하트 보내기\n• 무제한 슈퍼챗 이용\n• 프로필 열람권 무제한\n• 추천카드 더 보기 무제한\n• VIP 전용 매칭 서비스\n• 우선 고객지원',
        tier: 'GOLD',
        iconColor: '#FFD700',
        isActive: true,
        features: ['무제한 하트', '무제한 슈퍼챗', '프로필 열람권', '추천카드', 'VIP 매칭', '우선 고객지원'],
      ),
      VipProduct(
        id: '2',
        title: 'VIP SILVER',
        subtitle: '프리미엄 기능을 합리적으로!',
        description: '대부분의 프리미엄 기능을 이용할 수 있습니다.\n\n• 매일 50개 하트 보내기\n• 매일 20개 슈퍼챗 이용\n• 프로필 열람권 매일 10회\n• 추천카드 더 보기 매일 50회\n• VIP 전용 이벤트 참여',
        tier: 'SILVER',
        iconColor: '#C0C0C0',
        isActive: true,
        features: ['50개 하트/일', '20개 슈퍼챗/일', '프로필 열람권 10회/일', '추천카드 50회/일', 'VIP 이벤트'],
      ),
      VipProduct(
        id: '3',
        title: 'VIP BRONZE',
        subtitle: '기본 VIP 혜택을 시작하세요!',
        description: '필수 프리미엄 기능을 이용할 수 있습니다.\n\n• 매일 20개 하트 보내기\n• 매일 10개 슈퍼챗 이용\n• 프로필 열람권 매일 5회\n• 추천카드 더 보기 매일 20회\n• 광고 제거',
        tier: 'BRONZE',
        iconColor: '#CD7F32',
        isActive: true,
        features: ['20개 하트/일', '10개 슈퍼챗/일', '프로필 열람권 5회/일', '추천카드 20회/일', '광고 제거'],
      ),
    ];
  }

  // Load all products from AWS
  Future<void> loadProducts() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // 먼저 mock 데이터를 표시
      state = state.copyWith(
        products: _getMockProducts(),
        isLoading: false,
      );
      
      // AWS에서 데이터 로드 시도
      try {
        final request = GraphQLRequest<String>(
          document: '''query ListVipProducts {
            listVipProducts {
              items {
                id
                title
                subtitle
                description
                tier
                iconColor
                isActive
                features
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
          final items = jsonData['listVipProducts']['items'] as List?;
          
          if (items != null && items.isNotEmpty) {
            final products = items
                .map((item) => VipProduct.fromJson(item as Map<String, dynamic>))
                .toList();
            
            state = state.copyWith(
              products: products,
              isLoading: false,
            );
          }
        }
      } catch (e) {
        // AWS 연결 실패 시 mock 데이터 유지
        print('AWS 연결 실패, mock 데이터 사용: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'VIP 상품을 불러오는 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Create a new product
  Future<void> createProduct({
    required String title,
    required String subtitle,
    required String description,
    required String tier,
    required String iconColor,
    bool isActive = true,
    List<String>? features,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final newProduct = VipProduct(
        title: title,
        subtitle: subtitle,
        description: description,
        tier: tier,
        iconColor: iconColor,
        isActive: isActive,
        features: features,
      );
      
      // 먼저 로컬 상태 업데이트
      final updatedProducts = List<VipProduct>.from([...state.products, newProduct]);
      state = state.copyWith(
        products: updatedProducts,
        isLoading: false,
      );
      
      // AWS에 저장 시도
      try {
        final request = GraphQLRequest<VipProduct>(
          document: '''mutation CreateVipProduct(\$input: CreateVipProductInput!) {
            createVipProduct(input: \$input) {
              id
              title
              subtitle
              description
              tier
              iconColor
              isActive
              features
              createdAt
              updatedAt
            }
          }''',
          variables: {
            'input': {
              'title': newProduct.title,
              'subtitle': newProduct.subtitle,
              'description': newProduct.description,
              'tier': newProduct.tier,
              'iconColor': newProduct.iconColor,
              'isActive': newProduct.isActive,
              'features': newProduct.features,
            }
          },
          decodePath: 'createVipProduct',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 저장 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'VIP 상품 추가 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Update an existing product
  Future<void> updateProduct(VipProduct product) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // 먼저 로컬 상태 업데이트
      final updatedProducts = List<VipProduct>.from(
        state.products.map((p) {
          return p.id == product.id ? product : p;
        })
      );
      
      state = state.copyWith(
        products: updatedProducts,
        isLoading: false,
      );
      
      // AWS에 업데이트 시도
      try {
        final request = GraphQLRequest<VipProduct>(
          document: '''mutation UpdateVipProduct(\$input: UpdateVipProductInput!) {
            updateVipProduct(input: \$input) {
              id
              title
              subtitle
              description
              tier
              iconColor
              isActive
              features
              createdAt
              updatedAt
            }
          }''',
          variables: {
            'input': {
              'id': product.id,
              'title': product.title,
              'subtitle': product.subtitle,
              'description': product.description,
              'tier': product.tier,
              'iconColor': product.iconColor,
              'isActive': product.isActive,
              'features': product.features,
            }
          },
          decodePath: 'updateVipProduct',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 업데이트 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'VIP 상품 수정 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // 먼저 로컬 상태 업데이트
      final updatedProducts = state.products.where((p) => p.id != productId).toList();
      state = state.copyWith(
        products: updatedProducts,
        isLoading: false,
      );
      
      // AWS에서 삭제 시도
      try {
        final request = GraphQLRequest<VipProduct>(
          document: '''mutation DeleteVipProduct(\$input: DeleteVipProductInput!) {
            deleteVipProduct(input: \$input) {
              id
            }
          }''',
          variables: {
            'input': {
              'id': productId,
            }
          },
          decodePath: 'deleteVipProduct',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 삭제 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'VIP 상품 삭제 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Toggle product active status
  Future<void> toggleProductStatus(String productId, bool isActive) async {
    try {
      final product = state.products.firstWhere((p) => p.id == productId);
      final updatedProduct = product.copyWith(isActive: isActive);
      await updateProduct(updatedProduct);
    } catch (e) {
      state = state.copyWith(
        error: 'VIP 상품 상태 변경 중 오류가 발생했습니다: $e',
      );
    }
  }
}