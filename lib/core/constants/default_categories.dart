import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../models/transaction_type.dart';

List<CategoryModel> defaultCategories() {
  return [
    // Expense
    CategoryModel(
      id: 'exp_food',
      name: 'Food',
      type: TransactionType.expense,
      iconCodePoint: Icons.restaurant_rounded.codePoint,
      colorValue: const Color(0xFFEF4444).toARGB32(),
      isDefault: true,
    ),
    CategoryModel(
      id: 'exp_transport',
      name: 'Transport',
      type: TransactionType.expense,
      iconCodePoint: Icons.directions_car_rounded.codePoint,
      colorValue: const Color(0xFF3B82F6).toARGB32(),
      isDefault: true,
    ),
    CategoryModel(
      id: 'exp_shopping',
      name: 'Shopping',
      type: TransactionType.expense,
      iconCodePoint: Icons.shopping_bag_rounded.codePoint,
      colorValue: const Color(0xFF8B5CF6).toARGB32(),
      isDefault: true,
    ),
    CategoryModel(
      id: 'exp_bills',
      name: 'Bills',
      type: TransactionType.expense,
      iconCodePoint: Icons.receipt_long_rounded.codePoint,
      colorValue: const Color(0xFFF59E0B).toARGB32(),
      isDefault: true,
    ),
    CategoryModel(
      id: 'exp_health',
      name: 'Health',
      type: TransactionType.expense,
      iconCodePoint: Icons.favorite_rounded.codePoint,
      colorValue: const Color(0xFFEC4899).toARGB32(),
      isDefault: true,
    ),
    CategoryModel(
      id: 'exp_entertainment',
      name: 'Entertainment',
      type: TransactionType.expense,
      iconCodePoint: Icons.movie_rounded.codePoint,
      colorValue: const Color(0xFF14B8A6).toARGB32(),
      isDefault: true,
    ),
    CategoryModel(
      id: 'exp_education',
      name: 'Education',
      type: TransactionType.expense,
      iconCodePoint: Icons.school_rounded.codePoint,
      colorValue: const Color(0xFF6366F1).toARGB32(),
      isDefault: true,
    ),
    CategoryModel(
      id: 'exp_other',
      name: 'Other',
      type: TransactionType.expense,
      iconCodePoint: Icons.more_horiz_rounded.codePoint,
      colorValue: const Color(0xFF64748B).toARGB32(),
      isDefault: true,
    ),
    // Income
    CategoryModel(
      id: 'inc_salary',
      name: 'Salary',
      type: TransactionType.income,
      iconCodePoint: Icons.payments_rounded.codePoint,
      colorValue: const Color(0xFF22C55E).toARGB32(),
      isDefault: true,
    ),
    CategoryModel(
      id: 'inc_freelance',
      name: 'Freelance',
      type: TransactionType.income,
      iconCodePoint: Icons.laptop_mac_rounded.codePoint,
      colorValue: const Color(0xFF06B6D4).toARGB32(),
      isDefault: true,
    ),
    CategoryModel(
      id: 'inc_business',
      name: 'Business',
      type: TransactionType.income,
      iconCodePoint: Icons.storefront_rounded.codePoint,
      colorValue: const Color(0xFF0EA5E9).toARGB32(),
      isDefault: true,
    ),
    CategoryModel(
      id: 'inc_gift',
      name: 'Gift',
      type: TransactionType.income,
      iconCodePoint: Icons.card_giftcard_rounded.codePoint,
      colorValue: const Color(0xFFF97316).toARGB32(),
      isDefault: true,
    ),
    CategoryModel(
      id: 'inc_other',
      name: 'Other',
      type: TransactionType.income,
      iconCodePoint: Icons.more_horiz_rounded.codePoint,
      colorValue: const Color(0xFF64748B).toARGB32(),
      isDefault: true,
    ),
  ];
}
