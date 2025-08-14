import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/heart_model.dart';
import '../utils/logger.dart';

class HeartService {
  static final HeartService _instance = HeartService._internal();
  factory HeartService() => _instance;
  HeartService._internal();

  // 하트 패키지 목록 (보너스 포함)
  static const List<Map<String, dynamic>> _heartPackages = [
    {'id': 1, 'baseCount': 1, 'bonusCount': 0, 'price': 10},
    {'id': 2, 'baseCount': 3, 'bonusCount': 0, 'price': 30},
    {'id': 3, 'baseCount': 5, 'bonusCount': 0, 'price': 50},
    {'id': 4, 'baseCount': 10, 'bonusCount': 2, 'price': 100, 'bonusIconPath': 'assets/icons/m_heart1.png'},
    {'id': 5, 'baseCount': 15, 'bonusCount': 5, 'price': 150, 'bonusIconPath': 'assets/icons/m_heart1.png'},
    {'id': 6, 'baseCount': 20, 'bonusCount': 10, 'price': 200, 'bonusIconPath': 'assets/icons/m_heart1.png'},
    {'id': 7, 'baseCount': 30, 'bonusCount': 15, 'price': 300, 'bonusIconPath': 'assets/icons/m_heart1.png'},
    {'id': 8, 'baseCount': 50, 'bonusCount': 25, 'price': 500, 'bonusIconPath': 'assets/icons/m_heart1.png'},
    {'id': 9, 'baseCount': 80, 'bonusCount': 40, 'price': 800, 'bonusIconPath': 'assets/icons/m_heart1.png'},
    {'id': 10, 'baseCount': 100, 'bonusCount': 60, 'price': 1000, 'bonusIconPath': 'assets/icons/m_heart1.png'},
    {'id': 11, 'baseCount': 150, 'bonusCount': 100, 'price': 1500, 'bonusIconPath': 'assets/icons/m_heart1.png'},
    {'id': 12, 'baseCount': 200, 'bonusCount': 200, 'price': 2000, 'bonusIconPath': 'assets/icons/m_heart1.png'},
  ];

  /// 사용 가능한 하트 패키지 목록 가져오기
  List<HeartPackage> getHeartPackages() {
    return _heartPackages.map((data) => HeartPackage.fromJson(data)).toList();
  }

  /// 현재 사용자의 하트 수 가져오기
  Future<int> getCurrentHearts() async {
    try {
      // 로컬에서 먼저 확인
      final prefs = await SharedPreferences.getInstance();
      final localHearts = prefs.getInt('user_hearts') ?? 0;

      // AWS Cognito 사용자 정보에서 하트 수 가져오기
      if (Amplify.isConfigured) {
        try {
          final session = await Amplify.Auth.fetchAuthSession();
          
          if (session.isSignedIn) {
            // AWS에서 사용자 속성 가져오기
            final userAttributes = await Amplify.Auth.fetchUserAttributes();
            
            for (final attribute in userAttributes) {
              if (attribute.userAttributeKey.key == 'custom:hearts') {
                final awsHearts = int.tryParse(attribute.value) ?? localHearts;
                
                // AWS와 로컬이 다르면 AWS 값으로 동기화
                if (awsHearts != localHearts) {
                  await prefs.setInt('user_hearts', awsHearts);
                }
                
                Logger.log('현재 하트 수: $awsHearts', name: 'HeartService');
                return awsHearts;
              }
            }
          }
        } catch (e) {
          Logger.error('AWS에서 하트 정보 가져오기 실패: $e', name: 'HeartService');
        }
      }

      Logger.log('로컬 하트 수: $localHearts', name: 'HeartService');
      return localHearts;
    } catch (e) {
      Logger.error('하트 수 가져오기 실패: $e', name: 'HeartService');
      return 0;
    }
  }

