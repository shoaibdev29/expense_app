class AppSettings {
  final String currency;
  final int firstDayOfWeek; // DateTime.monday = 1 ... DateTime.sunday = 7
  final bool isDarkMode;

  const AppSettings({
    this.currency = 'PKR',
    this.firstDayOfWeek = DateTime.monday,
    this.isDarkMode = false,
  });

  AppSettings copyWith({
    String? currency,
    int? firstDayOfWeek,
    bool? isDarkMode,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'firstDayOfWeek': firstDayOfWeek,
        'isDarkMode': isDarkMode,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      currency: json['currency'] as String? ?? 'PKR',
      firstDayOfWeek: json['firstDayOfWeek'] as int? ?? DateTime.monday,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
    );
  }
}
