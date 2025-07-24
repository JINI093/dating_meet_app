import 'package:flutter/material.dart';

class GiftCardItem extends StatelessWidget {
  final String name;
  final int price;
  final String brand;
  final String? thumbnailUrl;
  final bool selected;
  final VoidCallback? onTap;

  const GiftCardItem({
    Key? key,
    required this.name,
    required this.price,
    required this.brand,
    this.thumbnailUrl,
    this.selected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withValues(alpha: 0.08) : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  thumbnailUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.card_giftcard, size: 48),
                ),
              )
            else
              const Icon(Icons.card_giftcard, size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$brand', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Text('${price.toString()}원', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle, color: theme.colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }
} 