import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/superchat_model.dart';
import '../utils/logger.dart';

class SuperChatService {
  static final SuperChatService _instance = SuperChatService._internal();
  factory SuperChatService() => _instance;
  SuperChatService._internal();

  // 슈퍼챗 패키지 목록 (보너스 포함)
  static const List<Map<String, dynamic>> _superChatPackages = [
    {'id': 1, 'baseCount': 1, 'bonusCount': 0, 'price': 50},
    {'id': 2, 'baseCount': 3, 'bonusCount': 0, 'price': 150},
    {'id': 3, 'baseCount': 5, 'bonusCount': 1, 'price': 250, 'bonusIconPath': 'assets/icons/m_super1.png'},
    {'id': 4, 'baseCount': 10, 'bonusCount': 3, 'price': 500, 'bonusIconPath': 'assets/icons/m_super2.png'},
    {'id': 5, 'baseCount': 15, 'bonusCount': 5, 'price': 750, 'bonusIconPath': 'assets/icons/m_super3.png'},
    {'id': 6, 'baseCount': 20, 'bonusCount': 8, 'price': 1000, 'bonusIconPath': 'assets/icons/m_super4.png'},
    {'id': 7, 'baseCount': 30, 'bonusCount': 12, 'price': 1500, 'bonusIconPath': 'assets/icons/m_super5.png'},
    {'id': 8, 'baseCount': 50, 'bonusCount': 18, 'price': 2500, 'bonusIconPath': 'assets/icons/m_super6.png'},
    {'id': 9, 'baseCount': 80, 'bonusCount': 32, 'price': 4000, 'bonusIconPath': 'assets/icons/m_super7.png'},
    {'id': 10, 'baseCount': 100, 'bonusCount': 42, 'price': 5000, 'bonusIconPath': 'assets/icons/m_super8.png'},
    {'id': 11, 'baseCount': 150, 'bonusCount': 62, 'price': 7500, 'bonusIconPath': 'assets/icons/m_super9.png'},
    {'id': 12, 'baseCount': 200, 'bonusCount': 85, 'price': 10000, 'bonusIconPath': 'assets/icons/m_super10.png'},
  ];

  /// 사용 가능한 슈퍼챗 패키지 목록 가져오기
  List<SuperChatPackage> getSuperChatPackages() {
    return _superChatPackages.map((data) => SuperChatPackage.fromJson(data)).toList();
  }

  /// 현재 사용자의 슈퍼챗 수 가져오기
  Future<int> getCurrentSuperChats() async {
    try {
      // 로컬에서 먼저 확인
      final prefs = await SharedPreferences.getInstance();
      final localSuperChats = prefs.getInt('user_superchats') ?? 0;

      // AWS Cognito 사용자 정보에서 슈퍼챗 수 가져오기
      if (Amplify.isConfigured) {
        try {
          final session = await Amplify.Auth.fetchAuthSession();
          
          if (session.isSignedIn) {
            // AWS에서 사용자 속성 가져오기
            final userAttributes = await Amplify.Auth.fetchUserAttributes();
            
            for (final attribute in userAttributes) {
              if (attribute.userAttributeKey.key == 'custom:superchats') {
                final awsSuperChats = int.tryParse(attribute.value) ?? localSuperChats;
                
                // AWS와 로컬이 다르면 AWS 값으로 동기화
                if (awsSuperChats != localSuperChats) {
                  await prefs.setInt('user_superchats', awsSuperChats);
                }
                
                Logger.log('현재 슈퍼챗 수: $awsSuperChats', name: 'SuperChatService');
                return awsSuperChats;
              }
            }
          }
        } catch (e) {
          Logger.error('AWS에서 슈퍼챗 정보 가져오기 실패: $e', name: 'SuperChatService');
        }
      }

      Logger.log('로컬 슈퍼챗 수: $localSuperChats', name: 'SuperChatService');
      return localSuperChats;
    } catch (e) {
      Logger.error('슈퍼챗 수 가져오기 실패: $e', name: 'SuperChatService');
      return 0;
    }
  }

