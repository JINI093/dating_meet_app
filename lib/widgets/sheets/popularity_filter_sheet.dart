import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

class PopularityFilterSheet extends StatefulWidget {
  final String selectedPopularity;

  const PopularityFilterSheet({
    super.key,
    required this.selectedPopularity,
  });

  @override
  State<PopularityFilterSheet> createState() => _PopularityFilterSheetState();
}

class _PopularityFilterSheetState extends State<PopularityFilterSheet> {
  late String _selectedPopularity;

  final List<Map<String, dynamic>> _popularityOptions = [
    {
      'value': '기본',
      'title': '기본',
      'description': '추천 알고리즘에 따른 순서',
      'icon': CupertinoIcons.shuffle,
    },
    {
      'value': '최신순',
      'title': '최신순',
      'description': '최근 가입한 순서',
      'icon': CupertinoIcons.clock,
    },
    {
      'value': '좋아요 많은 순',
      'title': '좋아요 많은 순',
      'description': '받은 좋아요가 많은 순서',
      'icon': CupertinoIcons.heart_fill,
    },
    {
      'value': '슈퍼챗 많은 순',
      'title': '슈퍼챗 많은 순',
      'description': '받은 슈퍼챗이 많은 순서',
      'icon': CupertinoIcons.paperplane_fill,
    },
    {
      'value': '거리순',
      'title': '가까운 거리순',
      'description': '나와 가까운 거리 순서',
      'icon': CupertinoIcons.location_fill,
    },
    {
      'value': '온라인순',
      'title': '온라인 먼저',
      'description': '현재 온라인인 사용자 우선',
      'icon': CupertinoIcons.dot_radiowaves_left_right,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedPopularity = widget.selectedPopularity;
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
                  '정렬 기준 선택',
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
          
          // Popularity Options
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _popularityOptions.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: AppColors.divider,
              ),
              itemBuilder: (context, index) {
                final option = _popularityOptions[index];
                final isSelected = option['value'] == _selectedPopularity;
                
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.bottomSheetPadding,
                    vertical: AppDimensions.spacing8,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      ),
                    ),
                    child: Icon(
                      option['icon'],
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      size: AppDimensions.iconM,
                    ),
                  ),
                  title: Text(
                    option['title'],
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  subtitle: Text(
                    option['description'],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          CupertinoIcons.checkmark_circle_fill,
                          color: AppColors.primary,
                          size: AppDimensions.iconM,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedPopularity = option['value'];
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
                Navigator.pop(context, _selectedPopularity);
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