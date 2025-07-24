import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../routes/route_names.dart';

class ExchangeSuccessScreen extends StatelessWidget {
  const ExchangeSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '포인트 전환',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 상단 여백

            
            // 중앙 이미지
            Center(
              child: Image.asset(
                'assets/icons/points.png',
                width: 300,
                height: 300,
              ),
            ),
            
            
            // 메인 메시지
            const Text(
              '요청하신 상품권\n신청이\n완료되었습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.3,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 안내 메시지
            const Text(
              '모바일 상품권 특성상 전환 신청일로부터 영업일 기준 최대\n10~15일 소요 될 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                height: 1.4,
              ),
            ),
            
            const Spacer(),
            
            // 확인 버튼
            Container(
              width: 120,
              height: 36,
              margin: const EdgeInsets.only(bottom: 80),
              child: ElevatedButton(
                onPressed: () {
                  context.go(RouteNames.home);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 