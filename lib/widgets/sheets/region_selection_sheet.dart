import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

class RegionSelectionSheet extends StatefulWidget {
  final String selectedRegion;

  const RegionSelectionSheet({
    super.key,
    required this.selectedRegion,
  });

  @override
  State<RegionSelectionSheet> createState() => _RegionSelectionSheetState();
}

class _RegionSelectionSheetState extends State<RegionSelectionSheet> {
  late String _selectedRegion;

  final List<String> _regions = [
    '전체',
    '서울',
    '부산',
    '대구',
    '인천',
    '광주',
    '대전',
    '울산',
    '세종',
    '경기',
    '강원',
    '충북',
    '충남',
    '전북',
    '전남',
    '경북',
    '경남',
    '제주',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRegion = widget.selectedRegion;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.spacing12),
            width: AppDimensions.bottomSheetHandleWidth,
            height: AppDimensions.bottomSheetHandleHeight,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(
                AppDimensions.bottomSheetHandleHeight / 2,
              ),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.bottomSheetPadding),
            child: Row(
              children: [
                Text(
                  '지역 선택',
                  style: AppTextStyles.h5.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: AppColors.textSecondary,
                    size: AppDimensions.iconM,
                  ),
                ),
              ],
            ),
          ),
          
          // Region List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _regions.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: AppColors.divider,
              ),
              itemBuilder: (context, index) {
                final region = _regions[index];
                final isSelected = region == _selectedRegion;
                
                return ListTile(
                  title: Text(
                    region,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          color: AppColors.primary,
                          size: AppDimensions.iconM,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedRegion = region;
                    });
                  },
                );
              },
            ),
          ),
          
          // Apply Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.bottomSheetPadding),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedRegion);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                minimumSize: const Size(double.infinity, AppDimensions.buttonHeightL),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
              ),
              child: Text(
                '적용하기',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}