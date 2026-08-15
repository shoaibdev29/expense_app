import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/transaction_type.dart';
import '../utils/formatters.dart';
import '../utils/icon_helper.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
    required this.currency,
    this.onTap,
    this.onDelete,
  });

  final TransactionModel transaction;
  final CategoryModel? category;
  final String currency;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isIncome = transaction.type == TransactionType.income;
    final color = category != null
        ? Color(category!.colorValue)
        : scheme.outline;
    final amountColor = isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: onDelete == null
          ? DismissDirection.none
          : DismissDirection.endToStart,
      confirmDismiss: (_) async {
        if (onDelete == null) return false;
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete transaction?'),
                content: const Text(
                  'This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: scheme.onError),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(
              materialIcon(
                category?.iconCodePoint ?? Icons.help_outline.codePoint,
              ),
              color: color,
              size: 22,
            ),
          ),
          title: Text(
            category?.name ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            [
              Formatters.shortDate(transaction.date),
              if (transaction.note != null && transaction.note!.isNotEmpty)
                transaction.note!,
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'} ${Formatters.currency(transaction.amount, currency)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ),
      ),
    );
  }
}
