import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/app_settings.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/transaction_type.dart';
import '../services/storage_service.dart';
import '../utils/date_helpers.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider(this._storage);

  final StorageService _storage;
  final _uuid = const Uuid();

  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  AppSettings _settings = const AppSettings();
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  AppSettings get settings => _settings;
  String get currency => _settings.currency;
  bool get isDarkMode => _settings.isDarkMode;

  Future<void> load() async {
    _transactions = _storage.loadTransactions();
    _categories = _storage.loadCategories();
    _settings = _storage.loadSettings();
    _loaded = true;
    notifyListeners();
  }

  // --- Calculations ---

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  double get todayExpense {
    final now = DateTime.now();
    return _sumExpenseWhere((t) => DateHelpers.isSameDay(t.date, now));
  }

  double get weekExpense {
    final now = DateTime.now();
    final start = DateHelpers.startOfWeek(now, _settings.firstDayOfWeek);
    final end = DateHelpers.endOfWeek(now, _settings.firstDayOfWeek);
    return _sumExpenseWhere(
      (t) => !t.date.isBefore(start) && !t.date.isAfter(end),
    );
  }

  double get monthExpense {
    final now = DateTime.now();
    return _sumExpenseWhere((t) => DateHelpers.isSameMonth(t.date, now));
  }

  double get monthIncome {
    final now = DateTime.now();
    return _transactions
        .where(
          (t) =>
              t.type == TransactionType.income &&
              DateHelpers.isSameMonth(t.date, now),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthBalance => monthIncome - monthExpense;

  List<TransactionModel> get recentTransactions {
    final sorted = [..._transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  Map<String, double> monthExpenseByCategory() {
    final now = DateTime.now();
    final map = <String, double>{};
    for (final t in _transactions) {
      if (t.type != TransactionType.expense) continue;
      if (!DateHelpers.isSameMonth(t.date, now)) continue;
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  double _sumExpenseWhere(bool Function(TransactionModel) test) {
    return _transactions
        .where((t) => t.type == TransactionType.expense && test(t))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // --- Categories ---

  List<CategoryModel> categoriesFor(TransactionType type) =>
      _categories.where((c) => c.type == type).toList();

  CategoryModel? categoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  int transactionCountForCategory(String categoryId) =>
      _transactions.where((t) => t.categoryId == categoryId).length;

  Future<void> addCategory({
    required String name,
    required TransactionType type,
    required int iconCodePoint,
    required int colorValue,
  }) async {
    final category = CategoryModel(
      id: _uuid.v4(),
      name: name.trim(),
      type: type,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
    );
    _categories = [..._categories, category];
    await _storage.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> updateCategory(CategoryModel category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index < 0) return;
    _categories = [..._categories]..[index] = category;
    await _storage.saveCategories(_categories);
    notifyListeners();
  }

  /// Returns an error message if deletion is blocked; otherwise null.
  Future<String?> deleteCategory(String id) async {
    final category = categoryById(id);
    if (category == null) return 'Category not found.';
    if (category.isDefault) {
      return 'Default categories cannot be deleted.';
    }
    final count = transactionCountForCategory(id);
    if (count > 0) {
      return 'Cannot delete: $count transaction(s) use this category.';
    }
    _categories = _categories.where((c) => c.id != id).toList();
    await _storage.saveCategories(_categories);
    notifyListeners();
    return null;
  }

  // --- Transactions ---

  Future<void> addTransaction({
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? note,
  }) async {
    final item = TransactionModel(
      id: _uuid.v4(),
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      createdAt: DateTime.now(),
    );
    _transactions = [item, ..._transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index < 0) return;
    _transactions = [..._transactions]..[index] = transaction;
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions = _transactions.where((t) => t.id != id).toList();
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  List<TransactionModel> filteredTransactions({
    String query = '',
    TransactionType? type,
    String? categoryId,
    DateTime? month,
  }) {
    final q = query.trim().toLowerCase();
    return _transactions.where((t) {
      if (type != null && t.type != type) return false;
      if (categoryId != null && t.categoryId != categoryId) return false;
      if (month != null && !DateHelpers.isSameMonth(t.date, month)) {
        return false;
      }
      if (q.isEmpty) return true;
      final category = categoryById(t.categoryId);
      final haystack = [
        category?.name ?? '',
        t.note ?? '',
        t.amount.toString(),
        t.type.label,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // --- Settings ---

  Future<void> setDarkMode(bool value) async {
    _settings = _settings.copyWith(isDarkMode: value);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    _settings = _settings.copyWith(currency: currency);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setFirstDayOfWeek(int day) async {
    _settings = _settings.copyWith(firstDayOfWeek: day);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _storage.clearAllData();
    _transactions = [];
    _categories = _storage.loadCategories();
    _settings = const AppSettings();
    await _storage.saveSettings(_settings);
    notifyListeners();
  }
}
