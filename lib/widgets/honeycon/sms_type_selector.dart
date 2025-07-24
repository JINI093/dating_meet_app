import 'package:flutter/material.dart';

class SmsTypeSelector extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;
  final List<String> types;

  const SmsTypeSelector({
    Key? key,
    required this.value,
    required this.onChanged,
    this.types = const ['M', 'L', 'S'],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: types.map((type) {
        String label;
        switch (type) {
          case 'M': label = '문자'; break;
          case 'L': label = '장문'; break;
          case 'S': label = '알림톡'; break;
          default: label = type;
        }
        final selected = value == type;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => onChanged(type),
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(color: selected ? Colors.white : null),
          ),
        );
      }).toList(),
    );
  }
} 