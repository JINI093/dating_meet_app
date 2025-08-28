import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:convert';
import '../../models/GeneralProduct.dart';
import '../../models/ModelProvider.dart';

// Provider for general products
final generalProductsProvider = StateNotifierProvider<GeneralProductsNotifier, GeneralProductsState>((ref) {
  return GeneralProductsNotifier();
});

// State class
class GeneralProductsState {
  final List<GeneralProduct> products;
  final bool isLoading;
  final String? error;

  GeneralProductsState({
    required this.products,
    required this.isLoading,
    this.error,
  });

  GeneralProductsState copyWith({
    List<GeneralProduct>? products,
    bool? isLoading,
    String? error,
  }) {
    return GeneralProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier class
class GeneralProductsNotifier extends StateNotifier<GeneralProductsState> {
  GeneralProductsNotifier() : super(GeneralProductsState(products: [], isLoading: false)) {
    loadProducts();
  }

  // Mock data for initial display
  List<GeneralProduct> _getMockProducts() {
    return [
      GeneralProduct(
        id: '1',
        title: '하트',
        subtitle: '더욱 많은 이성에게 하트를 보내보세요!',
        description: '하트로 더욱 많은 이성에게 관심을 표현할 수 있습니다!\n\n• 이성 한명에게 보내는 하트의 수는 제한이 없습니다.\n• 하트는 호감 어필의 용도로 관심있는 이성에게 나를 어필해보세요!\n• 이벤트는 사전 고지 없이 종료 또는 변경 될 수 있습니다.',
        iconType: 'heart',
        iconColor: '#FF6B9D',
        isActive: true,
      ),
      GeneralProduct(
        id: '2',
        title: '슈퍼챗',
        subtitle: '더욱 많은 이성에게 슈퍼챗을 보내보세요!',
        description: '슈퍼챗으로 마음에 드는 이성과 대화를 이루어 보세요!\n\n• 슈퍼챗으로 이성에게 메시지를 보낼 수 있습니다.\n• 슈퍼챗을 받은 이성이 좋아요를 누르면 대화로 연결됩니다.\n• 이성이 슈퍼챗을 5일간 읽지 않거나 거부하면 발송 당시 소모했던 슈퍼챗은 다시 회수됩니다. 부담 없이 즐겨보세요!',
        iconType: 'chat',
        iconColor: '#66D364',
        isActive: true,
      ),
      GeneralProduct(
        id: '3',
        title: '프로필 열람권',
        subtitle: '나를 픽한 이성은 누구?',
        description: '프로필 열람권으로 나를 픽한 이성의 정보를 확인해보세요!\n\n• 나를 픽한 이성이 누구인지 알고 싶은 프로필 열람권을 사용하여 확인해보세요!',
        iconType: 'profile',
        iconColor: '#4A90E2',
        isActive: false,
      ),
      GeneralProduct(
        id: '4',
        title: '추천카드 더 보기',
        subtitle: '아직 마음에 드는 이성을 찾지 못하셨나요?',
        description: '더욱 많은 이성이 여러분을 기다리고 있습니다!\n\n• 추천 카드는 매일 10명 무료로 확인해 보실 수 있습니다.\n• 추가로 매달 인기 회원 20명 무료로 볼 수 있습니다.\n•• 내 주변 VIP 회원들은 추천카드 횟수 상관없이 볼 수 있습니다.\n• 추천 카드 더보기 상품으로 더욱 많은 이성을 확인해보세요! 아직 많은 이성이 여러분을 만나길 기다리고 있습니다.\n• 할인 이벤트나 적립 이벤트는 예고 없이 종료, 변경 될 수 있습니다.',
        iconType: 'stack',
        iconColor: '#FFB74D',
        isActive: true,
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
          document: '''query ListGeneralProducts {
            listGeneralProducts {
              items {
                id
                title
                subtitle
                description
                iconType
                iconColor
                isActive
                price
                category
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
          final items = jsonData['listGeneralProducts']['items'] as List?;
          
          if (items != null && items.isNotEmpty) {
            final products = items
                .map((item) => GeneralProduct.fromJson(item as Map<String, dynamic>))
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
        error: '상품을 불러오는 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Create a new product
  Future<void> createProduct({
    required String title,
    required String subtitle,
    required String description,
    required String iconType,
    required String iconColor,
    bool isActive = true,
    double? price,
    String? category,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final newProduct = GeneralProduct(
        title: title,
        subtitle: subtitle,
        description: description,
        iconType: iconType,
        iconColor: iconColor,
        isActive: isActive,
        price: price,
        category: category,
      );
      
      // 먼저 로컬 상태 업데이트
      final updatedProducts = List<GeneralProduct>.from([...state.products, newProduct]);
      state = state.copyWith(
        products: updatedProducts,
        isLoading: false,
      );
      
      // AWS에 저장 시도
      try {
        final request = GraphQLRequest<GeneralProduct>(
          document: '''mutation CreateGeneralProduct(\$input: CreateGeneralProductInput!) {
            createGeneralProduct(input: \$input) {
              id
              title
              subtitle
              description
              iconType
              iconColor
              isActive
              price
              category
              createdAt
              updatedAt
            }
          }''',
          variables: {
            'input': {
              'title': newProduct.title,
              'subtitle': newProduct.subtitle,
              'description': newProduct.description,
              'iconType': newProduct.iconType,
              'iconColor': newProduct.iconColor,
              'isActive': newProduct.isActive,
              'price': newProduct.price,
              'category': newProduct.category,
            }
          },
          decodePath: 'createGeneralProduct',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 저장 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '상품 추가 중 오류가 발생했습니다: $e',
      );
    }
  }

  // Update an existing product
  Future<void> updateProduct(GeneralProduct product) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // 먼저 로컬 상태 업데이트
      final updatedProducts = List<GeneralProduct>.from(
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
        final request = GraphQLRequest<GeneralProduct>(
          document: '''mutation UpdateGeneralProduct(\$input: UpdateGeneralProductInput!) {
            updateGeneralProduct(input: \$input) {
              id
              title
              subtitle
              description
              iconType
              iconColor
              isActive
              price
              category
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
              'iconType': product.iconType,
              'iconColor': product.iconColor,
              'isActive': product.isActive,
              'price': product.price,
              'category': product.category,
            }
          },
          decodePath: 'updateGeneralProduct',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 업데이트 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '상품 수정 중 오류가 발생했습니다: $e',
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
        final request = GraphQLRequest<GeneralProduct>(
          document: '''mutation DeleteGeneralProduct(\$input: DeleteGeneralProductInput!) {
            deleteGeneralProduct(input: \$input) {
              id
            }
          }''',
          variables: {
            'input': {
              'id': productId,
            }
          },
          decodePath: 'deleteGeneralProduct',
        );
        await Amplify.API.mutate(request: request).response;
      } catch (e) {
        print('AWS 삭제 실패: $e');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '상품 삭제 중 오류가 발생했습니다: $e',
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
        error: '상품 상태 변경 중 오류가 발생했습니다: $e',
      );
    }
  }
}