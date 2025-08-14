import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/superchat_model.dart';
import '../services/aws_superchat_service.dart';
import '../services/aws_likes_service.dart';
import '../services/superchat_priority_service.dart';
import '../services/superchat_service.dart';
import '../utils/logger.dart';
import 'enhanced_auth_provider.dart';

/// 슈퍼챗 상태
class SuperchatState {
  final List<SuperchatModel> receivedSuperchats;
  final List<SuperchatModel> sentSuperchats;
  final bool isLoading;
  final bool isLoadingReceived;
  final bool isLoadingSent;
  final bool isSending;
  final String? error;
  final int remainingDailySuperchats;
  final int totalUnreadSuperchats;
  final int currentSuperChats; // 현재 보유 슈퍼챗 수
  final List<SuperChatPackage> packages; // 슈퍼챗 패키지 목록
  final List<SuperChatTransaction> transactions; // 슈퍼챗 거래 내역

  const SuperchatState({
    this.receivedSuperchats = const [],
    this.sentSuperchats = const [],
    this.isLoading = false,
    this.isLoadingReceived = false,
    this.isLoadingSent = false,
    this.isSending = false,
    this.error,
    this.remainingDailySuperchats = 5,
    this.totalUnreadSuperchats = 0,
    this.currentSuperChats = 0,
    this.packages = const [],
    this.transactions = const [],
  });

  SuperchatState copyWith({
    List<SuperchatModel>? receivedSuperchats,
    List<SuperchatModel>? sentSuperchats,
    bool? isLoading,
    bool? isLoadingReceived,
    bool? isLoadingSent,
    bool? isSending,
    String? error,
    int? remainingDailySuperchats,
    int? totalUnreadSuperchats,
    int? currentSuperChats,
    List<SuperChatPackage>? packages,
    List<SuperChatTransaction>? transactions,
  }) {
    return SuperchatState(
      receivedSuperchats: receivedSuperchats ?? this.receivedSuperchats,
      sentSuperchats: sentSuperchats ?? this.sentSuperchats,
      isLoading: isLoading ?? this.isLoading,
      isLoadingReceived: isLoadingReceived ?? this.isLoadingReceived,
      isLoadingSent: isLoadingSent ?? this.isLoadingSent,
      isSending: isSending ?? this.isSending,
      error: error,
      remainingDailySuperchats: remainingDailySuperchats ?? this.remainingDailySuperchats,
      totalUnreadSuperchats: totalUnreadSuperchats ?? this.totalUnreadSuperchats,
      currentSuperChats: currentSuperChats ?? this.currentSuperChats,
      packages: packages ?? this.packages,
      transactions: transactions ?? this.transactions,
    );
  }
}

/// 슈퍼챗 관리
class SuperchatNotifier extends StateNotifier<SuperchatState> {
  final Ref ref;
  final AWSSuperchatService _superchatService = AWSSuperchatService();
  final AWSLikesService _likesService = AWSLikesService();
  final SuperchatPriorityService _priorityService = SuperchatPriorityService();
  final SuperChatService _superChatService = SuperChatService();

  SuperchatNotifier(this.ref) : super(const SuperchatState());

  /// 초기화
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _superchatService.initialize();
      
      // 슈퍼챗 구매 관련 초기화
      final packages = _superChatService.getSuperChatPackages();
      final currentSuperChats = await _superChatService.getCurrentSuperChats();
      final transactions = await _superChatService.getSuperChatTransactions();
      
      state = state.copyWith(
        packages: packages,
        currentSuperChats: currentSuperChats,
        transactions: transactions,
      );
      
      await loadAllSuperchats();
      
