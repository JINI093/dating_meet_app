import 'package:flutter/material.dart';

class GiftCardCatalogScreen extends StatefulWidget {
  final int userPoint;
  final String userEmail;
  const GiftCardCatalogScreen({Key? key, required this.userPoint, required this.userEmail}) : super(key: key);

  @override
  State<GiftCardCatalogScreen> createState() => _GiftCardCatalogScreenState();
}

class _GiftCardCatalogScreenState extends State<GiftCardCatalogScreen> {
  late TextEditingController _emailController;
  int _giftCardCount = 0;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.userEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int maxGiftCards = widget.userPoint ~/ 1000;
    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트 전환'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Image.asset('assets/images/gift_card.png', height: 120),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('내 포인트', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${widget.userPoint} P', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('전환 약수는 1,000P(10만 상품권) 단위로만 전환이 가능합니다', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('상품권 전환', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _giftCardCount > 0 ? () => setState(() => _giftCardCount--) : null,
                    ),
                    Text('$_giftCardCount 장', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _giftCardCount < maxGiftCards ? () => setState(() => _giftCardCount++) : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('회차별 최대 전환 가능 포인트는 30,000P 입니다.\n자세한 사항은 안내사항을 참고해주세요', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 24),
            const Text('상품권 받을 정보', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '이메일 주소 입력',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('수정'),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _giftCardCount > 0 && _emailController.text.isNotEmpty
                    ? () {
                        // TODO: 포인트 차감 및 API 연동 후 성공 화면 이동
                        Navigator.pushNamed(context, '/exchange_success');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('전환신청하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 