import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _isAllNotificationsEnabled = true;

  // 더미 데이터
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'profileImage': 'assets/images/profile1.jpg',
      'title': '화수님께 좋아요를 받았습니다.',
      'subtitle': '좋아요를 누른 회원님을 확인해주세요!',
      'time': '5분 전',
      'isRead': false,
      'type': 'like',
    },
    {
      'id': '2',
      'profileImage': 'assets/images/profile2.jpg',
      'title': '민지님이 슈퍼챗을 가져왔습니다.',
      'subtitle': '슈퍼챗 발송에 성공된 300P가 적립되었습니다.',
      'time': '1시간 전',
      'isRead': false,
      'type': 'superchat',
    },
    {
      'id': '3',
      'profileImage': 'assets/images/profile3.jpg',
      'title': 'Jenny님께 좋아요를 받았습니다.',
      'subtitle': '좋아요를 누른 회원님을 확인해주세요!',
      'time': '2시간 전',
      'isRead': false,
      'type': 'like',
    },
    {
      'id': '4',
      'profileImage': 'assets/images/profile4.jpg',
      'title': '민지님께 메시지가 도착했습니다.',
      'subtitle': '먼저 온 메시지를 확인해주세요',
      'time': '3시간 전',
      'isRead': true,
      'type': 'message',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '알림',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Switch(
              value: _isAllNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _isAllNotificationsEnabled = value;
                });
              },
              activeColor: const Color(0xFFFF357B),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationItem(notification);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.bell,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '알림이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification['isRead'] ? Colors.white : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification['isRead'] ? const Color(0xFFE5E5E5) : const Color(0xFFFF357B).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 이미지
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: ClipOval(
              child: Image.asset(
                notification['profileImage'],
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 48,
                    height: 48,
                    color: const Color(0xFFF0F0F0),
                    child: const Icon(
                      CupertinoIcons.person,
                      color: Colors.grey,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 알림 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: notification['isRead'] ? FontWeight.w500 : FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['subtitle'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 8),
                // 확인하기 버튼
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                  ),
                  child: Text(
                    '확인하기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 시간 표시
          Text(
            notification['time'],
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}