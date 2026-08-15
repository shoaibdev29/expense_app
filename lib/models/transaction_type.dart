enum TransactionType {
  income,
  expense;

  String get label => this == TransactionType.income ? 'Income' : 'Expense';

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}
