import 'package:shared_preferences/shared_preferences.dart';

import '../models/superchat_model.dart';
import '../utils/logger.dart';

/// 슈퍼챗 메시지 우선순위 관리 서비스
/// 포인트 기반 우선순위 시스템과 메시지 정렬 로직 제공
class SuperchatPriorityService {
  static final SuperchatPriorityService _instance = SuperchatPriorityService._internal();
  factory SuperchatPriorityService() => _instance;
  SuperchatPriorityService._internal();

  static const String _priorityStatsKey = 'superchat_priority_stats';
  static const String _lastPriorityUpdateKey = 'last_priority_update';

  /// 슈퍼챗 목록을 우선순위별로 정렬
  /// 1. 읽지 않은 것 우선
  /// 2. 우선순위별 정렬 (낮은 숫자 = 높은 우선순위)
  /// 3. 만료 임박 순서
  /// 4. 최신순 정렬
  List<SuperchatModel> sortSuperchatsByPriority(List<SuperchatModel> superchats) {
    try {
      final sortedList = List<SuperchatModel>.from(superchats);
      
      sortedList.sort((a, b) {
        // 1. 읽지 않은 것 우선
        if (a.isRead != b.isRead) {
          return a.isRead ? 1 : -1;
        }
        
        // 2. 만료된 것은 맨 뒤로
        if (a.isExpired != b.isExpired) {
          return a.isExpired ? 1 : -1;
        }
        
        // 3. 우선순위별 정렬 (낮은 숫자가 높은 우선순위)
        if (a.priority != b.priority) {
          return a.priority.compareTo(b.priority);
        }
        
        // 4. 만료 임박 순서 (만료가 가까운 것 우선)
        if (!a.isExpired && !b.isExpired) {
          final aDaysLeft = _getDaysUntilExpiry(a);
          final bDaysLeft = _getDaysUntilExpiry(b);
          if (aDaysLeft != bDaysLeft) {
            return aDaysLeft.compareTo(bDaysLeft);
          }
        }
        
        // 5. 최신순 정렬
        return b.createdAt.compareTo(a.createdAt);
      });

      Logger.log('슈퍼챗 ${sortedList.length}개 우선순위별 정렬 완료', name: 'SuperchatPriorityService');
      return sortedList;
    } catch (e) {
      Logger.error('슈퍼챗 정렬 오류', error: e, name: 'SuperchatPriorityService');
      return superchats;
    }
  }

  /// 고우선순위 슈퍼챗 필터링
  /// 우선순위 1-2 (다이아몬드, 골드) 슈퍼챗만 반환
  List<SuperchatModel> getHighPrioritySuperchats(List<SuperchatModel> superchats) {
    try {
      final highPriorityList = superchats
          .where((superchat) => 
              superchat.priority <= 2 && 
              !superchat.isExpired &&
              !superchat.isRead)
          .toList();

      // 고우선순위 내에서도 정렬
      highPriorityList.sort((a, b) {
        if (a.priority != b.priority) {
          return a.priority.compareTo(b.priority);
        }
        return b.createdAt.compareTo(a.createdAt);
      });

      Logger.log('고우선순위 슈퍼챗 ${highPriorityList.length}개 필터링', name: 'SuperchatPriorityService');
      return highPriorityList;
    } catch (e) {
      Logger.error('고우선순위 슈퍼챗 필터링 오류', error: e, name: 'SuperchatPriorityService');
      return [];
    }
  }

