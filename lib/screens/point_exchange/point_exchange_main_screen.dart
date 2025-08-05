import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../routes/route_names.dart';

class PointExchangeMainScreen extends StatelessWidget {
  final int userPoint;
  const PointExchangeMainScreen({Key? key, required this.userPoint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => context.go(RouteNames.profile),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 포인트 <-> 상품권 섹션
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _PointCard(userPoint: userPoint),
                ),
                const SizedBox(width: 20),
                const Icon(
                  CupertinoIcons.right_chevron,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: _GiftCard(),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // 전환신청하기 버튼
            Center(
              child: Container(
                width: 120,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    // 상품권 전환 신청 완료 화면 이동
                    context.go(RouteNames.pointsSuccess);
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
                    '전환신청하기',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 안내사항 타이틀
            const Text(
              '안내사항',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 구분선
            Container(
              height: 1,
              color: const Color(0xFFE0E0E0),
            ),
            
            const SizedBox(height: 16),
            
            // 안내사항 리스트
            const _NoticeList(),
          ],
        ),
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  final int userPoint;
  const _PointCard({required this.userPoint});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '포인트',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Image.asset(
            'assets/icons/coins.png',
            width: 56,
            height: 56,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 32,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            '1,000P',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  const _GiftCard();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '상품권',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Image.asset(
            'assets/icons/point.png',
            width: 56,
            height: 56,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 32,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          const Text(
            '100,000원',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeList extends StatelessWidget {
  const _NoticeList();
  
  @override
  Widget build(BuildContext context) {
    final List<String> notices = [
      '회차별 최대 전환 가능 포인트는 30,000P(300만 상품권) 입니다.',
      '전환 약수는 1,000P(10만 상품권) 단위로만 전환이 가능합니다.',
      '상품권은 매월 1일, 15일 전환이 가능합니다.',
      '지급 되는 상품권은 현대, 신세계, 롯데 상품권 중 랜덤으로 지급되며 선택은 불가능 합니다.',
      '모바일 상품권 특성상 전환 신청일로부터 영업일 기준 최대 10~15일 소요 될 수 있습니다.',
      '모바일 상품권으로 교환신청을 하면 다시 포인트로 전환할 수 없습니다. 신중하게 포인트 전환을 하시기 바랍니다.',
      '모바일 상품권 특성상 30일 이후의 사용기간이 지나 사용이 불가능 하여도 재발급, 포인트 전환은 불가합니다.',
      '지로 상품권 전환시 상품권의 하여 최대 교환·배송 유효기간은 상이합니다. 상품권 도착은 받은날 모바일 상품권의 고객센터로 문의하시기 바랍니다.',
      '상품권 전환 이벤트는 당사의 사정에 따라 사전 예고 없이 지급 금액 변동이나 종료 될 수 있습니다.',
      '비정상적인 루트로 포인트를 지급 받으시나 상품권 전환시 포인트 회수 및 당사 정책에 따라 조치가 취해질 수 있습니다.',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(notices.length, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
            ),
            Expanded(
              child: Text(
                notices[index],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
} 