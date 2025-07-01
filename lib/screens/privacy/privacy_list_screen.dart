import 'package:flutter/material.dart';

class PrivacyListScreen extends StatefulWidget {
  const PrivacyListScreen({super.key});

  @override
  State<PrivacyListScreen> createState() => _PrivacyListScreenState();
}

class _PrivacyListScreenState extends State<PrivacyListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보 관리'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '개인정보 관리',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text('개인정보 관리 화면입니다.'),
          ],
        ),
      ),
    );
  }
} 