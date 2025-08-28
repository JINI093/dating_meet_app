import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/Coupon.dart';
import '../providers/coupons_provider.dart';

class CouponEditDialog extends ConsumerStatefulWidget {
  final Coupon? coupon;

  const CouponEditDialog({
    super.key,
    this.coupon,
  });

  @override
  ConsumerState<CouponEditDialog> createState() => _CouponEditDialogState();
}

class _CouponEditDialogState extends ConsumerState<CouponEditDialog> {
  final TextEditingController _couponCodeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rewardAmountController = TextEditingController();
  final TextEditingController _maxUsageController = TextEditingController();
  
  String _selectedCouponType = 'ONE_PLUS_ONE';
  String _selectedRewardType = '하트';
  DateTime _selectedValidUntil = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  bool _isGeneratingCode = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.coupon != null) {
      _couponCodeController.text = widget.coupon!.couponCode ?? '';
      _titleController.text = widget.coupon!.title ?? '';
      _descriptionController.text = widget.coupon!.description ?? '';
      _selectedCouponType = widget.coupon!.couponType ?? 'ONE_PLUS_ONE';
      _selectedRewardType = widget.coupon!.rewardType ?? '하트';
      _rewardAmountController.text = widget.coupon!.rewardAmount?.toString() ?? '';
      _maxUsageController.text = widget.coupon!.maxUsage?.toString() ?? '0';
      _isActive = widget.coupon!.isActive ?? true;
      
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
    _couponCodeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardAmountController.dispose();
    _maxUsageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              widget.coupon == null ? '쿠폰 생성' : '쿠폰 수정',
              style: const TextStyle(
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
                    // 쿠폰 종류 선택
                    _buildSectionTitle('쿠폰종류'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCouponType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ONE_PLUS_ONE', child: Text('1+1 쿠폰')),
                        DropdownMenuItem(value: 'PRODUCT_REWARD', child: Text('상품지급 쿠폰')),
                        DropdownMenuItem(value: 'POINT_REWARD', child: Text('포인트 지급 쿠폰')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCouponType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // 할인 종류 (1+1 쿠폰인 경우) 또는 보상 종류
                    if (_selectedCouponType != 'POINT_REWARD') ...[
                      _buildSectionTitle(_selectedCouponType == 'ONE_PLUS_ONE' ? '할인' : '쿠폰명'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedRewardType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: '하트', child: Text('하트')),
                          DropdownMenuItem(value: '슈퍼챗', child: Text('슈퍼챗')),
                          DropdownMenuItem(value: '프로필 열람권', child: Text('프로필 열람권')),
                          DropdownMenuItem(value: '추천카드', child: Text('추천카드')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRewardType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // 보상 수량 (포인트 지급이나 상품지급 쿠폰인 경우)
                    if (_selectedCouponType != 'ONE_PLUS_ONE') ...[
                      _buildSectionTitle(_selectedCouponType == 'POINT_REWARD' ? '지급 포인트' : '지급 보인트'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _rewardAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '보상 수량을 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // 쿠폰 코드
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('발행할 쿠폰 코드'),
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
                    
                    // 제목
                    _buildSectionTitle('제목'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: '쿠폰 제목을 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 설명
                    _buildSectionTitle('쿠폰 설명'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '쿠폰에 대한 설명을 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 유효기간
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
                    const SizedBox(height: 24),
                    
                    // 사용 제한
                    _buildSectionTitle('사용 제한 (0이면 무제한)'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _maxUsageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '최대 사용 가능 횟수',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 활성 상태
                    Row(
                      children: [
                        const Text(
                          '쿠폰 활성화',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Switch(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                          activeColor: Colors.green,
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
                  onPressed: _saveCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(widget.coupon == null ? '쿠폰 생성' : '쿠폰 수정'),
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
      final code = await ref.read(couponsProvider.notifier).generateUniqueCouponCode();
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

  Future<void> _saveCoupon() async {
    if (_couponCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('쿠폰 코드를 입력해주세요')),
      );
      return;
    }

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('쿠폰 제목을 입력해주세요')),
      );
      return;
    }

    Navigator.of(context).pop();
    
    final rewardAmount = _selectedCouponType == 'ONE_PLUS_ONE' 
        ? 1 
        : int.tryParse(_rewardAmountController.text) ?? 0;
    final maxUsage = int.tryParse(_maxUsageController.text) ?? 0;
    
    if (widget.coupon == null) {
      // 새 쿠폰 생성
      await ref.read(couponsProvider.notifier).createCoupon(
        couponCode: _couponCodeController.text,
        couponType: _selectedCouponType,
        title: _titleController.text,
        description: _descriptionController.text,
        rewardType: _selectedCouponType == 'POINT_REWARD' ? null : _selectedRewardType,
        rewardAmount: rewardAmount,
        validUntil: _selectedValidUntil.toIso8601String().split('T')[0],
        isActive: _isActive,
        maxUsage: maxUsage,
      );
    } else {
      // 기존 쿠폰 수정
      final updatedCoupon = widget.coupon!.copyWith(
        couponCode: _couponCodeController.text,
        couponType: _selectedCouponType,
        title: _titleController.text,
        description: _descriptionController.text,
        rewardType: _selectedCouponType == 'POINT_REWARD' ? null : _selectedRewardType,
        rewardAmount: rewardAmount,
        validUntil: _selectedValidUntil.toIso8601String().split('T')[0],
        isActive: _isActive,
        maxUsage: maxUsage,
      );
      await ref.read(couponsProvider.notifier).updateCoupon(updatedCoupon);
    }
  }
}