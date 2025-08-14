import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';

class ProfileViewService {
  static final ProfileViewService _instance = ProfileViewService._internal();
  factory ProfileViewService() => _instance;
  ProfileViewService._internal();

  /// 현재 사용자의 프로필 열람권 수 가져오기
  Future<int> getCurrentProfileViewTickets() async {
    try {
      // 로컬에서 먼저 확인
      final prefs = await SharedPreferences.getInstance();
      final localProfileViewTickets = prefs.getInt('user_profile_view_tickets') ?? 0;

      // AWS Cognito 사용자 정보에서 프로필 열람권 수 가져오기
      if (Amplify.isConfigured) {
        try {
          final session = await Amplify.Auth.fetchAuthSession();
          
          if (session.isSignedIn) {
            // AWS에서 사용자 속성 가져오기
            final userAttributes = await Amplify.Auth.fetchUserAttributes();
            
            for (final attribute in userAttributes) {
              if (attribute.userAttributeKey.key == 'custom:profile_view_tickets') {
                final awsProfileViewTickets = int.tryParse(attribute.value) ?? localProfileViewTickets;
                
                // AWS와 로컬이 다르면 AWS 값으로 동기화
                if (awsProfileViewTickets != localProfileViewTickets) {
                  await prefs.setInt('user_profile_view_tickets', awsProfileViewTickets);
                }
                
                Logger.log('현재 프로필 열람권 수: $awsProfileViewTickets', name: 'ProfileViewService');
                return awsProfileViewTickets;
              }
            }
          }
        } catch (e) {
          Logger.error('AWS에서 프로필 열람권 정보 가져오기 실패: $e', name: 'ProfileViewService');
        }
      }

      Logger.log('로컬 프로필 열람권 수: $localProfileViewTickets', name: 'ProfileViewService');
      return localProfileViewTickets;
    } catch (e) {
      Logger.error('프로필 열람권 수 가져오기 실패: $e', name: 'ProfileViewService');
      return 0;
    }
  }

  /// 프로필 열람권 구매 처리
  Future<bool> purchaseProfileViewTickets(int amount) async {
    try {
      Logger.log('프로필 열람권 구매 시작: $amount개', name: 'ProfileViewService');

      // 현재 프로필 열람권 수 가져오기
      final currentProfileViewTickets = await getCurrentProfileViewTickets();
      final newProfileViewTickets = currentProfileViewTickets + amount;

      // 로컬 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_profile_view_tickets', newProfileViewTickets);

      // AWS에 저장 (custom attribute가 없으면 건너뛰기)
      if (Amplify.isConfigured) {
        try {
          // custom:profile_view_tickets attribute가 스키마에 존재하는지 먼저 확인
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          bool hasProfileViewTicketsAttribute = false;
          
          for (final attribute in userAttributes) {
            if (attribute.userAttributeKey.key == 'custom:profile_view_tickets') {
              hasProfileViewTicketsAttribute = true;
              break;
            }
          }
          
          if (hasProfileViewTicketsAttribute) {
            await Amplify.Auth.updateUserAttribute(
              userAttributeKey: const CognitoUserAttributeKey.custom('profile_view_tickets'),
              value: newProfileViewTickets.toString(),
            );
            Logger.log('AWS에 프로필 열람권 정보 저장 완료', name: 'ProfileViewService');
          } else {
            Logger.log('AWS custom:profile_view_tickets 속성이 없어서 로컬 저장만 수행', name: 'ProfileViewService');
          }
        } catch (e) {
          Logger.error('AWS 프로필 열람권 정보 저장 실패: $e', name: 'ProfileViewService');
        }
      }

      Logger.log('✅ 프로필 열람권 구매 완료: $currentProfileViewTickets → $newProfileViewTickets', name: 'ProfileViewService');
      return true;
    } catch (e) {
      Logger.error('❌ 프로필 열람권 구매 실패: $e', name: 'ProfileViewService');
      return false;
    }
  }

  /// 프로필 열람권 사용
  Future<bool> spendProfileViewTickets(int amount, {String? description}) async {
    try {
      final currentProfileViewTickets = await getCurrentProfileViewTickets();
      
      if (currentProfileViewTickets < amount) {
        Logger.error('프로필 열람권 부족: 현재 $currentProfileViewTickets개, 필요 $amount개', name: 'ProfileViewService');
        return false;
      }

      final newProfileViewTickets = currentProfileViewTickets - amount;

      // 로컬 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_profile_view_tickets', newProfileViewTickets);

      // AWS에 저장 (custom attribute가 없으면 건너뛰기)
      if (Amplify.isConfigured) {
        try {
          // custom:profile_view_tickets attribute가 스키마에 존재하는지 먼저 확인
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          bool hasProfileViewTicketsAttribute = false;
          
          for (final attribute in userAttributes) {
            if (attribute.userAttributeKey.key == 'custom:profile_view_tickets') {
              hasProfileViewTicketsAttribute = true;
              break;
            }
          }
          
          if (hasProfileViewTicketsAttribute) {
            await Amplify.Auth.updateUserAttribute(
              userAttributeKey: const CognitoUserAttributeKey.custom('profile_view_tickets'),
              value: newProfileViewTickets.toString(),
            );
            Logger.log('AWS에 프로필 열람권 사용 정보 저장 완료', name: 'ProfileViewService');
          } else {
            Logger.log('AWS custom:profile_view_tickets 속성이 없어서 로컬 저장만 수행', name: 'ProfileViewService');
          }
        } catch (e) {
          Logger.error('AWS 프로필 열람권 사용 저장 실패: $e', name: 'ProfileViewService');
        }
      }

      Logger.log('✅ 프로필 열람권 사용 완료: $currentProfileViewTickets → $newProfileViewTickets', name: 'ProfileViewService');
      return true;
    } catch (e) {
      Logger.error('❌ 프로필 열람권 사용 실패: $e', name: 'ProfileViewService');
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
      Logger.error('사용자 ID 가져오기 실패: $e', name: 'ProfileViewService');
    }
    return 'unknown_user';
  }

  /// 프로필 열람권 정보 초기화 (개발/테스트용)
  Future<void> resetProfileViewTickets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_profile_view_tickets', 0);
      
      if (Amplify.isConfigured) {
        try {
          // custom:profile_view_tickets attribute가 스키마에 존재하는지 먼저 확인
          final userAttributes = await Amplify.Auth.fetchUserAttributes();
          bool hasProfileViewTicketsAttribute = false;
          
          for (final attribute in userAttributes) {
            if (attribute.userAttributeKey.key == 'custom:profile_view_tickets') {
              hasProfileViewTicketsAttribute = true;
              break;
            }
          }
          
          if (hasProfileViewTicketsAttribute) {
            await Amplify.Auth.updateUserAttribute(
              userAttributeKey: const CognitoUserAttributeKey.custom('profile_view_tickets'),
              value: '0',
            );
            Logger.log('AWS에 프로필 열람권 초기화 완료', name: 'ProfileViewService');
          } else {
            Logger.log('AWS custom:profile_view_tickets 속성이 없어서 로컬 초기화만 수행', name: 'ProfileViewService');
          }
        } catch (e) {
          Logger.error('AWS 프로필 열람권 초기화 실패: $e', name: 'ProfileViewService');
        }
      }
      
      Logger.log('프로필 열람권 정보 초기화 완료', name: 'ProfileViewService');
    } catch (e) {
      Logger.error('프로필 열람권 정보 초기화 실패: $e', name: 'ProfileViewService');
    }
  }
}