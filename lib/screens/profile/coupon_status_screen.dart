import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CouponStatusScreen extends ConsumerStatefulWidget {
  const CouponStatusScreen({super.key});

  @override
  ConsumerState<CouponStatusScreen> createState() => _CouponStatusScreenState();
}

class _CouponStatusScreenState extends ConsumerState<CouponStatusScreen> {
  final TextEditingController _couponController = TextEditingController();
  List<Map<String, dynamic>> _registeredCoupons = []; // 등록된 쿠폰 리스트
  
  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

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
          '내 쿠폰 현황',
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
          // 쿠폰 번호 등록 입력 필드 (이미지 위에 텍스트 입력)
          Container(
            margin: const EdgeInsets.all(20),
            height: 50,
            child: Stack(
              children: [
                // 배경 이미지
                Image.asset(
                  'assets/icons/coupon_input.png',
                  width: double.infinity,
                  height: 50,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    // 이미지 로드 실패시 기존 스타일로 표시
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF02062),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    );
                  },
                ),
                // 텍스트 입력 필드
                Positioned.fill(
                  child: Row(
                    children: [
                      // 텍스트 입력 영역 (흰색 부분)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 30, right: 10),
                          alignment: Alignment.center,
                          color: Colors.transparent, // 투명 배경
                          child: TextField(
                            controller: _couponController,
                            decoration: const InputDecoration(
                              hintText: '쿠폰번호 등록',
                              hintStyle: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              filled: false, // 배경 채우기 비활성화
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      // 등록 버튼 영역
                      GestureDetector(
                        onTap: () => _registerCoupon(_couponController.text),
                        child: Container(
                          width: 80,
                          height: 50,
                          alignment: Alignment.center,
                          color: Colors.transparent, // 투명 배경
                          child: const Text(
                            '등록',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 쿠폰 목록
          Expanded(
            child: _buildCouponList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponList() {
    if (_registeredCoupons.isEmpty) {
      // 등록된 쿠폰이 없는 경우
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.ticket,
              size: 60,
              color: Color(0xFFCCCCCC),
            ),
            const SizedBox(height: 16),
            const Text(
              '등록된 쿠폰이 없습니다.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF999999),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '쿠폰 번호를 입력하여 등록해주세요.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFBBBBBB),
              ),
            ),
          ],
        ),
      );
    }
    
    // 등록된 쿠폰이 있는 경우
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _registeredCoupons.map((coupon) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCouponItem(
              icon: coupon['icon'] ?? '🎁',
              iconColor: const Color(0xFFFF6B9D),
              title: coupon['title'] ?? '쿠폰',
              subtitle: coupon['subtitle'] ?? '쿠폰',
              expiryDate: coupon['expiryDate'] ?? '유효기간',
              buttonText: '사용하기',
              onButtonTap: () => _useCoupon(coupon['title'] ?? '쿠폰'),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  void _registerCoupon(String couponCode) {
    if (couponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('쿠폰 번호를 입력해주세요.'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFFFF6B9D),
        ),
      );
      return;
    }
    
    // TODO: 실제 쿠폰 등록 로직 구현
    // 임시로 테스트 쿠폰 데이터 추가
    Map<String, dynamic>? newCoupon;
    
    // 쿠폰 코드에 따른 예시 쿠폰 (나중에 서버에서 받아올 데이터)
    if (couponCode.toUpperCase() == 'BIRTHDAY2025') {
      newCoupon = {
        'icon': '🎁',
        'title': '하트 + 1개',
        'subtitle': '생일 축하 쿠폰',
        'expiryDate': '2025.04.30 까지',
      };
    } else if (couponCode.toUpperCase() == 'WELCOME2025') {
      newCoupon = {
        'icon': '🎟️',
        'title': '쿠폰혜택',
        'subtitle': '쿠폰명',
        'expiryDate': '2025.04.30 까지',
      };
    } else if (couponCode.toUpperCase() == 'DISCOUNT10') {
      newCoupon = {
        'icon': '💰',
        'title': '10% 할인',
        'subtitle': '할인쿠폰',
        'expiryDate': '2025.04.30 까지',
      };
    }
    
    if (newCoupon != null) {
      setState(() {
        _registeredCoupons.add(newCoupon!);
      });
      _couponController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('쿠폰이 등록되었습니다.'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFFFF6B9D),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('유효하지 않은 쿠폰 번호입니다.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCouponItem({
    required String icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String expiryDate,
    required String buttonText,
    required VoidCallback onButtonTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 쿠폰 아이콘과 타이틀
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/coupon.png',
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 80,
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w800, // ExtraBold
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // 쿠폰 타이틀
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF02062), // 핑크색
              ),
            ),
          ),
          // 사용하기 버튼 및 유효기간
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onButtonTap,
                child: Container(
                  width: 69,
                  height: 39,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF02062),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                expiryDate,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _useCoupon(String couponName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '쿠폰 사용',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          '$couponName 쿠폰을 사용하시겠습니까?',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE0E0E0),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmCouponUse(couponName);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    '사용',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmCouponUse(String couponName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$couponName 쿠폰이 사용되었습니다.'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFFFF6B9D),
      ),
    );
  }
}