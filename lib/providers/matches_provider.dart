import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/match_model.dart';
import '../services/aws_match_service.dart';
import '../services/aws_chat_service.dart';
import '../utils/logger.dart';

// Matches State
class MatchesState {
  final List<MatchModel> matches;
  final List<MatchModel> newMatches;
  final bool isLoading;
  final String? error;
  final int totalUnreadCount;

  const MatchesState({
    required this.matches,
    required this.newMatches,
    required this.isLoading,
    this.error,
    required this.totalUnreadCount,
  });

  MatchesState copyWith({
    List<MatchModel>? matches,
    List<MatchModel>? newMatches,
    bool? isLoading,
    String? error,
    int? totalUnreadCount,
  }) {
    return MatchesState(
      matches: matches ?? this.matches,
      newMatches: newMatches ?? this.newMatches,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
    );
  }

  List<MatchModel> get allMatches => [...newMatches, ...matches];
  
  List<MatchModel> get activeMatches => 
      allMatches.where((match) => match.status == MatchStatus.active).toList();
  
  List<MatchModel> get matchesWithMessages => 
      matches.where((match) => match.lastMessage != null).toList();
  
  List<MatchModel> get unreadMatches => 
      allMatches.where((match) => match.hasUnreadMessages).toList();
}

// Matches Provider
class MatchesNotifier extends StateNotifier<MatchesState> {
  final AWSMatchService _matchService = AWSMatchService();
  Timer? _pollingTimer;

  MatchesNotifier() : super(const MatchesState(
    matches: [],
    newMatches: [],
    isLoading: false,
    totalUnreadCount: 0,
  )) {
    _initialize();
  }

  /// 초기화
  Future<void> _initialize() async {
    try {
      await _matchService.initialize();
      await _loadMatches();
      _startPolling();
    } catch (e) {
      Logger.error('MatchesNotifier 초기화 오류', error: e, name: 'MatchesProvider');
    }
  }

  /// 매칭 목록 로드
  Future<void> _loadMatches() async {
    try {
      final authState = await _getCurrentUser();
      if (authState?.userId == null) {
        return;
      }

      state = state.copyWith(isLoading: true, error: null);
      
      final userId = authState!.userId!;
      final allMatches = await _matchService.getUserMatches(userId: userId);
      
      // 새로운 매칭과 기존 매칭 분리
      final now = DateTime.now();
      final cutoffTime = now.subtract(const Duration(hours: 24)); // 24시간 이내를 '새로운' 매칭으로 간주
      
      final newMatches = allMatches
          .where((match) => match.matchedAt.isAfter(cutoffTime))
          .toList();
      
      final regularMatches = allMatches
          .where((match) => !match.matchedAt.isAfter(cutoffTime))
          .toList();
      
      // 읽지 않은 메시지 수 계산
      final totalUnread = _calculateUnreadCount([...newMatches, ...regularMatches]);
      
      state = state.copyWith(
        matches: regularMatches,
        newMatches: newMatches,
        isLoading: false,
        totalUnreadCount: totalUnread,
        error: null,
      );
      
      Logger.log('매칭 목록 로드 완료: ${regularMatches.length}개 일반, ${newMatches.length}개 신규', 
                 name: 'MatchesProvider');
    } catch (e) {
      Logger.error('매칭 목록 로드 오류', error: e, name: 'MatchesProvider');
      state = state.copyWith(
        isLoading: false,
        error: '매칭 목록을 불러오는데 실패했습니다.',
      );
    }
  }

  int _calculateUnreadCount(List<MatchModel> matches) {
    return matches.fold(0, (sum, match) => sum + match.unreadCount);
  }

  /// 매칭 목록 새로고침
  Future<void> refreshMatches() async {
    await _loadMatches();
  }

  /// 새로운 매칭 확인 (백그라운드 폴링)
  Future<void> _checkForNewMatches() async {
    try {
      final authState = await _getCurrentUser();
      if (authState?.userId == null) {
        return;
      }

      final userId = authState!.userId!;
      final newMatches = await _matchService.checkForNewMatches(userId);
      
      if (newMatches.isNotEmpty) {
        // 새 매칭을 상태에 추가
        final updatedNewMatches = [...newMatches, ...state.newMatches];
        final totalUnread = _calculateUnreadCount([...state.matches, ...updatedNewMatches]);
        
        state = state.copyWith(
          newMatches: updatedNewMatches,
          totalUnreadCount: totalUnread,
        );
        
        Logger.log('새 매칭 ${newMatches.length}개 추가됨', name: 'MatchesProvider');
      }
    } catch (e) {
      Logger.error('새 매칭 확인 오류', error: e, name: 'MatchesProvider');
    }
  }

