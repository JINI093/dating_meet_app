import 'package:flutter/material.dart';
import '../utils/admin_theme.dart';

/// 필터 아이템 모델
class FilterItem {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  FilterItem({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
}

/// 필터 바 위젯
class FilterBar extends StatefulWidget {
  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final List<FilterItem> filters;
  final Function(DateTime?, DateTime?)? onDateRangeChanged;
  final bool showDateFilter;

  const FilterBar({
    super.key,
    required this.searchController,
    required this.searchHint,
    this.onSearchChanged,
    this.filters = const [],
    this.onDateRangeChanged,
    this.showDateFilter = true,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AdminTheme.mobileBreakpoint;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AdminTheme.spacingL),
        child: Column(
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  flex: isMobile ? 1 : 2,
                  child: TextField(
                    controller: widget.searchController,
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AdminTheme.radiusM),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AdminTheme.spacingM,
                        vertical: AdminTheme.spacingS,
                      ),
                    ),
                    onChanged: widget.onSearchChanged,
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: AdminTheme.spacingM),
                  if (widget.showDateFilter) _buildDateRangeButton(),
                ],
              ],
            ),
            
            if (isMobile && widget.showDateFilter) ...[
              const SizedBox(height: AdminTheme.spacingM),
              _buildDateRangeButton(),
            ],
            
            // Filters
            if (widget.filters.isNotEmpty) ...[
              const SizedBox(height: AdminTheme.spacingM),
              if (isMobile)
                _buildMobileFilters()
              else
                _buildDesktopFilters(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFilters() {
    return Wrap(
      spacing: AdminTheme.spacingM,
      runSpacing: AdminTheme.spacingS,
      children: widget.filters.map((filter) {
        return SizedBox(
          width: 160,
          child: _buildFilterDropdown(filter),
        );
      }).toList(),
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: widget.filters.map((filter) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AdminTheme.spacingS),
          child: _buildFilterDropdown(filter),
        );
      }).toList(),
    );
  }

  Widget _buildFilterDropdown(FilterItem filter) {
    return DropdownButtonFormField<String>(
      value: filter.value,
      decoration: InputDecoration(
        labelText: filter.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminTheme.radiusM),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AdminTheme.spacingM,
          vertical: AdminTheme.spacingS,
        ),
      ),
      items: filter.items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          filter.onChanged(value);
        }
      },
    );
  }

  Widget _buildDateRangeButton() {
    final dateText = _startDate != null && _endDate != null
        ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
        : '날짜 선택';
    
    return OutlinedButton.icon(
      onPressed: _selectDateRange,
      icon: const Icon(Icons.date_range),
      label: Text(
        dateText,
        style: TextStyle(
          color: _startDate != null && _endDate != null
              ? AdminTheme.primaryColor
              : AdminTheme.secondaryTextColor,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AdminTheme.spacingM,
          vertical: AdminTheme.spacingM,
        ),
        side: BorderSide(
          color: _startDate != null && _endDate != null
              ? AdminTheme.primaryColor
              : AdminTheme.borderColor,
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AdminTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
      });
      
      widget.onDateRangeChanged?.call(_startDate, _endDate);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}