import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_profile_counter.dart';
import '../utils/logger.dart';

class DailyCounterService {
  static const String _counterKey = 'daily_profile_counter';
  
  static int _getDailyLimitForTier(String vipTier) {
    switch (vipTier.toUpperCase()) {
      case 'GOLD':
        return 15;
      case 'SILVER':
        return 10;
      case 'BRONZE':
        return 5;
      default:
        return 5; // Free users get same as Bronze
    }
  }
  
  Future<DailyProfileCounter?> getDailyCounter(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final counterJson = prefs.getString('${_counterKey}_$userId');
      
      if (counterJson == null) {
        return null;
      }
      
      final counter = DailyProfileCounter.fromJson(jsonDecode(counterJson));
      
      // Check if counter is from today
      if (!counter.isToday) {
        // Reset counter for new day
        await _resetCounter(userId, counter.vipTier);
        return DailyProfileCounter.create(userId: userId, vipTier: counter.vipTier);
      }
      
      return counter;
    } catch (e) {
      Logger.error('Failed to get daily counter: $e', name: 'DailyCounterService');
      return null;
    }
  }
  
  Future<void> saveDailyCounter(DailyProfileCounter counter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final counterJson = jsonEncode(counter.toJson());
      await prefs.setString('${_counterKey}_${counter.userId}', counterJson);
    } catch (e) {
      Logger.error('Failed to save daily counter: $e', name: 'DailyCounterService');
    }
  }
  
  Future<void> incrementCounter(String userId, String vipTier) async {
    try {
      DailyProfileCounter? counter = await getDailyCounter(userId);
      
      counter ??= DailyProfileCounter.create(userId: userId, vipTier: vipTier);
      
      // Update daily limit if VIP tier changed
      final updatedLimit = _getDailyLimitForTier(vipTier);
      if (counter.dailyLimit != updatedLimit || counter.vipTier != vipTier) {
        counter = counter.copyWith(
          vipTier: vipTier,
          dailyLimit: updatedLimit,
        );
      }
      
      // Increment counter if not reached limit
      if (!counter.hasReachedLimit) {
        counter = counter.copyWith(
          profilesViewed: counter.profilesViewed + 1,
        );
        await saveDailyCounter(counter);
        
        Logger.log('Profile counter incremented: ${counter.profilesViewed}/${counter.dailyLimit}', 
                  name: 'DailyCounterService');
      }
    } catch (e) {
      Logger.error('Failed to increment counter: $e', name: 'DailyCounterService');
    }
  }
  
  Future<bool> canViewMoreProfiles(String userId, String vipTier) async {
    try {
      final counter = await getDailyCounter(userId) ?? 
                     DailyProfileCounter.create(userId: userId, vipTier: vipTier);
      
      return !counter.hasReachedLimit;
    } catch (e) {
      Logger.error('Failed to check profile limit: $e', name: 'DailyCounterService');
      return true; // Allow viewing if error occurs
    }
  }
  
  Future<int> getRemainingProfiles(String userId, String vipTier) async {
    try {
      final counter = await getDailyCounter(userId) ?? 
                     DailyProfileCounter.create(userId: userId, vipTier: vipTier);
      
      return counter.remainingProfiles;
    } catch (e) {
      Logger.error('Failed to get remaining profiles: $e', name: 'DailyCounterService');
      return 0;
    }
  }
  
  Future<void> _resetCounter(String userId, String vipTier) async {
    try {
      final newCounter = DailyProfileCounter.create(userId: userId, vipTier: vipTier);
      await saveDailyCounter(newCounter);
      Logger.log('Daily counter reset for new day', name: 'DailyCounterService');
    } catch (e) {
      Logger.error('Failed to reset counter: $e', name: 'DailyCounterService');
    }
  }
  
  Future<void> updateVipTier(String userId, String newVipTier) async {
    try {
      final counter = await getDailyCounter(userId);
      if (counter != null) {
        final updatedCounter = counter.copyWith(
          vipTier: newVipTier,
          dailyLimit: _getDailyLimitForTier(newVipTier),
        );
        await saveDailyCounter(updatedCounter);
        Logger.log('VIP tier updated in daily counter: $newVipTier', name: 'DailyCounterService');
      }
    } catch (e) {
      Logger.error('Failed to update VIP tier: $e', name: 'DailyCounterService');
    }
  }
}