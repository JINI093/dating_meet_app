import 'package:flutter/material.dart';

class PointSettingsScreen extends StatefulWidget {
  const PointSettingsScreen({super.key});

  @override
  State<PointSettingsScreen> createState() => _PointSettingsScreenState();
}

class _PointSettingsScreenState extends State<PointSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트 설정'),
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
              '포인트 설정',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text('포인트 설정 화면입니다.'),
          ],
        ),
      ),
    );
  }
} 