      // 명시적으로 로딩 완료 상태로 설정
      state = state.copyWith(
        isLoading: false,
        isLoadingReceived: false,
        isLoadingSent: false,
        isSending: false,
      );
    } catch (e) {
      Logger.error('슈퍼챗 초기화 오류', error: e, name: 'SuperchatProvider');
      state = state.copyWith(
        isLoading: false,
        error: '슈퍼챗 기능 초기화에 실패했습니다.',
      );
    }
  }

  /// 모든 슈퍼챗 데이터 로드
  Future<void> loadAllSuperchats() async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      return;
    }

    final userId = authState.currentUser!.user!.userId;

    await Future.wait([
      loadReceivedSuperchats(userId),
      loadSentSuperchats(userId),
      updateRemainingDailySuperchats(userId),
    ]);
  }

  /// 받은 슈퍼챗 로드
  Future<void> loadReceivedSuperchats(String userId) async {
    state = state.copyWith(isLoadingReceived: true, error: null);

    try {
      final superchats = await _superchatService.getReceivedSuperchats(userId: userId);
      final unreadCount = superchats.where((superchat) => !superchat.isRead).length;
      
      state = state.copyWith(
        receivedSuperchats: superchats,
        isLoadingReceived: false,
        totalUnreadSuperchats: unreadCount,
      );
    } catch (e) {
      Logger.error('받은 슈퍼챗 로드 오류', error: e, name: 'SuperchatProvider');
      state = state.copyWith(
        isLoadingReceived: false,
        error: '받은 슈퍼챗을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 보낸 슈퍼챗 로드
  Future<void> loadSentSuperchats(String userId) async {
    state = state.copyWith(isLoadingSent: true, error: null);

    try {
      final superchats = await _superchatService.getSentSuperchats(userId: userId);
      state = state.copyWith(
        sentSuperchats: superchats,
        isLoadingSent: false,
      );
    } catch (e) {
      Logger.error('보낸 슈퍼챗 로드 오류', error: e, name: 'SuperchatProvider');
      state = state.copyWith(
        isLoadingSent: false,
        error: '보낸 슈퍼챗을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 일일 슈퍼챗 전송 가능 횟수 업데이트
  Future<void> updateRemainingDailySuperchats(String userId) async {
    try {
      final remaining = await _superchatService.getRemainingDailySuperchats(userId);
      state = state.copyWith(remainingDailySuperchats: remaining);
    } catch (e) {
      Logger.error('일일 슈퍼챗 가능 횟수 업데이트 오류', error: e, name: 'SuperchatProvider');
    }
  }

  /// 슈퍼챗 전송
  Future<bool> sendSuperchat({
    required String toProfileId,
    required String message,
    required int pointsUsed,
    SuperchatTemplateType? templateType,
    Map<String, dynamic>? customData,
  }) async {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      state = state.copyWith(error: '로그인이 필요합니다.');
      return false;
    }

    if (state.remainingDailySuperchats <= 0) {
      state = state.copyWith(error: '일일 슈퍼챗 전송 제한을 초과했습니다.');
      return false;
    }

    state = state.copyWith(isSending: true, error: null);

    try {
      final fromUserId = authState.currentUser!.user!.userId;
      
      // REST API를 통한 슈퍼챗 전송 (likes 페이지와 호환성 위해)
      final likeResult = await _likesService.sendSuperchat(
        fromUserId: fromUserId,
        toProfileId: toProfileId,
        message: message,
        pointsUsed: pointsUsed,
        templateType: templateType?.name,
        customData: customData,
      );

      if (likeResult != null) {
        // LikeModel을 SuperchatModel로 변환
        final superchatModel = SuperchatModel(
          id: likeResult.id,
          fromUserId: likeResult.fromUserId,
          toProfileId: likeResult.toProfileId,
          message: likeResult.message ?? message,
          pointsUsed: pointsUsed,
          templateType: templateType ?? SuperchatTemplateType.custom,
          customData: customData,
          status: SuperchatStatus.sent,
          priority: _calculatePriority(pointsUsed),
          expiresAt: DateTime.now().add(const Duration(days: 7)),
          createdAt: likeResult.createdAt,
          updatedAt: likeResult.updatedAt,
        );
        
        // 보낸 슈퍼챗 목록에 추가
        state = state.copyWith(
          sentSuperchats: [...state.sentSuperchats, superchatModel],
          remainingDailySuperchats: state.remainingDailySuperchats - 1,
          isSending: false,
        );

        Logger.log('슈퍼챗 전송 성공: ${superchatModel.id}', name: 'SuperchatProvider');
        return true;
      } else {
        throw Exception('슈퍼챗 전송에 실패했습니다.');
      }
    } catch (e) {
      Logger.error('슈퍼챗 전송 오류', error: e, name: 'SuperchatProvider');
      state = state.copyWith(
        isSending: false,
        error: e.toString().contains('Exception:') 
            ? e.toString().replaceAll('Exception:', '').trim()
            : '슈퍼챗 전송에 실패했습니다.',
      );
      return false;
    }
  }

  /// 슈퍼챗을 읽음으로 표시
  Future<void> markSuperchatAsRead(String superchatId) async {
    try {
      final success = await _superchatService.updateSuperchatStatus(
        superchatId: superchatId,
        status: 'READ',
      );

      if (success) {
        // 로컬 상태 업데이트
        final updatedSuperchats = state.receivedSuperchats.map((superchat) {
          if (superchat.id == superchatId) {
            return superchat.copyWith(status: SuperchatStatus.read);
          }
          return superchat;
        }).toList();

        final unreadCount = updatedSuperchats.where((superchat) => !superchat.isRead).length;

        state = state.copyWith(
          receivedSuperchats: updatedSuperchats,
          totalUnreadSuperchats: unreadCount,
        );

        // SharedPreferences에 읽음 상태 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('superchat_read_$superchatId', true);
      }
    } catch (e) {
      Logger.error('슈퍼챗 읽음 표시 오류', error: e, name: 'SuperchatProvider');
    }
  }

  /// 슈퍼챗에 답장
  Future<bool> replyToSuperchat({
    required String superchatId,
    required String replyMessage,
  }) async {
    try {
      // 1. 슈퍼챗 상태를 답장함으로 업데이트
      final success = await _superchatService.updateSuperchatStatus(
        superchatId: superchatId,
        status: 'REPLIED',
      );

      if (success) {
        // 2. 로컬 상태 업데이트
        final updatedSuperchats = state.receivedSuperchats.map((superchat) {
          if (superchat.id == superchatId) {
            return superchat.copyWith(status: SuperchatStatus.replied);
          }
          return superchat;
        }).toList();

        final unreadCount = updatedSuperchats.where((superchat) => !superchat.isRead).length;

        state = state.copyWith(
          receivedSuperchats: updatedSuperchats,
          totalUnreadSuperchats: unreadCount,
        );

        // 3. 실제 채팅으로 연결하는 로직은 향후 채팅 기능 구현 시 추가
        Logger.log('슈퍼챗 답장 성공: $superchatId', name: 'SuperchatProvider');
        return true;
      }

      return false;
    } catch (e) {
      Logger.error('슈퍼챗 답장 오류', error: e, name: 'SuperchatProvider');
      state = state.copyWith(error: '답장에 실패했습니다.');
      return false;
    }
  }

  /// 슈퍼챗 우선순위별 정렬
  List<SuperchatModel> getSortedReceivedSuperchats() {
    return _priorityService.sortSuperchatsByPriority(state.receivedSuperchats);
  }

  /// 스마트 우선순위 정렬 (사용자 패턴 고려)
  List<SuperchatModel> getSmartSortedSuperchats() {
    final authState = ref.read(enhancedAuthProvider);
    if (!authState.isSignedIn || authState.currentUser?.user?.userId == null) {
      return getSortedReceivedSuperchats();
    }

    final userId = authState.currentUser!.user!.userId;
    return _priorityService.smartPrioritySort(state.receivedSuperchats, userId);
  }

  /// 고우선순위 슈퍼챗 필터링
  List<SuperchatModel> getHighPrioritySuperchats() {
    return _priorityService.getHighPrioritySuperchats(state.receivedSuperchats);
  }

  /// 만료 예정 슈퍼챗 필터링
  List<SuperchatModel> getExpiringSoonSuperchats() {
    return _priorityService.getExpiringSoonSuperchats(state.receivedSuperchats);
  }

  /// 우선순위별 슈퍼챗 그룹화
  Map<int, List<SuperchatModel>> getGroupedSuperchatsByPriority() {
    return _priorityService.groupSuperchatsByPriority(state.receivedSuperchats);
  }

  /// 우선순위 통계 정보
  Map<String, dynamic> getPriorityStatistics() {
    return _priorityService.getPriorityStatistics(state.receivedSuperchats);
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadAllSuperchats();
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 상태 초기화
  void reset() {
    state = const SuperchatState();
  }

  /// 슈퍼챗 구매
  Future<bool> purchaseSuperChats(SuperChatPackage package) async {
    try {
      // 로딩 상태는 UI에서 관리하도록 하고, 여기서는 데이터만 처리
      final success = await _superChatService.purchaseSuperChats(package);
      
      if (success) {
        // 현재 슈퍼챗 수와 거래 내역 업데이트
        final newSuperChats = await _superChatService.getCurrentSuperChats();
        final newTransactions = await _superChatService.getSuperChatTransactions();
        
        state = state.copyWith(
          currentSuperChats: newSuperChats,
          transactions: newTransactions,
          isLoading: false, // 명시적으로 false 설정
          error: null,
        );
        
        Logger.log('✅ 슈퍼챗 구매 성공: ${package.totalCount}개', name: 'SuperchatProvider');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '슈퍼챗 구매에 실패했습니다.',
        );
        return false;
      }
    } catch (e) {
      Logger.error('슈퍼챗 구매 오류: $e', name: 'SuperchatProvider');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// 슈퍼챗 사용
  Future<bool> spendSuperChats(int amount, {String? description}) async {
    try {
      if (state.currentSuperChats < amount) {
        state = state.copyWith(error: '슈퍼챗이 부족합니다. (현재: ${state.currentSuperChats}개)');
        return false;
      }

      final success = await _superChatService.spendSuperChats(amount, description: description);
      
      if (success) {
        // 현재 슈퍼챗 수와 거래 내역 업데이트
        final newSuperChats = await _superChatService.getCurrentSuperChats();
        final newTransactions = await _superChatService.getSuperChatTransactions();
        
        state = state.copyWith(
          currentSuperChats: newSuperChats,
          transactions: newTransactions,
          error: null,
        );
        
        Logger.log('✅ 슈퍼챗 사용 성공: $amount개', name: 'SuperchatProvider');
        return true;
      } else {
        state = state.copyWith(error: '슈퍼챗 사용에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('슈퍼챗 사용 오류: $e', name: 'SuperchatProvider');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 슈퍼챗 정보 새로고침
  Future<void> refreshSuperChats() async {
    try {
      final currentSuperChats = await _superChatService.getCurrentSuperChats();
      final transactions = await _superChatService.getSuperChatTransactions();
      
      state = state.copyWith(
        currentSuperChats: currentSuperChats,
        transactions: transactions,
        error: null,
      );
    } catch (e) {
      Logger.error('슈퍼챗 새로고침 실패: $e', name: 'SuperchatProvider');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 슈퍼챗 우선순위 계산
  int _calculatePriority(int pointsUsed) {
    // 포인트에 따른 우선순위 계산
    if (pointsUsed >= 1000) return 1; // 최고 우선순위
    if (pointsUsed >= 500) return 2;  // 높은 우선순위
    if (pointsUsed >= 200) return 3;  // 중간 우선순위
    return 4; // 기본 우선순위
  }
}

/// 슈퍼챗 프로바이더
final superchatProvider = StateNotifierProvider<SuperchatNotifier, SuperchatState>((ref) {
  return SuperchatNotifier(ref);
});

/// 받은 슈퍼챗 수 프로바이더
final receivedSuperchatsCountProvider = Provider<int>((ref) {
  final superchatState = ref.watch(superchatProvider);
  return superchatState.receivedSuperchats.length;
});

/// 읽지 않은 슈퍼챗 수 프로바이더
final unreadSuperchatsCountProvider = Provider<int>((ref) {
  final superchatState = ref.watch(superchatProvider);
  return superchatState.totalUnreadSuperchats;
});

/// 보낸 슈퍼챗 수 프로바이더
final sentSuperchatsCountProvider = Provider<int>((ref) {
  final superchatState = ref.watch(superchatProvider);
  return superchatState.sentSuperchats.length;
});

/// 일일 슈퍼챗 전송 가능 여부 프로바이더
final canSendSuperchatProvider = Provider<bool>((ref) {
  final superchatState = ref.watch(superchatProvider);
  return superchatState.remainingDailySuperchats > 0;
});

/// 고우선순위 슈퍼챗 프로바이더
final highPrioritySuperchatsProvider = Provider<List<SuperchatModel>>((ref) {
  final superchatNotifier = ref.read(superchatProvider.notifier);
  return superchatNotifier.getHighPrioritySuperchats();
});

/// 만료 예정 슈퍼챗 프로바이더
final expiringSoonSuperchatsProvider = Provider<List<SuperchatModel>>((ref) {
  final superchatNotifier = ref.read(superchatProvider.notifier);
  return superchatNotifier.getExpiringSoonSuperchats();
});

/// 정렬된 받은 슈퍼챗 프로바이더
final sortedReceivedSuperchatsProvider = Provider<List<SuperchatModel>>((ref) {
  final superchatNotifier = ref.read(superchatProvider.notifier);
  return superchatNotifier.getSortedReceivedSuperchats();
});

/// 스마트 정렬된 슈퍼챗 프로바이더
final smartSortedSuperchatsProvider = Provider<List<SuperchatModel>>((ref) {
  final superchatNotifier = ref.read(superchatProvider.notifier);
  return superchatNotifier.getSmartSortedSuperchats();
});

/// 우선순위별 그룹화된 슈퍼챗 프로바이더
final groupedSuperchatsProvider = Provider<Map<int, List<SuperchatModel>>>((ref) {
  final superchatNotifier = ref.read(superchatProvider.notifier);
  return superchatNotifier.getGroupedSuperchatsByPriority();
});

/// 슈퍼챗 통계 프로바이더
final superchatStatsProvider = Provider<Map<String, int>>((ref) {
  final superchatState = ref.watch(superchatProvider);
  return {
    'received': superchatState.receivedSuperchats.length,
    'sent': superchatState.sentSuperchats.length,
    'unread': superchatState.totalUnreadSuperchats,
    'remaining': superchatState.remainingDailySuperchats,
    'highPriority': ref.watch(highPrioritySuperchatsProvider).length,
    'expiringSoon': ref.watch(expiringSoonSuperchatsProvider).length,
  };
});

/// 우선순위 통계 프로바이더 (상세)
final priorityStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final superchatNotifier = ref.read(superchatProvider.notifier);
  return superchatNotifier.getPriorityStatistics();
});

/// 현재 보유 슈퍼챗 수 프로바이더
final currentSuperChatsProvider = Provider<int>((ref) {
  return ref.watch(superchatProvider).currentSuperChats;
});

/// 슈퍼챗 패키지 목록 프로바이더
final superChatPackagesProvider = Provider<List<SuperChatPackage>>((ref) {
  return ref.watch(superchatProvider).packages;
});

/// 슈퍼챗 거래 내역 프로바이더
final superChatTransactionsProvider = Provider<List<SuperChatTransaction>>((ref) {
  return ref.watch(superchatProvider).transactions;
});