  /// 폴링 시작
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForNewMatches();
    });
  }

  /// 폴링 중지
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// 매칭 읽음 처리
  void markMatchAsRead(String matchId) {
    final updatedMatches = state.matches.map((match) {
      if (match.id == matchId) {
        return match.copyWith(
          hasUnreadMessages: false,
          unreadCount: 0,
        );
      }
      return match;
    }).toList();

    final updatedNewMatches = state.newMatches.map((match) {
      if (match.id == matchId) {
        return match.copyWith(
          hasUnreadMessages: false,
          unreadCount: 0,
        );
      }
      return match;
    }).toList();

    final totalUnread = _calculateUnreadCount([...updatedMatches, ...updatedNewMatches]);

    state = state.copyWith(
      matches: updatedMatches,
      newMatches: updatedNewMatches,
      totalUnreadCount: totalUnread,
    );
  }

  /// 마지막 메시지 업데이트
  Future<void> updateLastMessage(String matchId, String message) async {
    try {
      final now = DateTime.now();
      
      final updatedMatches = state.matches.map((match) {
        if (match.id == matchId) {
          return match.copyWith(
            lastMessage: message,
            lastMessageTime: now,
          );
        }
        return match;
      }).toList();

      final updatedNewMatches = state.newMatches.map((match) {
        if (match.id == matchId) {
          return match.copyWith(
            lastMessage: message,
            lastMessageTime: now,
          );
        }
        return match;
      }).toList();

      state = state.copyWith(
        matches: updatedMatches,
        newMatches: updatedNewMatches,
      );
    } catch (e) {
      Logger.error('마지막 메시지 업데이트 오류', error: e, name: 'MatchesProvider');
      state = state.copyWith(error: '메시지 업데이트에 실패했습니다.');
    }
  }

  /// 새 매칭 추가
  Future<void> addNewMatch(MatchModel match) async {
    try {
      final updatedNewMatches = [match, ...state.newMatches];
      final totalUnread = _calculateUnreadCount([...state.matches, ...updatedNewMatches]);
      
      state = state.copyWith(
        newMatches: updatedNewMatches,
        totalUnreadCount: totalUnread,
      );
      
      Logger.log('새 매칭 추가: ${match.id}', name: 'MatchesProvider');
    } catch (e) {
      Logger.error('새 매칭 추가 오류', error: e, name: 'MatchesProvider');
      state = state.copyWith(error: '새 매칭 추가에 실패했습니다.');
    }
  }

  void moveNewMatchToRegular(String matchId) {
    final newMatch = state.newMatches.firstWhere(
      (match) => match.id == matchId,
      orElse: () => throw Exception('Match not found'),
    );

    final updatedNewMatches = state.newMatches.where((match) => match.id != matchId).toList();
    final updatedMatches = [newMatch, ...state.matches];

    state = state.copyWith(
      matches: updatedMatches,
      newMatches: updatedNewMatches,
    );
  }

  /// 매칭 보관
  Future<void> archiveMatch(String matchId) async {
    try {
      final success = await _matchService.updateMatchStatus(
        matchId: matchId,
        status: MatchStatus.archived,
      );
      
      if (!success) {
        throw Exception('매칭 보관에 실패했습니다.');
      }
      
      final updatedMatches = state.matches.map((match) {
        if (match.id == matchId) {
          return match.copyWith(status: MatchStatus.archived);
        }
        return match;
      }).toList();

      final updatedNewMatches = state.newMatches.map((match) {
        if (match.id == matchId) {
          return match.copyWith(status: MatchStatus.archived);
        }
        return match;
      }).toList();

      final totalUnread = _calculateUnreadCount([...updatedMatches, ...updatedNewMatches]);

      state = state.copyWith(
        matches: updatedMatches,
        newMatches: updatedNewMatches,
        totalUnreadCount: totalUnread,
      );
      
      Logger.log('매칭 보관 완료: $matchId', name: 'MatchesProvider');
    } catch (e) {
      Logger.error('매칭 보관 오류', error: e, name: 'MatchesProvider');
      state = state.copyWith(error: '매칭 보관에 실패했습니다.');
    }
  }

  /// 매칭 차단
  Future<void> blockMatch(String matchId) async {
    try {
      final authState = await _getCurrentUser();
      if (authState?.userId == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      final success = await _matchService.blockMatch(
        matchId: matchId,
        blockingUserId: authState!.userId!,
      );
      
      if (!success) {
        throw Exception('매칭 차단에 실패했습니다.');
      }
      
      // 차단된 매칭을 목록에서 제거
      final updatedMatches = state.matches.where((match) => match.id != matchId).toList();
      final updatedNewMatches = state.newMatches.where((match) => match.id != matchId).toList();
      
      final totalUnread = _calculateUnreadCount([...updatedMatches, ...updatedNewMatches]);

      state = state.copyWith(
        matches: updatedMatches,
        newMatches: updatedNewMatches,
        totalUnreadCount: totalUnread,
      );
      
      Logger.log('매칭 차단 완료: $matchId', name: 'MatchesProvider');
    } catch (e) {
      Logger.error('매칭 차단 오류', error: e, name: 'MatchesProvider');
      state = state.copyWith(error: '매칭 차단에 실패했습니다.');
    }
  }

  /// 매칭 신고
  Future<void> reportMatch(String matchId, String reason) async {
    try {
      // 신고 후 자동으로 차단 처리
      await blockMatch(matchId);
      
      Logger.log('매칭 신고 완료: $matchId (사유: $reason)', name: 'MatchesProvider');
    } catch (e) {
      Logger.error('매칭 신고 오류', error: e, name: 'MatchesProvider');
      state = state.copyWith(error: '매칭 신고에 실패했습니다.');
    }
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 현재 사용자 정보 가져오기
  Future<dynamic> _getCurrentUser() async {
    try {
      // 여기서는 간단히 구현하지만, 실제로는 AuthProvider에서 가져와야 함
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');
      if (userId != null) {
        return MockUser(userId: userId);
      }
      return null;
    } catch (e) {
      Logger.error('현재 사용자 정보 가져오기 오류', error: e, name: 'MatchesProvider');
      return null;
    }
  }
  
  /// 매칭별 읽지 않은 메시지 수 업데이트 (실시간 연동)
  void updateUnreadCount(String matchId, int unreadCount) {
    final updatedMatches = state.matches.map((match) {
      if (match.id == matchId) {
        return match.copyWith(
          unreadCount: unreadCount,
          hasUnreadMessages: unreadCount > 0,
        );
      }
      return match;
    }).toList();

    final updatedNewMatches = state.newMatches.map((match) {
      if (match.id == matchId) {
        return match.copyWith(
          unreadCount: unreadCount,
          hasUnreadMessages: unreadCount > 0,
        );
      }
      return match;
    }).toList();

    final totalUnread = _calculateUnreadCount([...updatedMatches, ...updatedNewMatches]);

    state = state.copyWith(
      matches: updatedMatches,
      newMatches: updatedNewMatches,
      totalUnreadCount: totalUnread,
    );
  }
  
  /// 특정 매칭 조회
  Future<MatchModel?> getMatchById(String matchId) async {
    try {
      final authState = await _getCurrentUser();
      if (authState?.userId == null) {
        return null;
      }

      final userId = authState!.userId!;
      final match = await _matchService.getMatch(
        matchId: matchId,
        currentUserId: userId,
      );
      
      if (match != null) {
        Logger.log('매칭 조회 성공: $matchId', name: 'MatchesProvider');
      }
      
      return match;
    } catch (e) {
      Logger.error('매칭 조회 오류', error: e, name: 'MatchesProvider');
      return null;
    }
  }
  
  /// 매칭과 채팅 상태 동기화
  Future<void> syncMatchWithChat(String matchId) async {
    try {
      final authState = await _getCurrentUser();
      if (authState?.userId == null) {
        return;
      }

      final userId = authState!.userId!;
      final chatService = AWSChatService();
      
      // 채팅 서비스에서 읽지 않은 메시지 수 가져오기
      final unreadCount = chatService.getUnreadCount(matchId, userId);
      
      // 매칭 상태 업데이트
      updateUnreadCount(matchId, unreadCount);
      
      // 마지막 메시지 정보 가져오기
      final cachedMessages = chatService.getCachedMessages(matchId);
      if (cachedMessages.isNotEmpty) {
        final lastMessage = cachedMessages.last;
        updateLastMessage(matchId, lastMessage.content);
      }
      
      Logger.log('매칭-채팅 동기화 완료: $matchId', name: 'MatchesProvider');
    } catch (e) {
      Logger.error('매칭-채팅 동기화 오류', error: e, name: 'MatchesProvider');
    }
  }
  
  /// 모든 활성 매칭과 채팅 동기화
  Future<void> syncAllMatchesWithChat() async {
    try {
      final allMatches = [...state.matches, ...state.newMatches];
      final activeMatches = allMatches.where((match) => 
          match.status == MatchStatus.active).toList();
      
      for (final match in activeMatches) {
        await syncMatchWithChat(match.id);
        // 과부하 방지를 위한 딜레이
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      Logger.log('모든 매칭-채팅 동기화 완료: ${activeMatches.length}개', name: 'MatchesProvider');
    } catch (e) {
      Logger.error('모든 매칭-채팅 동기화 오류', error: e, name: 'MatchesProvider');
    }
  }

  /// 리소스 정리
  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  // Get match by ID (synchronous - for UI)
  MatchModel? getMatchByIdSync(String matchId) {
    try {
      return state.allMatches.firstWhere((match) => match.id == matchId);
    } catch (e) {
      return null;
    }
  }

  // Search matches
  List<MatchModel> searchMatches(String query) {
    if (query.isEmpty) return state.activeMatches;
    
    return state.activeMatches.where((match) {
      return match.profile.name.toLowerCase().contains(query.toLowerCase()) ||
             (match.profile.bio?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  // Sort matches
  List<MatchModel> sortMatches(MatchSortType sortType) {
    final matches = [...state.activeMatches];
    
    switch (sortType) {
      case MatchSortType.recent:
        matches.sort((a, b) {
          final aTime = a.lastMessageTime ?? a.matchedAt;
          final bTime = b.lastMessageTime ?? b.matchedAt;
          return bTime.compareTo(aTime);
        });
        break;
      case MatchSortType.unread:
        matches.sort((a, b) {
          if (a.hasUnreadMessages && !b.hasUnreadMessages) return -1;
          if (!a.hasUnreadMessages && b.hasUnreadMessages) return 1;
          return b.matchedAt.compareTo(a.matchedAt);
        });
        break;
      case MatchSortType.name:
        matches.sort((a, b) => a.profile.name.compareTo(b.profile.name));
        break;
      case MatchSortType.matchDate:
        matches.sort((a, b) => b.matchedAt.compareTo(a.matchedAt));
        break;
    }
    
    return matches;
  }
}

enum MatchSortType {
  recent,
  unread,
  name,
  matchDate,
}

/// 임시 사용자 모델 (실제로는 AuthProvider에서 가져와야 함)
class MockUser {
  final String userId;
  MockUser({required this.userId});
}

// Provider instances
final matchesProvider = StateNotifierProvider<MatchesNotifier, MatchesState>((ref) {
  return MatchesNotifier();
});

// Helper providers
final totalMatchesCountProvider = Provider<int>((ref) {
  return ref.watch(matchesProvider).activeMatches.length;
});

final unreadMatchesCountProvider = Provider<int>((ref) {
  return ref.watch(matchesProvider).totalUnreadCount;
});

final newMatchesCountProvider = Provider<int>((ref) {
  return ref.watch(matchesProvider).newMatches.length;
});

final hasUnreadMatchesProvider = Provider<bool>((ref) {
  return ref.watch(matchesProvider).totalUnreadCount > 0;
});

/// 특정 매칭의 상세 정보 프로바이더
final matchDetailProvider = FutureProvider.family<MatchModel?, String>((ref, matchId) async {
  final matchesNotifier = ref.read(matchesProvider.notifier);
  return await matchesNotifier.getMatchById(matchId);
});

/// 매칭 검색 결과 프로바이더
final matchSearchProvider = Provider.family<List<MatchModel>, String>((ref, query) {
  final matchesNotifier = ref.read(matchesProvider.notifier);
  return matchesNotifier.searchMatches(query);
});

/// 매칭 정렬 결과 프로바이더
final sortedMatchesProvider = Provider.family<List<MatchModel>, MatchSortType>((ref, sortType) {
  final matchesNotifier = ref.read(matchesProvider.notifier);
  return matchesNotifier.sortMatches(sortType);
});

/// 특정 매칭의 읽지 않은 메시지 수 프로바이더
final matchUnreadCountProvider = Provider.family<int, String>((ref, matchId) {
  final match = ref.watch(matchesProvider).allMatches
      .where((m) => m.id == matchId)
      .firstOrNull;
  return match?.unreadCount ?? 0;
});

/// 매칭 로딩 상태 프로바이더
final matchesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(matchesProvider).isLoading;
});

/// 매칭 에러 상태 프로바이더
final matchesErrorProvider = Provider<String?>((ref) {
  return ref.watch(matchesProvider).error;
});