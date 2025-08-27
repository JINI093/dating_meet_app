import 'package:amplify_flutter/amplify_flutter.dart';
import '../../models/GeneralProduct.dart';

class CreateInitialProducts {
  static Future<void> createDefaultProducts() async {
    try {
      print('Creating default products...');
      
      // 1. 하트
      final heartProduct = GeneralProduct(
        id: 'heart-001',
        title: '하트',
        subtitle: '더욱 많은 이성에게 하트를 보내보세요!',
        description: '''하트로 더욱 많은 이성에게 관심을 표현할 수 있습니다.

• 일반 회원에게 보내는 하트와 같은 효과가 됩니다.
• 하트는 무제한으로 보낼 수 있으며 이성들에게 나를 더 많이 보여줍니다.
• 이성들도 나의 관심 표현을 받고 더 많은 관심을 가질 수 있습니다.''',
        iconType: 'heart',
        iconColor: '#FF6B9D',
        isActive: true,
        category: 'hearts',
      );
      
      // 2. 슈퍼챗
      final superChatProduct = GeneralProduct(
        id: 'superchat-001',
        title: '슈퍼챗',
        subtitle: '더욱 많은 이성에게 슈퍼챗을 보내보세요!',
        description: '''슈퍼챗으로 마음에 드는 이성과 대화를 시작해 보세요!

• 슈퍼챗으로 이성에게 메시지를 보낼 수 있습니다.
• 슈퍼챗을 받은 이성이 회신하면 슈퍼챗 대화를 진행합니다.
• 이성이 슈퍼챗을 다시 보내거나 무시할 때까지 대화가 유지됩니다.
• 슈퍼챗으로 더 적극적인 관심 표현이 가능합니다.''',
        iconType: 'chat',
        iconColor: '#66D364',
        isActive: true,
        category: 'superchat',
      );
      
      // 3. 프로필 열람권
      final profileViewProduct = GeneralProduct(
        id: 'profile-view-001',
        title: '프로필 열람권',
        subtitle: '나를 좋아한 이성은 누구?',
        description: '''프로필 열람권으로 나를 좋아한 이성의 정보를 확인하세요!

• 나를 좋아한 이성이 누구인지 프로필을 확인할 수 있습니다.
• 평소 궁금했던 이성의 정보를 바로 확인해보세요.
• 상대방의 프로필을 보고 매칭 여부를 결정할 수 있습니다.''',
        iconType: 'profile',
        iconColor: '#4A90E2',
        isActive: true,
        category: 'profile',
      );
      
      // 4. 추천카드 더 보기
      final recommendCardProduct = GeneralProduct(
        id: 'recommend-card-001',
        title: '추천카드 더 보기',
        subtitle: '더욱 나에게 맞는 이성을 추천 받아보세요!',
        description: '''더욱 많은 이성이 당신을 기다리고 있습니다!

• 추천 카드는 매일 10명 무료로 확인할 수 있습니다.
• 추가로 매일 원하는 만큼 더 많은 이성을 볼 수 있습니다.
• 더 많은 VIP 회원들의 프로필도 무제한으로 볼 수 있습니다.
• 추천 카드 더보기로 더욱 많은 이성을 확인해보세요!
• 이상형에 가까운 이성이 당신을 기다리고 있습니다.
• 지금 바로 더 많은 이성과의 만남의 기회를 늘려보세요.''',
        iconType: 'stack',
        iconColor: '#FFB74D',
        isActive: true,
        category: 'recommend',
      );
      
      // AWS에 상품 생성
      final products = [heartProduct, superChatProduct, profileViewProduct, recommendCardProduct];
      
      for (final product in products) {
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
                'id': product.id,
                'title': product.title,
                'subtitle': product.subtitle,
                'description': product.description,
                'iconType': product.iconType,
                'iconColor': product.iconColor,
                'isActive': product.isActive,
                'category': product.category,
              }
            },
            decodePath: 'createGeneralProduct',
          );
          
          final response = await Amplify.API.mutate(request: request).response;
          
          if (response.errors.isEmpty) {
            print('✅ Created product: ${product.title}');
          } else {
            print('❌ Error creating ${product.title}: ${response.errors}');
          }
        } catch (e) {
          print('❌ Failed to create ${product.title}: $e');
        }
      }
      
      print('✨ Initial products creation completed!');
    } catch (e) {
      print('❌ Error in createDefaultProducts: $e');
    }
  }
}