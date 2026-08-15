import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category_model.dart';
import '../../models/transaction_type.dart';
import '../../providers/expense_provider.dart';
import '../../utils/icon_helper.dart';
import '../../widgets/empty_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final expenseCats = provider.categoriesFor(TransactionType.expense);
    final incomeCats = provider.categoriesFor(TransactionType.income);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            tooltip: 'Add category',
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _SectionHeader(title: 'Expense', count: expenseCats.length),
          if (expenseCats.isEmpty)
            const EmptyState(
              icon: Icons.category_outlined,
              title: 'No expense categories',
              message: 'Add a custom expense category.',
            )
          else
            ...expenseCats.map(
              (c) => _CategoryTile(
                category: c,
                usageCount: provider.transactionCountForCategory(c.id),
                onEdit: () => _openEditor(context, category: c),
                onDelete: () => _delete(context, c),
              ),
            ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Income', count: incomeCats.length),
          if (incomeCats.isEmpty)
            const EmptyState(
              icon: Icons.category_outlined,
              title: 'No income categories',
              message: 'Add a custom income category.',
            )
          else
            ...incomeCats.map(
              (c) => _CategoryTile(
                category: c,
                usageCount: provider.transactionCountForCategory(c.id),
                onEdit: () => _openEditor(context, category: c),
                onDelete: () => _delete(context, c),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  Future<void> _delete(BuildContext context, CategoryModel category) async {
    final provider = context.read<ExpenseProvider>();
    if (category.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default categories cannot be deleted')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('Delete "${category.name}"?'),
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
    );
    if (confirmed != true || !context.mounted) return;

    final error = await provider.deleteCategory(category.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Category deleted')),
    );
  }

  Future<void> _openEditor(
    BuildContext context, {
    CategoryModel? category,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _CategoryEditorSheet(category: category),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.usageCount,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryModel category;
  final int usageCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            materialIcon(category.iconCodePoint),
            color: color,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          category.isDefault
              ? 'Default · $usageCount transaction(s)'
              : 'Custom · $usageCount transaction(s)',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            if (!category.isDefault)
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

class _CategoryEditorSheet extends StatefulWidget {
  const _CategoryEditorSheet({this.category});

  final CategoryModel? category;

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  static const _icons = [
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.shopping_bag_rounded,
    Icons.receipt_long_rounded,
    Icons.favorite_rounded,
    Icons.movie_rounded,
    Icons.school_rounded,
    Icons.payments_rounded,
    Icons.laptop_mac_rounded,
    Icons.storefront_rounded,
    Icons.card_giftcard_rounded,
    Icons.home_rounded,
    Icons.flight_rounded,
    Icons.pets_rounded,
    Icons.sports_esports_rounded,
    Icons.more_horiz_rounded,
  ];

  static const _colors = [
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF22C55E),
    Color(0xFF14B8A6),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF64748B),
  ];

  late final TextEditingController _nameController;
  late TransactionType _type;
  late int _iconCodePoint;
  late int _colorValue;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameController = TextEditingController(text: c?.name ?? '');
    _type = c?.type ?? TransactionType.expense;
    _iconCodePoint = c?.iconCodePoint ?? _icons.first.codePoint;
    _colorValue = c?.colorValue ?? _colors.first.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name is required')),
      );
      return;
    }

    final provider = context.read<ExpenseProvider>();
    if (widget.category == null) {
      await provider.addCategory(
        name: name,
        type: _type,
        iconCodePoint: _iconCodePoint,
        colorValue: _colorValue,
      );
    } else {
      await provider.updateCategory(
        widget.category!.copyWith(
          name: name,
          type: widget.category!.isDefault ? widget.category!.type : _type,
          iconCodePoint: _iconCodePoint,
          colorValue: _colorValue,
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.category != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            editing ? 'Edit category' : 'Add category',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          if (!editing || !(widget.category?.isDefault ?? false))
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
          const SizedBox(height: 16),
          Text(
            'Icon',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _icons.map((icon) {
              final selected = icon.codePoint == _iconCodePoint;
              return ChoiceChip(
                selected: selected,
                label: Icon(icon, size: 18),
                onSelected: (_) =>
                    setState(() => _iconCodePoint = icon.codePoint),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Color',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _colors.map((color) {
              final selected = color.toARGB32() == _colorValue;
              return GestureDetector(
                onTap: () => setState(() => _colorValue = color.toARGB32()),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(editing ? 'Save changes' : 'Add category'),
          ),
        ],
      ),
    );
  }
}