  /// 만료 예정 슈퍼챗 필터링
  /// 24시간 이내 만료 예정인 읽지 않은 슈퍼챗 반환
  List<SuperchatModel> getExpiringSoonSuperchats(List<SuperchatModel> superchats) {
    try {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(hours: 24));

      final expiringSoonList = superchats
          .where((superchat) => 
              !superchat.isExpired &&
              !superchat.isRead &&
              superchat.expiresAt.isBefore(tomorrow) &&
              superchat.expiresAt.isAfter(now))
          .toList();

      // 만료 임박 순서로 정렬
      expiringSoonList.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));

      Logger.log('만료 예정 슈퍼챗 ${expiringSoonList.length}개 필터링', name: 'SuperchatPriorityService');
      return expiringSoonList;
    } catch (e) {
      Logger.error('만료 예정 슈퍼챗 필터링 오류', error: e, name: 'SuperchatPriorityService');
      return [];
    }
  }

  /// 우선순위별 슈퍼챗 그룹화
  /// {priority: [superchats]} 형태로 반환
  Map<int, List<SuperchatModel>> groupSuperchatsByPriority(List<SuperchatModel> superchats) {
    try {
      final groupedSuperchats = <int, List<SuperchatModel>>{};

      for (final superchat in superchats) {
        final priority = superchat.priority;
        if (!groupedSuperchats.containsKey(priority)) {
          groupedSuperchats[priority] = [];
        }
        groupedSuperchats[priority]!.add(superchat);
      }

      // 각 그룹 내에서 정렬
      for (final priority in groupedSuperchats.keys) {
        groupedSuperchats[priority]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      Logger.log('슈퍼챗 우선순위별 그룹화: ${groupedSuperchats.keys.length}개 그룹', name: 'SuperchatPriorityService');
      return groupedSuperchats;
    } catch (e) {
      Logger.error('슈퍼챗 그룹화 오류', error: e, name: 'SuperchatPriorityService');
      return {};
    }
  }

  /// 스마트 우선순위 정렬
  /// 사용자의 읽기 패턴을 고려한 지능형 정렬
  List<SuperchatModel> smartPrioritySort(List<SuperchatModel> superchats, String userId) {
    try {
      final sortedList = List<SuperchatModel>.from(superchats);
      
      sortedList.sort((a, b) {
        // 1. 읽지 않은 것 우선
        if (a.isRead != b.isRead) {
          return a.isRead ? 1 : -1;
        }
        
        // 2. 만료된 것은 맨 뒤로
        if (a.isExpired != b.isExpired) {
          return a.isExpired ? 1 : -1;
        }
        
        // 3. 스마트 점수 계산 (우선순위 + 시간 가중치 + 사용자 패턴)
        final aScore = _calculateSmartScore(a, userId);
        final bScore = _calculateSmartScore(b, userId);
        
        if (aScore != bScore) {
          return bScore.compareTo(aScore); // 높은 점수 우선
        }
        
        // 4. 기본 우선순위
        if (a.priority != b.priority) {
          return a.priority.compareTo(b.priority);
        }
        
        // 5. 최신순
        return b.createdAt.compareTo(a.createdAt);
      });

      Logger.log('스마트 우선순위 정렬 완료: ${sortedList.length}개', name: 'SuperchatPriorityService');
      return sortedList;
    } catch (e) {
      Logger.error('스마트 우선순위 정렬 오류', error: e, name: 'SuperchatPriorityService');
      return sortSuperchatsByPriority(superchats); // 기본 정렬로 폴백
    }
  }

  /// 우선순위 통계 정보 반환
  Map<String, dynamic> getPriorityStatistics(List<SuperchatModel> superchats) {
    try {
      final stats = <String, dynamic>{
        'total': superchats.length,
        'unread': superchats.where((s) => !s.isRead).length,
        'expired': superchats.where((s) => s.isExpired).length,
        'expiringSoon': getExpiringSoonSuperchats(superchats).length,
        'byPriority': <int, int>{},
        'totalPointsReceived': 0,
        'averagePriority': 0.0,
      };

      int totalPoints = 0;
      int totalPrioritySum = 0;

      for (final superchat in superchats) {
        final priority = superchat.priority;
        stats['byPriority'][priority] = (stats['byPriority'][priority] ?? 0) + 1;
        totalPoints += superchat.pointsUsed;
        totalPrioritySum += priority;
      }

      stats['totalPointsReceived'] = totalPoints;
      stats['averagePriority'] = superchats.isNotEmpty 
          ? totalPrioritySum / superchats.length 
          : 0.0;

      Logger.log('우선순위 통계 계산 완료', name: 'SuperchatPriorityService');
      return stats;
    } catch (e) {
      Logger.error('우선순위 통계 계산 오류', error: e, name: 'SuperchatPriorityService');
      return {'total': 0, 'error': true};
    }
  }

  /// 우선순위 정보 캐싱
  Future<void> cachePriorityStats(String userId, Map<String, dynamic> stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsKey = '${_priorityStatsKey}_$userId';
      final updateKey = '${_lastPriorityUpdateKey}_$userId';
      
      // JSON 문자열로 변환하여 저장 (간단한 구현)
      final statsString = stats.toString();
      await prefs.setString(statsKey, statsString);
      await prefs.setString(updateKey, DateTime.now().toIso8601String());
      
      Logger.log('우선순위 통계 캐싱 완료', name: 'SuperchatPriorityService');
    } catch (e) {
      Logger.error('우선순위 통계 캐싱 오류', error: e, name: 'SuperchatPriorityService');
    }
  }

  /// 만료까지 남은 일수 계산
  int _getDaysUntilExpiry(SuperchatModel superchat) {
    if (superchat.isExpired) return -1;
    final now = DateTime.now();
    final difference = superchat.expiresAt.difference(now);
    return difference.inDays;
  }

  /// 스마트 점수 계산
  /// 우선순위, 시간 경과, 포인트 등을 종합적으로 고려
  double _calculateSmartScore(SuperchatModel superchat, String userId) {
    try {
      double score = 0.0;

      // 1. 기본 우선순위 점수 (높은 우선순위일수록 높은 점수)
      score += (5 - superchat.priority) * 10; // 1->40, 2->30, 3->20, 4->10

      // 2. 포인트 기반 점수
      score += superchat.pointsUsed / 100; // 100포인트당 1점

      // 3. 시간 가중치 (최근 것일수록 높은 점수, 하지만 너무 오래된 것은 감점)
      final hoursSinceCreated = DateTime.now().difference(superchat.createdAt).inHours;
      if (hoursSinceCreated <= 24) {
        score += 5; // 24시간 이내는 보너스
      } else if (hoursSinceCreated <= 72) {
        score += 3; // 3일 이내는 적당한 점수
      } else {
        score -= 2; // 3일 이후는 감점
      }

      // 4. 만료 임박 보너스
      final hoursUntilExpiry = superchat.expiresAt.difference(DateTime.now()).inHours;
      if (hoursUntilExpiry <= 24 && hoursUntilExpiry > 0) {
        score += 8; // 24시간 이내 만료는 높은 보너스
      } else if (hoursUntilExpiry <= 72 && hoursUntilExpiry > 0) {
        score += 3; // 3일 이내 만료는 적당한 보너스
      }

      // 5. 읽지 않은 메시지 보너스
      if (!superchat.isRead) {
        score += 15;
      }

      return score;
    } catch (e) {
      Logger.error('스마트 점수 계산 오류', error: e, name: 'SuperchatPriorityService');
      return 0.0;
    }
  }

  /// 우선순위 라벨 반환
  String getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return '💎 다이아몬드';
      case 2:
        return '🌟 골드';
      case 3:
        return '⭐ 실버';
      default:
        return '✨ 기본';
    }
  }

  /// 우선순위별 권장 행동 반환
  String getRecommendedAction(SuperchatModel superchat) {
    if (superchat.isExpired) {
      return '만료된 메시지입니다';
    }

    if (superchat.isRead) {
      return superchat.isReplied ? '답장 완료' : '답장을 고려해보세요';
    }

    final hoursUntilExpiry = superchat.expiresAt.difference(DateTime.now()).inHours;
    
    switch (superchat.priority) {
      case 1: // 다이아몬드
        return '💎 높은 포인트 투자! 빠른 답장 권장';
      case 2: // 골드
        return '🌟 관심 표현이 크네요. 답장해보세요';
      case 3: // 실버
        if (hoursUntilExpiry <= 24) {
          return '⏰ 24시간 이내 만료! 답장 고려';
        }
        return '⭐ 관심을 보여주셨어요';
      default: // 기본
        if (hoursUntilExpiry <= 24) {
          return '⏰ 곧 만료됩니다';
        }
        return '✨ 새로운 메시지입니다';
    }
  }
}