  /// 슈퍼챗 구매 처리
  Future<bool> purchaseSuperChats(SuperChatPackage package) async {
    try {
      Logger.log('슈퍼챗 구매 시작: ${package.baseCount} + ${package.bonusCount}개 (${package.price}P)', name: 'SuperChatService');

      // 현재 슈퍼챗 수 가져오기
      final currentSuperChats = await getCurrentSuperChats();
      final newSuperChats = currentSuperChats + package.totalCount;

      // 로컬 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_superchats', newSuperChats);

      // AWS에 저장 (custom attribute가 없으면 건너뛰기)
      if (Amplify.isConfigured) {
        try {
          // custom:superchats attribute가 스키마에 존재하는지 먼저 확인
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          bool hasSuperChatsAttribute = false;
          
          for (final attribute in userAttributes) {
            if (attribute.userAttributeKey.key == 'custom:superchats') {
              hasSuperChatsAttribute = true;
              break;
            }
          }
          
          if (hasSuperChatsAttribute) {
            await Amplify.Auth.updateUserAttribute(
              userAttributeKey: const CognitoUserAttributeKey.custom('superchats'),
              value: newSuperChats.toString(),
            );
            Logger.log('AWS에 슈퍼챗 정보 저장 완료', name: 'SuperChatService');
          } else {
            Logger.log('AWS custom:superchats 속성이 없어서 로컬 저장만 수행', name: 'SuperChatService');
          }
        } catch (e) {
          Logger.error('AWS 슈퍼챗 정보 저장 실패: $e', name: 'SuperChatService');
          // AWS 실패해도 로컬은 성공으로 처리
        }
      }

      // 구매 내역 저장
      await _saveSuperChatTransaction(SuperChatTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: await _getCurrentUserId(),
        amount: package.totalCount,
        type: 'purchase',
        description: '슈퍼챗 ${package.baseCount}개 + 보너스 ${package.bonusCount}개 구매',
        timestamp: DateTime.now(),
      ));

      Logger.log('✅ 슈퍼챗 구매 완료: $currentSuperChats → $newSuperChats', name: 'SuperChatService');
      return true;
    } catch (e) {
      Logger.error('❌ 슈퍼챗 구매 실패: $e', name: 'SuperChatService');
      return false;
    }
  }

  /// 슈퍼챗 사용
  Future<bool> spendSuperChats(int amount, {String? description}) async {
    try {
      final currentSuperChats = await getCurrentSuperChats();
      
      if (currentSuperChats < amount) {
        Logger.error('슈퍼챗 부족: 현재 $currentSuperChats개, 필요 $amount개', name: 'SuperChatService');
        return false;
      }

      final newSuperChats = currentSuperChats - amount;

      // 로컬 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_superchats', newSuperChats);

      // AWS에 저장 (custom attribute가 없으면 건너뛰기)
      if (Amplify.isConfigured) {
        try {
          // custom:superchats attribute가 스키마에 존재하는지 먼저 확인
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          bool hasSuperChatsAttribute = false;
          
          for (final attribute in userAttributes) {
            if (attribute.userAttributeKey.key == 'custom:superchats') {
              hasSuperChatsAttribute = true;
              break;
            }
          }
          
          if (hasSuperChatsAttribute) {
            await Amplify.Auth.updateUserAttribute(
              userAttributeKey: const CognitoUserAttributeKey.custom('superchats'),
              value: newSuperChats.toString(),
            );
            Logger.log('AWS에 슈퍼챗 사용 정보 저장 완료', name: 'SuperChatService');
          } else {
            Logger.log('AWS custom:superchats 속성이 없어서 로컬 저장만 수행', name: 'SuperChatService');
          }
        } catch (e) {
          Logger.error('AWS 슈퍼챗 사용 저장 실패: $e', name: 'SuperChatService');
        }
      }

      // 사용 내역 저장
      await _saveSuperChatTransaction(SuperChatTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: await _getCurrentUserId(),
        amount: -amount,
        type: 'spend',
        description: description ?? '슈퍼챗 $amount개 사용',
        timestamp: DateTime.now(),
      ));

      Logger.log('✅ 슈퍼챗 사용 완료: $currentSuperChats → $newSuperChats', name: 'SuperChatService');
      return true;
    } catch (e) {
      Logger.error('❌ 슈퍼챗 사용 실패: $e', name: 'SuperChatService');
      return false;
    }
  }

  /// 슈퍼챗 거래 내역 저장
  Future<void> _saveSuperChatTransaction(SuperChatTransaction transaction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactions = prefs.getStringList('superchat_transactions') ?? [];
      
      transactions.add(jsonEncode(transaction.toJson()));
      
      // 최근 100개만 유지
      if (transactions.length > 100) {
        transactions.removeAt(0);
      }
      
      await prefs.setStringList('superchat_transactions', transactions);
      Logger.log('슈퍼챗 거래 내역 저장 완료', name: 'SuperChatService');
    } catch (e) {
      Logger.error('슈퍼챗 거래 내역 저장 실패: $e', name: 'SuperChatService');
    }
  }

  /// 슈퍼챗 거래 내역 가져오기
  Future<List<SuperChatTransaction>> getSuperChatTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactions = prefs.getStringList('superchat_transactions') ?? [];
      
      return transactions
          .map((json) => SuperChatTransaction.fromJson(jsonDecode(json)))
          .toList()
          .reversed
          .toList(); // 최신순으로 정렬
    } catch (e) {
      Logger.error('슈퍼챗 거래 내역 가져오기 실패: $e', name: 'SuperChatService');
      return [];
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
      Logger.error('사용자 ID 가져오기 실패: $e', name: 'SuperChatService');
    }
    return 'unknown_user';
  }

  /// 슈퍼챗 정보 초기화 (개발/테스트용)
  Future<void> resetSuperChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_superchats', 0);
      await prefs.remove('superchat_transactions');
      
      if (Amplify.isConfigured) {
        try {
          // custom:superchats attribute가 스키마에 존재하는지 먼저 확인
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          bool hasSuperChatsAttribute = false;
          
          for (final attribute in userAttributes) {
            if (attribute.userAttributeKey.key == 'custom:superchats') {
              hasSuperChatsAttribute = true;
              break;
            }
          }
          
          if (hasSuperChatsAttribute) {
            await Amplify.Auth.updateUserAttribute(
              userAttributeKey: const CognitoUserAttributeKey.custom('superchats'),
              value: '0',
            );
            Logger.log('AWS에 슈퍼챗 초기화 완료', name: 'SuperChatService');
          } else {
            Logger.log('AWS custom:superchats 속성이 없어서 로컬 초기화만 수행', name: 'SuperChatService');
          }
        } catch (e) {
          Logger.error('AWS 슈퍼챗 초기화 실패: $e', name: 'SuperChatService');
        }
      }
      
      Logger.log('슈퍼챗 정보 초기화 완료', name: 'SuperChatService');
    } catch (e) {
      Logger.error('슈퍼챗 정보 초기화 실패: $e', name: 'SuperChatService');
    }
  }
}