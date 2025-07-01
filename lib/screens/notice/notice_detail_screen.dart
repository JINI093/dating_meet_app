import 'package:flutter/material.dart';

class NoticeDetailScreen extends StatelessWidget {
  final String noticeId;
  
  const NoticeDetailScreen({super.key, required this.noticeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('공지사항 상세 화면 - ID: $noticeId'),
      ),
    );
  }
} 