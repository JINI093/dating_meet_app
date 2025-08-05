import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_benefit_counter.dart';
import '../utils/logger.dart';

class DailyBenefitService {
  static const String _counterKey = 'daily_benefit_counter';
  
  static Map<String, int> _getBenefitLimitsForTier(String vipTier) {
    switch (vipTier.toUpperCase()) {
      case 'GOLD':
        return {'hearts': 0, 'superChats': 0}; // Gold는 무제한이므로 0으로 설정 (제한 없음)
      case 'SILVER':
        return {'hearts': 2, 'superChats': 2}; // Silver는 매일 2개씩
      case 'BRONZE':
        return {'hearts': 0, 'superChats': 0}; // Bronze는 특별 혜택 없음
      default:
        return {'hearts': 0, 'superChats': 0}; // Free users
    }
  }
  
  Future<DailyBenefitCounter?> getDailyBenefitCounter(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final counterJson = prefs.getString('${_counterKey}_$userId');
      
      if (counterJson == null) {
        return null;
      }
      
      final counter = DailyBenefitCounter.fromJson(jsonDecode(counterJson));
      
      // Check if counter is from today
      if (!counter.isToday) {
        // Reset counter for new day
        return null; // Will be recreated in calling method
      }
      
      return counter;
    } catch (e) {
      Logger.error('Failed to get daily benefit counter: $e', name: 'DailyBenefitService');
      return null;
    }
  }
  
  Future<void> saveDailyBenefitCounter(DailyBenefitCounter counter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final counterJson = jsonEncode(counter.toJson());
      await prefs.setString('${_counterKey}_${counter.userId}', counterJson);
    } catch (e) {
      Logger.error('Failed to save daily benefit counter: $e', name: 'DailyBenefitService');
    }
  }
  
  Future<bool> canUseHeart(String userId, String vipTier) async {
    try {
      final counter = await getDailyBenefitCounter(userId) ?? 
                     DailyBenefitCounter.create(userId: userId, vipTier: vipTier);
      
      return counter.canUseHeart();
    } catch (e) {
      Logger.error('Failed to check heart usage: $e', name: 'DailyBenefitService');
      return true; // Allow usage if error occurs
    }
  }
  
  Future<bool> canUseSuperChat(String userId, String vipTier) async {
    try {
      final counter = await getDailyBenefitCounter(userId) ?? 
                     DailyBenefitCounter.create(userId: userId, vipTier: vipTier);
      
      return counter.canUseSuperChat();
    } catch (e) {
      Logger.error('Failed to check super chat usage: $e', name: 'DailyBenefitService');
      return true; // Allow usage if error occurs
    }
  }
  
  Future<bool> useHeart(String userId, String vipTier) async {
    try {
      DailyBenefitCounter counter = await getDailyBenefitCounter(userId) ?? 
                                   DailyBenefitCounter.create(userId: userId, vipTier: vipTier);
      
      if (!counter.canUseHeart()) {
        return false; // Cannot use heart, limit reached
      }
      
      // Increment heart usage
      counter = counter.copyWith(heartsUsed: counter.heartsUsed + 1);
      await saveDailyBenefitCounter(counter);
      
      Logger.log('Heart used: ${counter.heartsUsed}/${counter.heartsLimit == 0 ? "unlimited" : counter.heartsLimit}', 
                name: 'DailyBenefitService');
      return true;
    } catch (e) {
      Logger.error('Failed to use heart: $e', name: 'DailyBenefitService');
      return false;
    }
  }
  
  Future<bool> useSuperChat(String userId, String vipTier) async {
    try {
      DailyBenefitCounter counter = await getDailyBenefitCounter(userId) ?? 
                                   DailyBenefitCounter.create(userId: userId, vipTier: vipTier);
      
      if (!counter.canUseSuperChat()) {
        return false; // Cannot use super chat, limit reached
      }
      
      // Increment super chat usage
      counter = counter.copyWith(superChatsUsed: counter.superChatsUsed + 1);
      await saveDailyBenefitCounter(counter);
      
      Logger.log('Super chat used: ${counter.superChatsUsed}/${counter.superChatsLimit == 0 ? "unlimited" : counter.superChatsLimit}', 
                name: 'DailyBenefitService');
      return true;
    } catch (e) {
      Logger.error('Failed to use super chat: $e', name: 'DailyBenefitService');
      return false;
    }
  }
  
  Future<Map<String, int>> getRemainingBenefits(String userId, String vipTier) async {
    try {
      final counter = await getDailyBenefitCounter(userId) ?? 
                     DailyBenefitCounter.create(userId: userId, vipTier: vipTier);
      
      return {
        'hearts': counter.remainingHearts,
        'superChats': counter.remainingSuperChats,
      };
    } catch (e) {
      Logger.error('Failed to get remaining benefits: $e', name: 'DailyBenefitService');
      return {'hearts': 0, 'superChats': 0};
    }
  }
  
  Future<void> updateVipTier(String userId, String newVipTier) async {
    try {
      final counter = await getDailyBenefitCounter(userId);
      if (counter != null) {
        final newLimits = _getBenefitLimitsForTier(newVipTier);
        final updatedCounter = counter.copyWith(
          vipTier: newVipTier,
          heartsLimit: newLimits['hearts']!,
          superChatsLimit: newLimits['superChats']!,
        );
        await saveDailyBenefitCounter(updatedCounter);
        Logger.log('VIP tier updated in daily benefit counter: $newVipTier', name: 'DailyBenefitService');
      }
    } catch (e) {
      Logger.error('Failed to update VIP tier in benefits: $e', name: 'DailyBenefitService');
    }
  }
}