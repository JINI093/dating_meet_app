import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../routes/route_names.dart';
import '../../providers/point_exchange_provider.dart';
import '../../providers/points_provider.dart';

class PointExchangeMainScreen extends ConsumerStatefulWidget {
  final int userPoint;
  const PointExchangeMainScreen({Key? key, required this.userPoint}) : super(key: key);

  @override
  ConsumerState<PointExchangeMainScreen> createState() => _PointExchangeMainScreenState();
}

class _PointExchangeMainScreenState extends ConsumerState<PointExchangeMainScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(RouteNames.profile);
            }
          },
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
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Expanded(
            //       child: _PointCard(userPoint: widget.userPoint),
            //     ),
            //     const SizedBox(width: 20),
            //     const Icon(
            //       CupertinoIcons.right_chevron,
            //       size: 20,
            //       color: Colors.grey,
            //     ),
            //     const SizedBox(width: 20),
            //     const Expanded(
            //       child: _GiftCard(),
            //     ),
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/icons/ic_exchange_before.png"),
                Image.asset("assets/icons/ic_polygon_exchange.png"),
                GestureDetector(
                  onTap: () {
                    _handleExchangeRequest();
                  },
                    child: Image.asset("assets/icons/ic_exchange_after.png")
                )
              ],
            ),
            //
            // const SizedBox(height: 30),
            //
            // // 전환신청하기 버튼
            // Center(
            //   child: Container(
            //     width: 120,
            //     height: 36,
            //     child: ElevatedButton(
            //       onPressed: () => _handleExchangeRequest(),
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: const Color(0xFFFFA726),
            //         elevation: 0,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(18),
            //         ),
            //         padding: EdgeInsets.zero,
            //       ),
            //       child: const Text(
            //         '전환신청하기',
            //         style: TextStyle(
            //           fontSize: 15,
            //           fontWeight: FontWeight.w600,
            //           color: Colors.white,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            
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

  /// Handle exchange request with HonetCon API
  Future<void> _handleExchangeRequest() async {
    var pointsState = ref.read(pointsProvider);
    var userPoints = pointsState.currentPoints;
    // context.push(RouteNames.pointsCatalog, extra: { "CURRENT_POINT" : userPoints });
    try {
      // Show input dialog for email and additional info
      final result = await _showExchangeInputDialog();

      if (result == null) return; // User cancelled

      // Show loading dialog
      _showLoadingDialog();

      // Get current user points
      final pointsState = ref.read(pointsProvider);
      final userPoints = pointsState.currentPoints;

      // Calculate gift card value (1,000P = 100,000원)
      const int pointsToExchange = 1000;
      const int giftCardValue = 100000;

      if (userPoints < pointsToExchange) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          _showErrorDialog('보유 포인트가 부족합니다. (필요: ${pointsToExchange}P, 보유: ${userPoints}P)');
        }
        return;
      }

      // Call HonetCon API through provider
      final success = await ref.read(pointExchangeProvider.notifier).exchangePointsToGiftCard(
        points: pointsToExchange,
        giftCardType: 'random', // Random gift card type
        giftCardValue: giftCardValue,
        recipientEmail: result['email']!,
        recipientPhone: result['phone'],
        message: result['message'],
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (success) {
          // Navigate to success screen
          context.go(RouteNames.pointsSuccess);
        } else {
          // Show error from provider
          final exchangeState = ref.read(pointExchangeProvider);
          _showErrorDialog(exchangeState.error ?? '상품권 전환에 실패했습니다');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('오류가 발생했습니다: $e');
      }
    }
  }

  /// Show exchange input dialog
  Future<Map<String, String>?> _showExchangeInputDialog() async {
    _emailController.clear();
    _phoneController.clear();
    _messageController.clear();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '상품권 전환 신청',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('전환할 포인트: 1,000P'),
              const Text('받을 상품권: 100,000원'),
              const SizedBox(height: 16),
              
              // Email input
              const Text('이메일 주소 *', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: '상품권을 받을 이메일 주소',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
              
              // Phone input (optional)
              const Text('전화번호 (선택사항)', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '010-1234-5678',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
              
              // Message input (optional)
              const Text('메모 (선택사항)', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '추가 메모사항',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              
              const SizedBox(height: 16),
              Text(
                '• 상품권은 영업일 기준 10-15일 내에 이메일로 발송됩니다.\n• 전환 후 취소가 불가능하니 신중히 결정해주세요.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final email = _emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이메일 주소를 입력해주세요')),
                );
                return;
              }
              
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('올바른 이메일 주소를 입력해주세요')),
                );
                return;
              }

              Navigator.of(context).pop({
                'email': email,
                'phone': _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
                'message': _messageController.text.trim().isNotEmpty ? _messageController.text.trim() : null,
              });
            },
            child: const Text('전환 신청'),
          ),
        ],
      ),
    );
  }

  /// Show loading dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('상품권 전환 중...'),
          ],
        ),
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
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