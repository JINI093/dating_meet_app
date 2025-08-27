import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ReferralCode.dart';
import '../providers/referral_codes_provider.dart';

class ReferralCodeDialog extends ConsumerStatefulWidget {
  final ReferralCode? referralCode;

  const ReferralCodeDialog({
    super.key,
    this.referralCode,
  });

  @override
  ConsumerState<ReferralCodeDialog> createState() => _ReferralCodeDialogState();
}

class _ReferralCodeDialogState extends ConsumerState<ReferralCodeDialog> {
  final TextEditingController _referralCodeController = TextEditingController();
  final TextEditingController _recipientUserIdController = TextEditingController();
  final TextEditingController _rewardPointsController = TextEditingController();
  
  bool _isGeneratingCode = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.referralCode != null) {
      _referralCodeController.text = widget.referralCode!.referralCode ?? '';
      _recipientUserIdController.text = widget.referralCode!.recipientUserId ?? '';
      _rewardPointsController.text = widget.referralCode!.rewardPoints?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _referralCodeController.dispose();
    _recipientUserIdController.dispose();
    _rewardPointsController.dispose();
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
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            const Text(
              '추천인 코드 관리',
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
                    // 발행할 추천인 코드
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('발행할 추천인 코드'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _referralCodeController,
                                decoration: InputDecoration(
                                  hintText: '추천인 코드를 입력하세요',
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
                              onPressed: _isGeneratingCode ? null : _generateReferralCode,
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
                    
                    // 코드 받는 아이디
                    _buildSectionTitle('코드 받는 아이디'),
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
                    
                    // 적립 포인트
                    _buildSectionTitle('적립 포인트'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _rewardPointsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '적립할 포인트를 입력하세요',
                        suffixText: 'P',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
                  onPressed: _saveReferralCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('코드발행'),
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

  Future<void> _generateReferralCode() async {
    setState(() {
      _isGeneratingCode = true;
    });

    try {
      final code = await ref.read(referralCodesProvider.notifier).generateUniqueReferralCode();
      _referralCodeController.text = code;
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

  Future<void> _saveReferralCode() async {
    if (_referralCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('추천인 코드를 입력해주세요')),
      );
      return;
    }

    if (_recipientUserIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('코드 받는 아이디를 입력해주세요')),
      );
      return;
    }

    final rewardPoints = int.tryParse(_rewardPointsController.text);
    if (rewardPoints == null || rewardPoints <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 적립 포인트를 입력해주세요')),
      );
      return;
    }

    Navigator.of(context).pop();
    
    if (widget.referralCode == null) {
      // 새 추천인 코드 생성
      await ref.read(referralCodesProvider.notifier).createReferralCode(
        referralCode: _referralCodeController.text,
        recipientUserId: _recipientUserIdController.text,
        rewardPoints: rewardPoints,
      );
    } else {
      // 기존 추천인 코드 수정
      final updatedCode = widget.referralCode!.copyWith(
        referralCode: _referralCodeController.text,
        recipientUserId: _recipientUserIdController.text,
        rewardPoints: rewardPoints,
      );
      await ref.read(referralCodesProvider.notifier).updateReferralCode(updatedCode);
    }
  }
}