  /// 하트 구매 처리
  Future<bool> purchaseHearts(HeartPackage package) async {
    try {
      Logger.log('하트 구매 시작: ${package.baseCount} + ${package.bonusCount}개 (${package.price}P)', name: 'HeartService');

      // 현재 하트 수 가져오기
      final currentHearts = await getCurrentHearts();
      final newHearts = currentHearts + package.totalCount;

      // 로컬 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_hearts', newHearts);

      // AWS에 저장 (custom attribute가 없으면 건너뛰기)
      if (Amplify.isConfigured) {
        try {
          // custom:hearts attribute가 스키마에 존재하는지 먼저 확인
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          bool hasHeartsAttribute = false;
          
          for (final attribute in userAttributes) {
            if (attribute.userAttributeKey.key == 'custom:hearts') {
              hasHeartsAttribute = true;
              break;
            }
          }
          
          if (hasHeartsAttribute) {
            await Amplify.Auth.updateUserAttribute(
              userAttributeKey: const CognitoUserAttributeKey.custom('hearts'),
              value: newHearts.toString(),
            );
            Logger.log('AWS에 하트 정보 저장 완료', name: 'HeartService');
          } else {
            Logger.log('AWS custom:hearts 속성이 없어서 로컬 저장만 수행', name: 'HeartService');
          }
        } catch (e) {
          Logger.error('AWS 하트 정보 저장 실패: $e', name: 'HeartService');
          // AWS 실패해도 로컬은 성공으로 처리
        }
      }

      // 구매 내역 저장
      await _saveHeartTransaction(HeartTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: await _getCurrentUserId(),
        amount: package.totalCount,
        type: 'purchase',
        description: '하트 ${package.baseCount}개 + 보너스 ${package.bonusCount}개 구매',
        timestamp: DateTime.now(),
      ));

      Logger.log('✅ 하트 구매 완료: $currentHearts → $newHearts', name: 'HeartService');
      return true;
    } catch (e) {
      Logger.error('❌ 하트 구매 실패: $e', name: 'HeartService');
      return false;
    }
  }

  /// 하트 사용 (하트 보내기)
  Future<bool> spendHearts(int amount, {String? description}) async {
    try {
      final currentHearts = await getCurrentHearts();
      
      if (currentHearts < amount) {
        Logger.error('하트 부족: 현재 $currentHearts개, 필요 $amount개', name: 'HeartService');
        return false;
      }

      final newHearts = currentHearts - amount;

      // 로컬 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_hearts', newHearts);

      // AWS에 저장 (custom attribute가 없으면 건너뛰기)
      if (Amplify.isConfigured) {
        try {
          // custom:hearts attribute가 스키마에 존재하는지 먼저 확인
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          bool hasHeartsAttribute = false;
          
          for (final attribute in userAttributes) {
            if (attribute.userAttributeKey.key == 'custom:hearts') {
              hasHeartsAttribute = true;
              break;
            }
          }
          
          if (hasHeartsAttribute) {
            await Amplify.Auth.updateUserAttribute(
              userAttributeKey: const CognitoUserAttributeKey.custom('hearts'),
              value: newHearts.toString(),
            );
            Logger.log('AWS에 하트 사용 정보 저장 완료', name: 'HeartService');
          } else {
            Logger.log('AWS custom:hearts 속성이 없어서 로컬 저장만 수행', name: 'HeartService');
          }
        } catch (e) {
          Logger.error('AWS 하트 사용 저장 실패: $e', name: 'HeartService');
        }
      }

      // 사용 내역 저장
      await _saveHeartTransaction(HeartTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: await _getCurrentUserId(),
        amount: -amount,
        type: 'spend',
        description: description ?? '하트 $amount개 사용',
        timestamp: DateTime.now(),
      ));

      Logger.log('✅ 하트 사용 완료: $currentHearts → $newHearts', name: 'HeartService');
      return true;
    } catch (e) {
      Logger.error('❌ 하트 사용 실패: $e', name: 'HeartService');
      return false;
    }
  }

  /// 하트 거래 내역 저장
  Future<void> _saveHeartTransaction(HeartTransaction transaction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactions = prefs.getStringList('heart_transactions') ?? [];
      
      transactions.add(jsonEncode(transaction.toJson()));
      
      // 최근 100개만 유지
      if (transactions.length > 100) {
        transactions.removeAt(0);
      }
      
      await prefs.setStringList('heart_transactions', transactions);
      Logger.log('하트 거래 내역 저장 완료', name: 'HeartService');
    } catch (e) {
      Logger.error('하트 거래 내역 저장 실패: $e', name: 'HeartService');
    }
  }

  /// 하트 거래 내역 가져오기
  Future<List<HeartTransaction>> getHeartTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactions = prefs.getStringList('heart_transactions') ?? [];
      
      return transactions
          .map((json) => HeartTransaction.fromJson(jsonDecode(json)))
          .toList()
          .reversed
          .toList(); // 최신순으로 정렬
    } catch (e) {
      Logger.error('하트 거래 내역 가져오기 실패: $e', name: 'HeartService');
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
      Logger.error('사용자 ID 가져오기 실패: $e', name: 'HeartService');
    }
    return 'unknown_user';
  }

  /// 하트 정보 초기화 (개발/테스트용)
  Future<void> resetHearts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_hearts', 0);
      await prefs.remove('heart_transactions');
      
      if (Amplify.isConfigured) {
        try {
          // custom:hearts attribute가 스키마에 존재하는지 먼저 확인
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          bool hasHeartsAttribute = false;
          
          for (final attribute in userAttributes) {
            if (attribute.userAttributeKey.key == 'custom:hearts') {
              hasHeartsAttribute = true;
              break;
            }
          }
          
          if (hasHeartsAttribute) {
            await Amplify.Auth.updateUserAttribute(
              userAttributeKey: const CognitoUserAttributeKey.custom('hearts'),
              value: '0',
            );
            Logger.log('AWS에 하트 초기화 완료', name: 'HeartService');
          } else {
            Logger.log('AWS custom:hearts 속성이 없어서 로컬 초기화만 수행', name: 'HeartService');
          }
        } catch (e) {
          Logger.error('AWS 하트 초기화 실패: $e', name: 'HeartService');
        }
      }
      
      Logger.log('하트 정보 초기화 완료', name: 'HeartService');
    } catch (e) {
      Logger.error('하트 정보 초기화 실패: $e', name: 'HeartService');
    }
  }
}