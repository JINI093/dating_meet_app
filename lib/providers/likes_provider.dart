import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/like_model.dart';
import '../services/aws_likes_service.dart';
import '../utils/logger.dart';
import 'enhanced_auth_provider.dart';

/// 호감 표시 상태
class LikesState {
  final List<LikeModel> receivedLikes;
  final List<LikeModel> sentLikes;
  final List<LikeModel> matches;
  final bool isLoading;
  final bool isLoadingReceived;
  final bool isLoadingSent;
  final bool isLoadingMatches;
  final String? error;
  final int remainingDailyLikes;
  final int totalUnreadLikes;

  // 이전 버전과의 호환성을 위한 getter
  List<LikeModel> get likes => receivedLikes;
  int get unreadCount => totalUnreadLikes;

  const LikesState({
    this.receivedLikes = const [],
    this.sentLikes = const [],
    this.matches = const [],
    this.isLoading = false,
    this.isLoadingReceived = false,
    this.isLoadingSent = false,
    this.isLoadingMatches = false,
    this.error,
    this.remainingDailyLikes = 10,
    this.totalUnreadLikes = 0,
  });

  LikesState copyWith({
    List<LikeModel>? receivedLikes,
    List<LikeModel>? sentLikes,
    List<LikeModel>? matches,
    bool? isLoading,
    bool? isLoadingReceived,
    bool? isLoadingSent,
    bool? isLoadingMatches,
    String? error,
    int? remainingDailyLikes,
    int? totalUnreadLikes,
    // 이전 버전 호환성
    List<LikeModel>? likes,
    int? unreadCount,
  }) {
    return LikesState(
      receivedLikes: receivedLikes ?? likes ?? this.receivedLikes,
      sentLikes: sentLikes ?? this.sentLikes,
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      isLoadingReceived: isLoadingReceived ?? this.isLoadingReceived,
      isLoadingSent: isLoadingSent ?? this.isLoadingSent,
      isLoadingMatches: isLoadingMatches ?? this.isLoadingMatches,
      error: error,
      remainingDailyLikes: remainingDailyLikes ?? this.remainingDailyLikes,
      totalUnreadLikes: totalUnreadLikes ?? unreadCount ?? this.totalUnreadLikes,
    );
  }
}

/// 호감 표시 관리
class LikesNotifier extends StateNotifier<LikesState> {
  final Ref ref;
  final AWSLikesService _likesService = AWSLikesService();

  LikesNotifier(this.ref) : super(const LikesState());

