import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/DiscountCoupon.dart';
import '../providers/discount_coupons_provider.dart';

class DiscountCouponDialog extends ConsumerStatefulWidget {
  final DiscountCoupon? coupon;

  const DiscountCouponDialog({
    super.key,
    this.coupon,
  });

  @override
  ConsumerState<DiscountCouponDialog> createState() => _DiscountCouponDialogState();
}

class _DiscountCouponDialogState extends ConsumerState<DiscountCouponDialog> {
  final TextEditingController _couponNameController = TextEditingController();
  final TextEditingController _recipientUserIdController = TextEditingController();
  final TextEditingController _discountRateController = TextEditingController();
  final TextEditingController _couponCodeController = TextEditingController();
  
  DateTime _selectedValidUntil = DateTime.now().add(const Duration(days: 30));
  bool _isGeneratingCode = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.coupon != null) {
      _couponNameController.text = widget.coupon!.couponName ?? '';
      _recipientUserIdController.text = widget.coupon!.recipientUserId ?? '';
      _discountRateController.text = widget.coupon!.discountRate?.toString() ?? '';
      _couponCodeController.text = widget.coupon!.couponCode ?? '';
      
      if (widget.coupon!.validUntil != null) {
        try {
          _selectedValidUntil = DateTime.parse(widget.coupon!.validUntil!);
        } catch (e) {
          _selectedValidUntil = DateTime.now().add(const Duration(days: 30));
        }
      }
    }
  }

  @override
  void dispose() {
    _couponNameController.dispose();
    _recipientUserIdController.dispose();
    _discountRateController.dispose();
    _couponCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            const Text(
              '할인쿠폰생성',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // 스크롤 가능한 폼
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 쿠폰명
                    _buildSectionTitle('쿠폰명'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _couponNameController,
                      decoration: InputDecoration(
                        hintText: '쿠폰명을 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 쿠폰 받는 아이디
                    _buildSectionTitle('쿠폰 받는 아이디'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _recipientUserIdController,
                      decoration: InputDecoration(
                        hintText: '사용자 ID를 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 항목(할인율)
                    _buildSectionTitle('항목(할인율)'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _discountRateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '할인율을 입력하세요 (예: 30)',
                        suffixText: '%',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 발행할 쿠폰 코드
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('발행 할 쿠폰 코드'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _couponCodeController,
                                decoration: InputDecoration(
                                  hintText: '쿠폰 코드를 입력하세요',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _isGeneratingCode ? null : _generateCouponCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: _isGeneratingCode 
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('코드발행'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // 쿠폰 유효 기간
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('쿠폰 유효 기간'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_selectedValidUntil.year}.${_selectedValidUntil.month.toString().padLeft(2, '0')}.${_selectedValidUntil.day.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _selectDate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: const Text('날짜선택'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 액션 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveDiscountCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('할인쿠폰 생성'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Future<void> _generateCouponCode() async {
    setState(() {
      _isGeneratingCode = true;
    });

    try {
      final code = await ref.read(discountCouponsProvider.notifier).generateUniqueCouponCode();
      _couponCodeController.text = code;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingCode = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedValidUntil,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // 2년 후까지
    );
    if (picked != null && picked != _selectedValidUntil) {
      setState(() {
        _selectedValidUntil = picked;
      });
    }
  }

  Future<void> _saveDiscountCoupon() async {
    if (_couponNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('쿠폰명을 입력해주세요')),
      );
      return;
    }

    if (_recipientUserIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('쿠폰 받는 아이디를 입력해주세요')),
      );
      return;
    }

    if (_couponCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('쿠폰 코드를 입력해주세요')),
      );
      return;
    }

    final discountRate = int.tryParse(_discountRateController.text);
    if (discountRate == null || discountRate <= 0 || discountRate > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 할인율을 입력해주세요 (1-100)')),
      );
      return;
    }

    Navigator.of(context).pop();
    
    if (widget.coupon == null) {
      // 새 할인쿠폰 생성
      await ref.read(discountCouponsProvider.notifier).createDiscountCoupon(
        couponName: _couponNameController.text,
        recipientUserId: _recipientUserIdController.text,
        discountRate: discountRate,
        couponCode: _couponCodeController.text,
        validUntil: _selectedValidUntil.toIso8601String().split('T')[0],
      );
    } else {
      // 기존 할인쿠폰 수정
      final updatedCoupon = widget.coupon!.copyWith(
        couponName: _couponNameController.text,
        recipientUserId: _recipientUserIdController.text,
        discountRate: discountRate,
        couponCode: _couponCodeController.text,
        validUntil: _selectedValidUntil.toIso8601String().split('T')[0],
      );
      await ref.read(discountCouponsProvider.notifier).updateDiscountCoupon(updatedCoupon);
    }
  }
}