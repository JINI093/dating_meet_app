import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';
import '../../core/constants/app_constants.dart';

class FilterBottomSheet extends StatefulWidget {
  final String filterType;

  const FilterBottomSheet({
    super.key,
    required this.filterType,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedRegion;
  double selectedDistance = 50.0;
  String selectedPopularity = '슈퍼챗 많은 순';

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
          _buildHandle(),
          
          // Header
          _buildHeader(),
          
          // Content
          Flexible(child: _buildContent()),
          
          // Apply Button
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.spacing12),
      width: AppDimensions.bottomSheetHandleWidth,
      height: AppDimensions.bottomSheetHandleHeight,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(
          AppDimensions.bottomSheetHandleHeight / 2,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    switch (widget.filterType) {
      case 'region':
        title = '지역 선택';
        break;
      case 'distance':
        title = '거리 설정';
        break;
      case 'popularity':
        title = '인기순 정렬';
        break;
      default:
        title = '필터';
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.bottomSheetPadding),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.h5,
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
    );
  }

  Widget _buildContent() {
    switch (widget.filterType) {
      case 'region':
        return _buildRegionContent();
      case 'distance':
        return _buildDistanceContent();
      case 'popularity':
        return _buildPopularityContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRegionContent() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.bottomSheetPadding,
      ),
      itemCount: AppConstants.koreanCities.length,
      itemBuilder: (context, index) {
        final city = AppConstants.koreanCities[index];
        final isSelected = selectedRegion == city;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedRegion = city;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spacing16,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.divider,
                  width: AppDimensions.dividerThickness,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  city,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isSelected 
                        ? AppColors.primary 
                        : AppColors.textPrimary,
                    fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.w400,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    CupertinoIcons.checkmark,
                    color: AppColors.primary,
                    size: AppDimensions.iconM,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDistanceContent() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.bottomSheetPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '반경 거리',
                style: AppTextStyles.bodyLarge,
              ),
              Text(
                '${selectedDistance.round()}km',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spacing24),
          
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: AppDimensions.filterSliderThumbSize / 2,
              ),
            ),
            child: Slider(
              value: selectedDistance,
              min: 1,
              max: AppConstants.maxSearchRadius.toDouble(),
              divisions: AppConstants.maxSearchRadius - 1,
              onChanged: (value) {
                setState(() {
                  selectedDistance = value;
                });
              },
            ),
          ),
          
          const SizedBox(height: AppDimensions.spacing16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1km',
                style: AppTextStyles.bodySmall,
              ),
              Text(
                '${AppConstants.maxSearchRadius}km',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularityContent() {
    final options = [
      '슈퍼챗 많은 순',
      '좋아요 많은 순',
      '최근 가입순',
      '온라인 순',
    ];

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.bottomSheetPadding,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selectedPopularity == option;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedPopularity = option;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spacing16,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.divider,
                  width: AppDimensions.dividerThickness,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  option,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isSelected 
                        ? AppColors.primary 
                        : AppColors.textPrimary,
                    fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.w400,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    CupertinoIcons.checkmark,
                    color: AppColors.primary,
                    size: AppDimensions.iconM,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.bottomSheetPadding),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _applyFilter,
          child: const Text('적용하기'),
        ),
      ),
    );
  }

  void _applyFilter() {
    // TODO: Apply filter logic
    Map<String, dynamic> filterData = {};
    
    switch (widget.filterType) {
      case 'region':
        if (selectedRegion != null) {
          filterData['region'] = selectedRegion;
        }
        break;
      case 'distance':
        filterData['distance'] = selectedDistance;
        break;
      case 'popularity':
        filterData['popularity'] = selectedPopularity;
        break;
    }
    
    Navigator.pop(context, filterData);
  }
}