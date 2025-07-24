import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class BlockContactsScreen extends StatefulWidget {
  const BlockContactsScreen({super.key});

  @override
  State<BlockContactsScreen> createState() => _BlockContactsScreenState();
}

class _BlockContactsScreenState extends State<BlockContactsScreen> {
  int _selectedTab = 0; // 0: 연락처, 1: 차단된 연락처
  
  final List<ContactItem> _contacts = [
    ContactItem(name: '홍길동', phone: '010-2345-6789', isBlocked: true),
    ContactItem(name: '홍길동', phone: '010-2345-6789', isBlocked: false),
    ContactItem(name: '홍길동', phone: '010-2345-6789', isBlocked: true),
    ContactItem(name: '홍길동', phone: '010-2345-6789', isBlocked: false),
    ContactItem(name: '홍길동', phone: '010-2345-6789', isBlocked: false),
    ContactItem(name: '홍길동', phone: '010-2345-6789', isBlocked: false),
    ContactItem(name: '홍길동', phone: '010-2345-6789', isBlocked: false),
    ContactItem(name: '홍길동', phone: '010-2345-6789', isBlocked: false),
  ];

  List<ContactItem> get _filteredContacts {
    if (_selectedTab == 0) {
      return _contacts; // 모든 연락처 표시
    } else {
      return _contacts.where((contact) => contact.isBlocked).toList(); // 차단된 연락처만 표시
    }
  }

  int get _blockedCount {
    return _contacts.where((contact) => contact.isBlocked).length;
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Column(
        children: [
          // 탭바
          Container(
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
                        '차단된 연락처($_blockedCount)',
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
          ),
          
          // 검색바
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(36),
            ),
            child: const Row(
              children: [
                Text(
                  '이름이나 번호 검색',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // 연락처 리스트
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
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
                      GestureDetector(
                        onTap: () => _toggleBlock(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: contact.isBlocked ? Colors.black : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                            border: contact.isBlocked ? null : Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Text(
                            contact.isBlocked ? '차단하기' : '차단해제',
                            style: TextStyle(
                              color: contact.isBlocked ? Colors.white : const Color(0xFF666666),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleBlock(int index) {
    setState(() {
      final filteredContact = _filteredContacts[index];
      // 원본 리스트에서 해당 연락처 찾기
      final originalIndex = _contacts.indexOf(filteredContact);
      if (originalIndex != -1) {
        _contacts[originalIndex].isBlocked = !_contacts[originalIndex].isBlocked;
      }
    });
  }
}

class ContactItem {
  final String name;
  final String phone;
  bool isBlocked;

  ContactItem({
    required this.name,
    required this.phone,
    required this.isBlocked,
  });
}