import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';

class RecommendCardService {
  static final RecommendCardService _instance = RecommendCardService._internal();
  factory RecommendCardService() => _instance;
  RecommendCardService._internal();

  /// 현재 사용자의 추천카드 더보기 수 가져오기
  Future<int> getCurrentRecommendCards() async {
    try {
      // 로컬에서 먼저 확인
      final prefs = await SharedPreferences.getInstance();
      final localRecommendCards = prefs.getInt('user_recommend_cards') ?? 0;

      // AWS Cognito 사용자 정보에서 추천카드 수 가져오기
      if (Amplify.isConfigured) {
        print("=======> login compelete");
        try {
          final session = await Amplify.Auth.fetchAuthSession();
          
          if (session.isSignedIn) {
            // AWS에서 사용자 속성 가져오기
            final userAttributes = await Amplify.Auth.fetchUserAttributes();
            
            for (final attribute in userAttributes) {
              if (attribute.userAttributeKey.key == 'custom:recommend_cards') {
                final awsRecommendCards = int.tryParse(attribute.value) ?? localRecommendCards;
                print("awsRecommendCards=======> ${awsRecommendCards}");

                // AWS와 로컬이 다르면 AWS 값으로 동기화
                if (awsRecommendCards != localRecommendCards) {
                  await prefs.setInt('user_recommend_cards', awsRecommendCards);
                }
                
                Logger.log('현재 추천카드 더보기 수: $awsRecommendCards', name: 'RecommendCardService');
                return awsRecommendCards;
              }
            }
          }
        } catch (e) {
          Logger.error('AWS에서 추천카드 정보 가져오기 실패: $e', name: 'RecommendCardService');
        }
      }
      print("=======> login failed");

      Logger.log('로컬 추천카드 더보기 수: $localRecommendCards', name: 'RecommendCardService');
      return localRecommendCards;
    } catch (e) {
      Logger.error('추천카드 더보기 수 가져오기 실패: $e', name: 'RecommendCardService');
      return 0;
    }
  }

  /// 추천카드 더보기 구매 처리
  Future<bool> purchaseRecommendCards(int amount) async {
    try {
      Logger.log('추천카드 더보기 구매 시작: $amount개', name: 'RecommendCardService');

      // 현재 추천카드 수 가져오기
      final currentRecommendCards = await getCurrentRecommendCards();
      final newRecommendCards = currentRecommendCards + amount;

      // 로컬 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_recommend_cards', newRecommendCards);

      // AWS에 저장 (custom attribute가 없으면 건너뛰기)
      if (Amplify.isConfigured) {
        try {
          // custom:recommend_cards attribute가 스키마에 존재하는지 먼저 확인
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          bool hasRecommendCardsAttribute = false;
          
          for (final attribute in userAttributes) {
            if (attribute.userAttributeKey.key == 'custom:recommend_cards') {
              hasRecommendCardsAttribute = true;
              break;
            }
          }
          
          if (hasRecommendCardsAttribute) {
            await Amplify.Auth.updateUserAttribute(
              userAttributeKey: const CognitoUserAttributeKey.custom('recommend_cards'),
              value: newRecommendCards.toString(),
            );
            Logger.log('AWS에 추천카드 정보 저장 완료', name: 'RecommendCardService');
          } else {
            Logger.log('AWS custom:recommend_cards 속성이 없어서 로컬 저장만 수행', name: 'RecommendCardService');
          }
        } catch (e) {
          Logger.error('AWS 추천카드 정보 저장 실패: $e', name: 'RecommendCardService');
        }
      }

      Logger.log('✅ 추천카드 더보기 구매 완료: $currentRecommendCards → $newRecommendCards', name: 'RecommendCardService');
      return true;
    } catch (e) {
      Logger.error('❌ 추천카드 더보기 구매 실패: $e', name: 'RecommendCardService');
      return false;
    }
  }

  /// 추천카드 더보기 사용
  Future<bool> spendRecommendCards(int amount, {String? description}) async {
    try {
      final currentRecommendCards = await getCurrentRecommendCards();
      
      if (currentRecommendCards < amount) {
        Logger.error('추천카드 더보기 부족: 현재 $currentRecommendCards개, 필요 $amount개', name: 'RecommendCardService');
        return false;
      }

      final newRecommendCards = currentRecommendCards - amount;

      // 로컬 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_recommend_cards', newRecommendCards);

      // AWS에 저장 (custom attribute가 없으면 건너뛰기)
      if (Amplify.isConfigured) {
        try {
          // custom:recommend_cards attribute가 스키마에 존재하는지 먼저 확인
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          bool hasRecommendCardsAttribute = false;
          
          for (final attribute in userAttributes) {
            if (attribute.userAttributeKey.key == 'custom:recommend_cards') {
              hasRecommendCardsAttribute = true;
              break;
            }
          }
          
          if (hasRecommendCardsAttribute) {
            await Amplify.Auth.updateUserAttribute(
              userAttributeKey: const CognitoUserAttributeKey.custom('recommend_cards'),
              value: newRecommendCards.toString(),
            );
            Logger.log('AWS에 추천카드 사용 정보 저장 완료', name: 'RecommendCardService');
          } else {
            Logger.log('AWS custom:recommend_cards 속성이 없어서 로컬 저장만 수행', name: 'RecommendCardService');
          }
        } catch (e) {
          Logger.error('AWS 추천카드 사용 저장 실패: $e', name: 'RecommendCardService');
        }
      }

      Logger.log('✅ 추천카드 더보기 사용 완료: $currentRecommendCards → $newRecommendCards', name: 'RecommendCardService');
      return true;
    } catch (e) {
      Logger.error('❌ 추천카드 더보기 사용 실패: $e', name: 'RecommendCardService');
      return false;
    }
  }

  /// 현재 사용자 ID 가져오기
  Future<String> _getCurrentUserId() async {
    try {
      if (Amplify.isConfigured) {
        final user = await Amplify.Auth.getCurrentUser();
        return user.userId;
      }
    } catch (e) {
      Logger.error('사용자 ID 가져오기 실패: $e', name: 'RecommendCardService');
    }
    return 'unknown_user';
  }

  /// 추천카드 정보 초기화 (개발/테스트용)
  Future<void> resetRecommendCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_recommend_cards', 0);
      
      if (Amplify.isConfigured) {
        try {
          // custom:recommend_cards attribute가 스키마에 존재하는지 먼저 확인
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          bool hasRecommendCardsAttribute = false;
          
          for (final attribute in userAttributes) {
            if (attribute.userAttributeKey.key == 'custom:recommend_cards') {
              hasRecommendCardsAttribute = true;
              break;
            }
          }
          
          if (hasRecommendCardsAttribute) {
            await Amplify.Auth.updateUserAttribute(
              userAttributeKey: const CognitoUserAttributeKey.custom('recommend_cards'),
              value: '0',
            );
            Logger.log('AWS에 추천카드 초기화 완료', name: 'RecommendCardService');
          } else {
            Logger.log('AWS custom:recommend_cards 속성이 없어서 로컬 초기화만 수행', name: 'RecommendCardService');
          }
        } catch (e) {
          Logger.error('AWS 추천카드 초기화 실패: $e', name: 'RecommendCardService');
        }
      }
      
      Logger.log('추천카드 정보 초기화 완료', name: 'RecommendCardService');
    } catch (e) {
      Logger.error('추천카드 정보 초기화 실패: $e', name: 'RecommendCardService');
    }
  }
}