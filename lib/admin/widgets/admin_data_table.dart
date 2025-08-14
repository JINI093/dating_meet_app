import 'package:flutter/material.dart';
import '../utils/admin_theme.dart';

/// 관리자 데이터 테이블
class AdminDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool isLoading;
  final Function(bool?)? onSelectAll;
  final int? sortColumnIndex;
  final bool sortAscending;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.onSelectAll,
    this.sortColumnIndex,
    this.sortAscending = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AdminTheme.primaryColor,
        ),
      );
    }

    if (rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AdminTheme.disabledTextColor,
            ),
            const SizedBox(height: AdminTheme.spacingM),
            Text(
              '데이터가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: AdminTheme.disabledTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AdminTheme.borderColor),
        borderRadius: BorderRadius.circular(AdminTheme.radiusM),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns,
          rows: rows,
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          onSelectAll: onSelectAll,
          showCheckboxColumn: onSelectAll != null,
          horizontalMargin: AdminTheme.spacingM,
          columnSpacing: AdminTheme.spacingM,
          headingRowColor: WidgetStateProperty.all(
            AdminTheme.primaryColor.withValues(alpha: 0.05),
          ),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          dataTextStyle: const TextStyle(
            fontSize: 14,
          ),
          headingRowHeight: 48,
          dataRowMinHeight: 56,
        ),
      ),
    );
  }
}