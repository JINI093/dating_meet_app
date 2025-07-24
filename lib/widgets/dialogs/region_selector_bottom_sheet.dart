import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_constants.dart';
import '../../utils/app_colors.dart';

class RegionSelectorBottomSheet extends StatefulWidget {
  final String? initialSido;
  final String? initialGugun;
  final void Function(String sido, String gugun) onSelected;

  const RegionSelectorBottomSheet({
    super.key,
    this.initialSido,
    this.initialGugun,
    required this.onSelected,
  });

  @override
  State<RegionSelectorBottomSheet> createState() => _RegionSelectorBottomSheetState();
}

class _RegionSelectorBottomSheetState extends State<RegionSelectorBottomSheet> {
  late String _selectedSido;
  String? _selectedGugun;

  @override
  void initState() {
    super.initState();
    _selectedSido = widget.initialSido ?? AppConstants.kRegions.keys.first;
    _selectedGugun = widget.initialGugun;
  }

  @override
  Widget build(BuildContext context) {
    final sidos = AppConstants.kRegions.keys.toList();
    final guguns = AppConstants.kRegions[_selectedSido] ?? [];

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 16, left: 0, right: 0, bottom: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Text('지역설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 본문
            SizedBox(
              height: 340,
              child: Row(
                children: [
                  // 시/도
                  Container(
                    width: 80,
                    color: const Color(0xFFF8F8F8),
                    child: ListView.builder(
                      itemCount: sidos.length,
                      itemBuilder: (context, idx) {
                        final sido = sidos[idx];
                        final selected = _selectedSido == sido;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedSido = sido;
                            _selectedGugun = null;
                          }),
                          child: Container(
                            color: selected ? Colors.white : Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            child: Text(
                              sido,
                              style: TextStyle(
                                color: selected ? AppColors.primary : AppColors.textSecondary,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // 구/군
                  Expanded(
                    child: ListView.builder(
                      itemCount: guguns.length,
                      itemBuilder: (context, idx) {
                        final gugun = guguns[idx];
                        final selected = _selectedGugun == gugun;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedGugun = gugun),
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            child: Row(
                              children: [
                                Text(
                                  gugun,
                                  style: TextStyle(
                                    color: selected ? AppColors.primary : AppColors.textPrimary,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                                const Spacer(),
                                if (selected)
                                  const Icon(CupertinoIcons.check_mark, color: AppColors.primary, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // 선택 지역 태그
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Text('선택 지역', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  if (_selectedSido.isNotEmpty && _selectedGugun != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_selectedSido $_selectedGugun',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _selectedGugun = null),
                            child: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.primary, size: 18),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // 설정 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  onPressed: (_selectedSido.isNotEmpty && _selectedGugun != null)
                      ? () {
                          widget.onSelected(_selectedSido, _selectedGugun!);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 