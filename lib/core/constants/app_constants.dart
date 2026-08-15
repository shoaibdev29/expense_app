class AppConstants {
  static const String appName = 'Expense Track';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.waleed.expense';

  static const String transactionsKey = 'transactions';
  static const String categoriesKey = 'categories';
  static const String settingsKey = 'settings';
  static const String themeKey = 'theme_mode';
  static const String currencyKey = 'currency';
  static const String firstDayKey = 'first_day_of_week';

  static const String defaultCurrency = 'PKR';

  static const List<String> supportedCurrencies = [
    'PKR',
    'USD',
    'AED',
    'GBP',
    'EUR',
    'SAR',
  ];

  static const Map<String, String> currencySymbols = {
    'PKR': 'Rs',
    'USD': '\$',
    'AED': 'AED',
    'GBP': '£',
    'EUR': '€',
    'SAR': 'SAR',
  };
}
