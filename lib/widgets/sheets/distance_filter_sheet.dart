import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

class DistanceFilterSheet extends StatefulWidget {
  final String selectedDistance;

  const DistanceFilterSheet({
    super.key,
    required this.selectedDistance,
  });

  @override
  State<DistanceFilterSheet> createState() => _DistanceFilterSheetState();
}

class _DistanceFilterSheetState extends State<DistanceFilterSheet> {
  late String _selectedDistance;
  double _currentSliderValue = 5.0;

  final List<String> _presetDistances = [
    '범위',
    '전체',
    '1km 내',
    '3km 내',
    '5km 내',
    '10km 내',
    '20km 내',
    '50km 내',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDistance = widget.selectedDistance;
    _currentSliderValue = _getSliderValueFromDistance(_selectedDistance);
  }

  double _getSliderValueFromDistance(String distance) {
    switch (distance) {
      case '1km 내':
        return 1.0;
      case '3km 내':
        return 3.0;
      case '5km 내':
        return 5.0;
      case '10km 내':
        return 10.0;
      case '20km 내':
        return 20.0;
      case '50km 내':
        return 50.0;
      case '범위':
        return 5.0;
      default:
        return 5.0;
    }
  }

  String _getDistanceFromSliderValue(double value) {
    if (value <= 1) return '1km 내';
    if (value <= 3) return '3km 내';
    if (value <= 5) return '5km 내';
    if (value <= 10) return '10km 내';
    if (value <= 20) return '20km 내';
    if (value <= 50) return '50km 내';
    return '50km 내';
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
                  '거리 선택',
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
          
          // Distance Slider
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.bottomSheetPadding,
              vertical: AppDimensions.spacing16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '최대 거리: ${_getDistanceFromSliderValue(_currentSliderValue)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing16),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.divider,
                    thumbColor: AppColors.primary,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    overlayColor: AppColors.primary.withValues(alpha: 0.1),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _currentSliderValue,
                    min: 1,
                    max: 50,
                    divisions: 5,
                    onChanged: (value) {
                      setState(() {
                        _currentSliderValue = value;
                        _selectedDistance = _getDistanceFromSliderValue(value);
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1km',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                    Text(
                      '50km',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Preset Options
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.bottomSheetPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '빠른 선택',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing12),
                Wrap(
                  spacing: AppDimensions.spacing8,
                  runSpacing: AppDimensions.spacing8,
                  children: _presetDistances.map((distance) {
                    final isSelected = distance == _selectedDistance;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDistance = distance;
                          _currentSliderValue = _getSliderValueFromDistance(distance);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing12,
                          vertical: AppDimensions.spacing8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.background,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.cardBorder,
                          ),
                        ),
                        child: Text(
                          distance,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Apply Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.bottomSheetPadding),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedDistance);
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