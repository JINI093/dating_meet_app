import 'package:flutter/material.dart';

class TicketSettingsScreen extends StatefulWidget {
  const TicketSettingsScreen({super.key});

  @override
  State<TicketSettingsScreen> createState() => _TicketSettingsScreenState();
}

class _TicketSettingsScreenState extends State<TicketSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('티켓 설정'),
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
              '티켓 설정',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text('티켓 설정 화면입니다.'),
          ],
        ),
      ),
    );
  }
} 