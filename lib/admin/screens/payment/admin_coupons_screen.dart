import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/coupons_provider.dart';
import '../../../models/Coupon.dart';
import '../../widgets/coupon_edit_dialog.dart';
import '../../widgets/discount_coupon_dialog.dart';
import '../../widgets/referral_code_dialog.dart';

/// 쿠폰 및 코드 관리 화면
class AdminCouponsScreen extends ConsumerStatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  ConsumerState<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends ConsumerState<AdminCouponsScreen> {
  @override
  Widget build(BuildContext context) {
    final couponsState = ref.watch(couponsProvider);
    
    return Container(
      color: const Color(0xFFF5F7FA),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '쿠폰 생성 및 추천인 코드 관리',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _addDiscountCoupon,
                    icon: const Icon(Icons.local_offer, size: 20),
                    label: const Text('할인쿠폰생성'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _addCoupon,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('쿠폰 생성'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _addReferralCode,
                    icon: const Icon(Icons.person_add, size: 20),
                    label: const Text('추천인 코드 관리'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 에러 메시지
          if (couponsState.error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                couponsState.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          
          // 테이블
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 테이블 헤더
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildTableHeader('쿠폰 코드', flex: 2),
                        _buildTableHeader('쿠폰 종류', flex: 2),
                        _buildTableHeader('제목', flex: 2),
                        _buildTableHeader('보상', flex: 2),
                        _buildTableHeader('유효기간', flex: 2),
                        _buildTableHeader('사용/제한', flex: 1),
                        _buildTableHeader('상태', flex: 1),
                        _buildTableHeader('관리', flex: 1),
                      ],
                    ),
                  ),
                  
                  // 테이블 내용
                  Expanded(
                    child: couponsState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : couponsState.coupons.isEmpty
                            ? const Center(
                                child: Text(
                                  '등록된 쿠폰이 없습니다',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: couponsState.coupons.length,
                                itemBuilder: (context, index) {
                                  final coupon = couponsState.coupons[index];
                                  return _buildTableRow(coupon, index);
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTableRow(Coupon coupon, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          // 쿠폰 코드
          Expanded(
            flex: 2,
            child: Text(
              coupon.couponCode ?? '-',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // 쿠폰 종류
          Expanded(
            flex: 2,
            child: _buildCouponTypeChip(coupon.couponType ?? ''),
          ),
          // 제목
          Expanded(
            flex: 2,
            child: Text(
              coupon.title ?? '-',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          // 보상
          Expanded(
            flex: 2,
            child: Text(
              _getRewardText(coupon),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          // 유효기간
          Expanded(
            flex: 2,
            child: Text(
              coupon.validUntil ?? '-',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          // 사용/제한
          Expanded(
            flex: 1,
            child: Text(
              '${coupon.usageCount ?? 0}/${coupon.maxUsage == 0 ? '∞' : coupon.maxUsage}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          // 상태
          Expanded(
            flex: 1,
            child: Switch(
              value: coupon.isActive ?? false,
              onChanged: (value) {
                ref.read(couponsProvider.notifier).toggleCouponStatus(coupon.id, value);
              },
              activeColor: Colors.green,
            ),
          ),
          // 관리
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _editCoupon(coupon),
                  tooltip: '수정',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => _deleteCoupon(coupon),
                  tooltip: '삭제',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponTypeChip(String couponType) {
    String displayText;
    Color backgroundColor;
    
    switch (couponType) {
      case 'ONE_PLUS_ONE':
        displayText = '1+1 쿠폰';
        backgroundColor = Colors.purple;
        break;
      case 'PRODUCT_REWARD':
        displayText = '상품지급 쿠폰';
        backgroundColor = Colors.orange;
        break;
      case 'POINT_REWARD':
        displayText = '포인트 지급 쿠폰';
        backgroundColor = Colors.blue;
        break;
      default:
        displayText = couponType;
        backgroundColor = Colors.grey;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getRewardText(Coupon coupon) {
    if (coupon.couponType == 'POINT_REWARD') {
      return '${coupon.rewardAmount ?? 0} 포인트';
    } else if (coupon.couponType == 'PRODUCT_REWARD') {
      return '${coupon.rewardType ?? ''} ${coupon.rewardAmount ?? 0}개';
    } else if (coupon.couponType == 'ONE_PLUS_ONE') {
      return '${coupon.rewardType ?? ''} 1+1';
    }
    return '-';
  }

  void _addDiscountCoupon() {
    _showDiscountCouponDialog();
  }

  void _addCoupon() {
    _showCouponDialog();
  }

  void _addReferralCode() {
    _showReferralCodeDialog();
  }

  void _editCoupon(Coupon coupon) {
    _showCouponDialog(coupon: coupon);
  }

  void _deleteCoupon(Coupon coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('쿠폰 삭제'),
        content: Text('${coupon.title} 쿠폰을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(couponsProvider.notifier).deleteCoupon(coupon.id);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDiscountCouponDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DiscountCouponDialog(),
    );
  }

  void _showCouponDialog({Coupon? coupon}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CouponEditDialog(coupon: coupon),
    );
  }

  void _showReferralCodeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ReferralCodeDialog(),
    );
  }
}