import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contact_block_model.dart';
import '../services/contact_service.dart';
import '../utils/logger.dart';

/// 연락처 차단 상태
class ContactBlockState {
  final List<ContactItem> allContacts;
  final List<BlockedContact> blockedContacts;
  final bool isLoading;
  final bool hasPermission;
  final String? error;
  final String searchQuery;

  const ContactBlockState({
    this.allContacts = const [],
    this.blockedContacts = const [],
    this.isLoading = false,
    this.hasPermission = false,
    this.error,
    this.searchQuery = '',
  });

  ContactBlockState copyWith({
    List<ContactItem>? allContacts,
    List<BlockedContact>? blockedContacts,
    bool? isLoading,
    bool? hasPermission,
    String? error,
    String? searchQuery,
  }) {
    return ContactBlockState(
      allContacts: allContacts ?? this.allContacts,
      blockedContacts: blockedContacts ?? this.blockedContacts,
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// 검색된 연락처 목록
  List<ContactItem> get filteredContacts {
    if (searchQuery.isEmpty) return allContacts;
    
    final service = ContactService();
    return service.searchContacts(allContacts, searchQuery);
  }

  /// 차단된 연락처 개수
  int get blockedCount => blockedContacts.length;

  /// 차단된 연락처만 필터링
  List<ContactItem> get blockedContactItems {
    return allContacts.where((contact) => contact.isBlocked).toList();
  }
}

/// 연락처 차단 관리
class ContactBlockNotifier extends StateNotifier<ContactBlockState> {
  final ContactService _contactService = ContactService();

  ContactBlockNotifier() : super(const ContactBlockState());

  /// 초기화
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 권한 확인
      final hasPermission = await _contactService.hasContactPermission();
      
      if (!hasPermission) {
        state = state.copyWith(
          isLoading: false,
          hasPermission: false,
          error: '연락처 권한이 필요합니다.',
        );
        return;
      }

      // 연락처 및 차단 목록 로드
      final contacts = await _contactService.getDeviceContacts();
      final blockedContacts = await _contactService.getBlockedContacts();

      state = state.copyWith(
        allContacts: contacts,
        blockedContacts: blockedContacts,
        isLoading: false,
        hasPermission: true,
        error: null,
      );

      Logger.log('✅ 연락처 차단 초기화 완료: ${contacts.length}개 연락처, ${blockedContacts.length}개 차단', 
          name: 'ContactBlockProvider');
      
    } catch (e) {
      Logger.error('연락처 차단 초기화 오류: $e', name: 'ContactBlockProvider');
      state = state.copyWith(
        isLoading: false,
        error: '연락처를 불러오는데 실패했습니다: $e',
      );
    }
  }

  /// 권한 요청
  Future<bool> requestPermission() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final granted = await _contactService.requestContactPermission();
      
      if (granted) {
        await initialize();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          hasPermission: false,
          error: '연락처 권한이 거부되었습니다.',
        );
        return false;
      }
    } catch (e) {
      Logger.error('권한 요청 오류: $e', name: 'ContactBlockProvider');
      state = state.copyWith(
        isLoading: false,
        error: '권한 요청 중 오류가 발생했습니다.',
      );
      return false;
    }
  }

  /// 연락처 차단/해제 토글
  Future<bool> toggleContactBlock(ContactItem contact, {String? reason}) async {
    try {
      final success = contact.isBlocked 
          ? await _contactService.unblockContact(contact.phone)
          : await _contactService.blockContact(contact, reason: reason);

      if (success) {
        // 상태 업데이트
        final updatedContacts = state.allContacts.map((c) {
          if (c.phone == contact.phone) {
            c.isBlocked = !c.isBlocked;
          }
          return c;
        }).toList();

        final updatedBlockedContacts = await _contactService.getBlockedContacts();

        state = state.copyWith(
          allContacts: updatedContacts,
          blockedContacts: updatedBlockedContacts,
          error: null,
        );

        final action = contact.isBlocked ? '해제' : '차단';
        Logger.log('✅ 연락처 $action 완료: ${contact.name}', name: 'ContactBlockProvider');
        return true;
      }

      return false;
    } catch (e) {
      Logger.error('연락처 차단/해제 오류: $e', name: 'ContactBlockProvider');
      state = state.copyWith(error: '연락처 차단 처리 중 오류가 발생했습니다.');
      return false;
    }
  }

  /// 연락처 검색
  void searchContacts(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// 검색 초기화
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  /// 연락처 새로고침
  Future<void> refreshContacts() async {
    await initialize();
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 특정 전화번호가 차단되었는지 확인
  Future<bool> isPhoneBlocked(String phone) async {
    try {
      return await _contactService.isContactBlocked(phone);
    } catch (e) {
      Logger.error('전화번호 차단 상태 확인 오류: $e', name: 'ContactBlockProvider');
      return false;
    }
  }

  /// 설정 앱으로 이동
  Future<void> openAppSettings() async {
    try {
      await _contactService.openAppSettings();
    } catch (e) {
      Logger.error('설정 앱 열기 실패: $e', name: 'ContactBlockProvider');
    }
  }
}

/// 연락처 차단 프로바이더
final contactBlockProvider = StateNotifierProvider<ContactBlockNotifier, ContactBlockState>((ref) {
  return ContactBlockNotifier();
});

/// 차단된 연락처 개수 프로바이더
final blockedContactCountProvider = Provider<int>((ref) {
  return ref.watch(contactBlockProvider).blockedCount;
});

/// 연락처 권한 상태 프로바이더
final contactPermissionProvider = Provider<bool>((ref) {
  return ref.watch(contactBlockProvider).hasPermission;
});

/// 특정 전화번호 차단 상태 확인 프로바이더
final phoneBlockStatusProvider = FutureProvider.family<bool, String>((ref, phone) async {
  final notifier = ref.read(contactBlockProvider.notifier);
  return await notifier.isPhoneBlocked(phone);
});