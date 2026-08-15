import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../utils/icon_helper.dart';

class CategoryChipSelector extends StatelessWidget {
  const CategoryChipSelector({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Text('No categories available.');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((c) {
        final selected = c.id == selectedId;
        final color = Color(c.colorValue);
        return ChoiceChip(
          selected: selected,
          onSelected: (_) => onSelected(c.id),
          avatar: Icon(
            materialIcon(c.iconCodePoint),
            size: 18,
            color: selected ? color : color.withValues(alpha: 0.8),
          ),
          label: Text(c.name),
          selectedColor: color.withValues(alpha: 0.18),
          side: BorderSide(
            color: selected ? color : Theme.of(context).colorScheme.outlineVariant,
          ),
        );
      }).toList(),
    );
  }
}
