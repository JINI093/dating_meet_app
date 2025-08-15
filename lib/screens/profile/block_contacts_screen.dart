import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/contact_block_provider.dart';
import '../../models/contact_block_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class BlockContactsScreen extends ConsumerStatefulWidget {
  const BlockContactsScreen({super.key});

  @override
  ConsumerState<BlockContactsScreen> createState() => _BlockContactsScreenState();
}

class _BlockContactsScreenState extends ConsumerState<BlockContactsScreen> {
  int _selectedTab = 0; // 0: 연락처, 1: 차단된 연락처
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactBlockProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactState = ref.watch(contactBlockProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.chevron_left,
            color: Colors.black,
            size: 28,
          ),
        ),
        title: const Text(
          '지인차단',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (contactState.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(contactState),
    );
  }

  Widget _buildBody(ContactBlockState state) {
    if (!state.hasPermission && !state.isLoading) {
      return _buildPermissionRequest();
    }

    if (state.error != null && state.allContacts.isEmpty) {
      return _buildErrorState(state.error!);
    }

    return Column(
      children: [
        // 탭바
        _buildTabBar(state),
        
        // 검색바
        _buildSearchBar(),
        
        // 연락처 리스트
        Expanded(
          child: _buildContactList(state),
        ),
      ],
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.person_2,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 24),
            Text(
              '연락처 권한이 필요합니다',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '지인차단 기능을 사용하려면\n연락처 접근 권한을 허용해주세요.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(contactBlockProvider.notifier).requestPermission();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '권한 허용하기',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              '연락처를 불러올 수 없습니다',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(contactBlockProvider.notifier).refreshContacts();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '다시 시도',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ContactBlockState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == 0 ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  '연락처',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _selectedTab == 0 ? Colors.black : const Color(0xFF999999),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == 1 ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  '차단된 연락처(${state.blockedCount})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _selectedTab == 1 ? Colors.black : const Color(0xFF999999),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.search,
            color: Color(0xFF999999),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(contactBlockProvider.notifier).searchContacts(value);
              },
              decoration: const InputDecoration(
                hintText: '이름이나 번호 검색',
                hintStyle: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                ref.read(contactBlockProvider.notifier).clearSearch();
              },
              child: const Icon(
                CupertinoIcons.clear,
                color: Color(0xFF999999),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactList(ContactBlockState state) {
    final contacts = _getFilteredContacts(state);

    if (state.isLoading && contacts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '연락처를 불러오는 중...',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTab == 0 ? CupertinoIcons.person_2 : CupertinoIcons.clear,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedTab == 0 ? '연락처가 없습니다' : '차단된 연락처가 없습니다',
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(contactBlockProvider.notifier).refreshContacts();
      },
      child: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return _buildContactItem(contact);
        },
      ),
    );
  }

  List<ContactItem> _getFilteredContacts(ContactBlockState state) {
    if (_selectedTab == 0) {
      return state.filteredContacts; // 모든 연락처 (검색 포함)
    } else {
      final blockedContacts = state.blockedContactItems;
      if (state.searchQuery.isEmpty) {
        return blockedContacts;
      } else {
        // 차단된 연락처에서 검색
        return blockedContacts.where((contact) {
          final query = state.searchQuery.toLowerCase();
          return contact.name.toLowerCase().contains(query) ||
                 contact.phone.contains(state.searchQuery);
        }).toList();
      }
    }
  }

  Widget _buildContactItem(ContactItem contact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // 프로필 이미지 또는 초기화
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.divider,
              shape: BoxShape.circle,
            ),
            child: _buildDefaultAvatar(contact.name),
          ),
          const SizedBox(width: 12),
          
          // 연락처 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact.phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          
          // 차단/해제 버튼
          GestureDetector(
            onTap: () => _toggleBlock(contact),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: contact.isBlocked ? const Color(0xFFF5F5F5) : Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: contact.isBlocked ? Border.all(color: const Color(0xFFE0E0E0)) : null,
              ),
              child: Text(
                contact.isBlocked ? '차단해제' : '차단하기',
                style: TextStyle(
                  color: contact.isBlocked ? const Color(0xFF666666) : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Future<void> _toggleBlock(ContactItem contact) async {
    final success = await ref.read(contactBlockProvider.notifier)
        .toggleContactBlock(contact, reason: '지인차단');

    if (success && mounted) {
      final action = !contact.isBlocked ? '차단' : '해제';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${contact.name} 연락처를 ${action}했습니다.'),
          backgroundColor: !contact.isBlocked ? const Color(0xFF4CAF50) : AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('연락처 차단 처리 중 오류가 발생했습니다.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}