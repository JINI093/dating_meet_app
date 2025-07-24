import 'package:flutter/material.dart';

class PhoneNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final String? errorText;
  final bool enabled;

  const PhoneNumberInput({
    Key? key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      enabled: enabled,
      maxLength: 13, // 010-1234-5678
      decoration: InputDecoration(
        labelText: '휴대폰 번호',
        hintText: hintText ?? '010-0000-0000',
        errorText: errorText,
        prefixIcon: const Icon(Icons.phone_android),
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (value) {
        // 자동 하이픈 처리 (간단 예시)
        String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.length >= 11) {
          controller.text = '${digits.substring(0,3)}-${digits.substring(3,7)}-${digits.substring(7,11)}';
          controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
        } else if (digits.length >= 7) {
          controller.text = '${digits.substring(0,3)}-${digits.substring(3,7)}-${digits.substring(7)}';
          controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
        } else if (digits.length >= 4) {
          controller.text = '${digits.substring(0,3)}-${digits.substring(3)}';
          controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
        }
        if (onChanged != null) onChanged!(controller.text);
      },
    );
  }
} 