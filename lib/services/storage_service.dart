import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/default_categories.dart';
import '../models/app_settings.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  List<TransactionModel> loadTransactions() {
    final raw = _prefs.getString(AppConstants.transactionsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveTransactions(List<TransactionModel> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(AppConstants.transactionsKey, encoded);
  }

  List<CategoryModel> loadCategories() {
    final raw = _prefs.getString(AppConstants.categoriesKey);
    if (raw == null || raw.isEmpty) {
      final defaults = defaultCategories();
      saveCategories(defaults);
      return defaults;
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCategories(List<CategoryModel> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(AppConstants.categoriesKey, encoded);
  }

  AppSettings loadSettings() {
    final raw = _prefs.getString(AppConstants.settingsKey);
    if (raw == null || raw.isEmpty) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(
      AppConstants.settingsKey,
      jsonEncode(settings.toJson()),
    );
  }

  Future<void> clearAllData() async {
    await _prefs.remove(AppConstants.transactionsKey);
    await _prefs.remove(AppConstants.categoriesKey);
    await _prefs.remove(AppConstants.settingsKey);
  }
}