  /// 초기화
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _likesService.initialize();
      await loadAllLikes();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      Logger.error('호감 표시 초기화 오류', error: e, name: 'LikesProvider');
      state = state.copyWith(
        isLoading: false,
        error: '호감 표시 기능 초기화에 실패했습니다.',
      );
    }
  }

  /// 모든 호감 데이터 로드
  Future<void> loadAllLikes() async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      Logger.error('사용자가 로그인되지 않음', name: 'LikesProvider');
      return;
    }

    final userId = authState.currentUser!.user!.userId;

    await Future.wait([
      loadReceivedLikes(userId),
      loadSentLikes(userId),
      loadMatches(userId),
      updateRemainingDailyLikes(userId),
    ]);
  }

  /// 받은 호감 로드
  Future<void> loadReceivedLikes(String userId) async {
    state = state.copyWith(isLoadingReceived: true, error: null);

    try {
      final likes = await _likesService.getReceivedLikes(userId: userId);
      final unreadCount = likes.where((like) => !like.isRead).length;
      
      state = state.copyWith(
        receivedLikes: likes,
        isLoadingReceived: false,
        totalUnreadLikes: unreadCount,
      );
    } catch (e) {
      Logger.error('받은 호감 로드 오류', error: e, name: 'LikesProvider');
      state = state.copyWith(
        isLoadingReceived: false,
        error: '받은 호감을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 보낸 호감 로드
  Future<void> loadSentLikes(String userId) async {
    state = state.copyWith(isLoadingSent: true, error: null);

    try {
      final likes = await _likesService.getSentLikes(userId: userId);
      state = state.copyWith(
        sentLikes: likes,
        isLoadingSent: false,
      );
    } catch (e) {
      Logger.error('보낸 호감 로드 오류', error: e, name: 'LikesProvider');
      state = state.copyWith(
        isLoadingSent: false,
        error: '보낸 호감을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 매칭 목록 로드
  Future<void> loadMatches(String userId) async {
    state = state.copyWith(isLoadingMatches: true, error: null);

    try {
      final matches = await _likesService.getMatches(userId: userId);
      state = state.copyWith(
        matches: matches,
        isLoadingMatches: false,
      );
    } catch (e) {
      Logger.error('매칭 목록 로드 오류', error: e, name: 'LikesProvider');
      state = state.copyWith(
        isLoadingMatches: false,
        error: '매칭 목록을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 일일 호감 표시 가능 횟수 업데이트
  Future<void> updateRemainingDailyLikes(String userId) async {
    try {
      final remaining = await _likesService.getRemainingDailyLikes(userId);
      state = state.copyWith(remainingDailyLikes: remaining);
    } catch (e) {
      Logger.error('일일 호감 표시 가능 횟수 업데이트 오류', error: e, name: 'LikesProvider');
    }
  }

  /// 호감 표시하기
  Future<bool> sendLike({
    required String toProfileId,
    String? message,
  }) async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      state = state.copyWith(error: '로그인이 필요합니다.');
      return false;
    }

    if (state.remainingDailyLikes <= 0) {
      state = state.copyWith(error: '일일 호감 표시 제한을 초과했습니다.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final fromUserId = authState.currentUser!.user!.userId;
      final result = await _likesService.sendLike(
        fromUserId: fromUserId,
        toProfileId: toProfileId,
        message: message,
      );

      if (result != null) {
        // 보낸 호감 목록에 추가
        state = state.copyWith(
          sentLikes: [...state.sentLikes, result],
          remainingDailyLikes: state.remainingDailyLikes - 1,
          isLoading: false,
        );

        // 매칭이 발생한 경우 매칭 목록에 추가
        if (result.isMatched) {
          state = state.copyWith(
            matches: [...state.matches, result],
          );
        }

        Logger.log('호감 표시 성공: ${result.id}', name: 'LikesProvider');
        return true;
      } else {
        throw Exception('호감 표시에 실패했습니다.');
      }
    } catch (e) {
      Logger.error('호감 표시 오류', error: e, name: 'LikesProvider');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().contains('Exception:') 
            ? e.toString().replaceAll('Exception:', '').trim()
            : '호감 표시에 실패했습니다.',
      );
      return false;
    }
  }

  /// 패스하기
  Future<bool> sendPass({
    required String toProfileId,
  }) async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      state = state.copyWith(error: '로그인이 필요합니다.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final fromUserId = authState.currentUser!.user!.userId;
      final result = await _likesService.sendPass(
        fromUserId: fromUserId,
        toProfileId: toProfileId,
      );

      if (result != null) {
        state = state.copyWith(isLoading: false);
        Logger.log('패스 성공: ${result.id}', name: 'LikesProvider');
        return true;
      } else {
        throw Exception('패스에 실패했습니다.');
      }
    } catch (e) {
      Logger.error('패스 오류', error: e, name: 'LikesProvider');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().contains('Exception:') 
            ? e.toString().replaceAll('Exception:', '').trim()
            : '패스에 실패했습니다.',
      );
      return false;
    }
  }

  /// 받은 호감을 읽음으로 표시
  Future<void> markAsRead(String likeId) async {
    try {
      // 로컬 상태 업데이트
      final updatedLikes = state.receivedLikes.map((like) {
        if (like.id == likeId) {
          return like.copyWith(isRead: true);
        }
        return like;
      }).toList();

      final unreadCount = updatedLikes.where((like) => !like.isRead).length;

      state = state.copyWith(
        receivedLikes: updatedLikes,
        totalUnreadLikes: unreadCount,
      );

      // SharedPreferences에 읽음 상태 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('like_read_$likeId', true);
    } catch (e) {
      Logger.error('호감 읽음 표시 오류', error: e, name: 'LikesProvider');
    }
  }

  /// 호감 수락 (매칭)
  Future<void> acceptLike(String likeId) async {
    try {
      // 해당 호감을 찾기
      final like = state.receivedLikes.firstWhere((l) => l.id == likeId);
      
      // 역방향 호감 표시 (수락)
      final success = await sendLike(toProfileId: like.fromUserId);
      
      if (success) {
        // 받은 호감 목록에서 제거
        final updatedLikes = state.receivedLikes.where((l) => l.id != likeId).toList();
        final unreadCount = updatedLikes.where((like) => !like.isRead).length;
        
        state = state.copyWith(
          receivedLikes: updatedLikes,
          totalUnreadLikes: unreadCount,
        );
        
        Logger.log('호감 수락 성공: $likeId', name: 'LikesProvider');
      }
    } catch (e) {
      Logger.error('호감 수락 오류', error: e, name: 'LikesProvider');
      state = state.copyWith(error: '호감 수락에 실패했습니다.');
    }
  }

  /// 호감 거절
  Future<void> rejectLike(String likeId) async {
    try {
      // 받은 호감 목록에서 제거
      final updatedLikes = state.receivedLikes.where((like) => like.id != likeId).toList();
      final unreadCount = updatedLikes.where((like) => !like.isRead).length;
      
      state = state.copyWith(
        receivedLikes: updatedLikes,
        totalUnreadLikes: unreadCount,
      );
      
      Logger.log('호감 거절: $likeId', name: 'LikesProvider');
    } catch (e) {
      Logger.error('호감 거절 오류', error: e, name: 'LikesProvider');
      state = state.copyWith(error: '호감 거절에 실패했습니다.');
    }
  }

  /// 새로고침
  Future<void> refreshLikes() async {
    await loadAllLikes();
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 상태 초기화
  void reset() {
    state = const LikesState();
  }
}

/// 이전 버전 호환성을 위한 ReceivedLikesNotifier
class ReceivedLikesNotifier extends LikesNotifier {
  ReceivedLikesNotifier(super.ref) {
    _loadLikes();
  }

  Future<void> _loadLikes() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Mock 데이터로 테스트 (실제로는 AWS 서비스 사용)
      await Future.delayed(const Duration(milliseconds: 500));
      
      final likes = LikeModel.getMockReceivedLikes();
      final unreadCount = likes.where((like) => !like.isRead).length;
      
      state = state.copyWith(
        receivedLikes: likes,
        isLoading: false,
        totalUnreadLikes: unreadCount,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  @override
  Future<void> refreshLikes() async {
    await _loadLikes();
  }

  @override
  Future<void> markAsRead(String likeId) async {
    await super.markAsRead(likeId);
  }
}

/// 이전 버전 호환성을 위한 SentLikesNotifier
class SentLikesNotifier extends LikesNotifier {
  SentLikesNotifier(super.ref) {
    _loadLikes();
  }

  Future<void> _loadLikes() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Mock 데이터로 테스트 (실제로는 AWS 서비스 사용)
      await Future.delayed(const Duration(milliseconds: 500));
      
      final likes = LikeModel.getMockSentLikes();
      
      state = state.copyWith(
        sentLikes: likes,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  @override
  Future<void> refreshLikes() async {
    await _loadLikes();
  }

  Future<void> cancelLike(String likeId) async {
    try {
      // 보낸 호감 목록에서 제거
      final updatedLikes = state.sentLikes.where((like) => like.id != likeId).toList();
      
      state = state.copyWith(sentLikes: updatedLikes);
      
      Logger.log('호감 취소: $likeId', name: 'LikesProvider');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Provider instances
final likesProvider = StateNotifierProvider<LikesNotifier, LikesState>((ref) {
  return LikesNotifier(ref);
});

final receivedLikesProvider = StateNotifierProvider<ReceivedLikesNotifier, LikesState>((ref) {
  return ReceivedLikesNotifier(ref);
});

final sentLikesProvider = StateNotifierProvider<SentLikesNotifier, LikesState>((ref) {
  return SentLikesNotifier(ref);
});

// Helper providers
final receivedLikesCountProvider = Provider<int>((ref) {
  final likesState = ref.watch(likesProvider);
  return likesState.receivedLikes.length;
});

final unreadLikesCountProvider = Provider<int>((ref) {
  final likesState = ref.watch(likesProvider);
  return likesState.totalUnreadLikes;
});

final sentLikesCountProvider = Provider<int>((ref) {
  final likesState = ref.watch(likesProvider);
  return likesState.sentLikes.length;
});

final matchesCountProvider = Provider<int>((ref) {
  final likesState = ref.watch(likesProvider);
  return likesState.matches.length;
});

final canSendLikeProvider = Provider<bool>((ref) {
  final likesState = ref.watch(likesProvider);
  return likesState.remainingDailyLikes > 0;
});

final likesStatsProvider = Provider<Map<String, int>>((ref) {
  final likesState = ref.watch(likesProvider);
  return {
    'received': likesState.receivedLikes.length,
    'sent': likesState.sentLikes.length,
    'matches': likesState.matches.length,
    'unread': likesState.totalUnreadLikes,
    'remaining': likesState.remainingDailyLikes,
  };
});