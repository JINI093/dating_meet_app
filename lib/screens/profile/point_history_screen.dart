import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PointHistoryScreen extends StatefulWidget {
  const PointHistoryScreen({super.key});

  @override
  State<PointHistoryScreen> createState() => _PointHistoryScreenState();
}

class _PointHistoryScreenState extends State<PointHistoryScreen> {
  int _selectedTab = 0; // 0: 포인트 충전/적립, 1: 포인트 사용

  final List<PointHistoryItem> _chargeHistory = [
    PointHistoryItem(
      amount: '+500P',
      description: '포인트 상점 충전',
      date: '2025.02.15',
    ),
    PointHistoryItem(
      amount: '+2,000P',
      description: '포인트 상점 충전',
      date: '2025.02.10',
    ),
    PointHistoryItem(
      amount: '+60P',
      description: '감지된 추천인 적립',
      date: '2025.01.24',
    ),
    PointHistoryItem(
      amount: '+50P',
      description: '슈퍼챗 환불',
      date: '2025.01.17',
    ),
    PointHistoryItem(
      amount: '+100P',
      description: '포인트 상점 충전',
      date: '2025.01.10',
    ),
  ];

  final List<PointHistoryItem> _usageHistory = [
    PointHistoryItem(
      amount: '-30P',
      description: '슈퍼챗 사용',
      date: '2025.02.14',
    ),
    PointHistoryItem(
      amount: '-50P',
      description: '프로필 부스터 사용',
      date: '2025.02.12',
    ),
    PointHistoryItem(
      amount: '-20P',
      description: '슈퍼챗 사용',
      date: '2025.02.08',
    ),
  ];

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
          '포인트 현황',
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
          // 탭 버튼들
          Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? const Color(0xFFFF357B) : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        '포인트 충전/적립',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == 0 ? Colors.white : const Color(0xFF999999),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? const Color(0xFFFF357B) : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        '포인트 사용',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _selectedTab == 1 ? Colors.white : const Color(0xFF999999),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 포인트 내역 리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _selectedTab == 0 ? _chargeHistory.length : _usageHistory.length,
              itemBuilder: (context, index) {
                final item = _selectedTab == 0 ? _chargeHistory[index] : _usageHistory[index];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFF0F0F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.amount,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: item.amount.startsWith('+') ? Colors.black : const Color(0xFFFF357B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item.date,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999999),
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
}

class PointHistoryItem {
  final String amount;
  final String description;
  final String date;

  PointHistoryItem({
    required this.amount,
    required this.description,
    required this.date,
  });
}