import 'package:flutter/material.dart';

class OrderStatusChip extends StatelessWidget {
  final String status;
  const OrderStatusChip({Key? key, required this.status}) : super(key: key);

  Color _getColor(BuildContext context) {
    switch (status) {
      case '완료':
      case 'success':
        return Theme.of(context).colorScheme.primary;
      case '진행중':
      case 'pending':
        return Colors.orange;
      case '실패':
      case 'fail':
        return Colors.redAccent;
      default:
        return Theme.of(context).disabledColor;
    }
  }

  String _getLabel() {
    switch (status) {
      case 'success':
        return '완료';
      case 'pending':
        return '진행중';
      case 'fail':
        return '실패';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_getLabel(), style: const TextStyle(color: Colors.white)),
      backgroundColor: _getColor(context),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );
  }
} 