import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_app/app.dart';
import 'package:expense_app/providers/expense_provider.dart';
import 'package:expense_app/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Expense Track loads dashboard', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final provider = ExpenseProvider(storage);
    await provider.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const ExpenseTrackApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Expense Track'), findsWidgets);
    expect(find.text('Current Balance'), findsOneWidget);
  });
}
