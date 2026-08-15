import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/expense_provider.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.create();
  final provider = ExpenseProvider(storage);
  await provider.load();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const ExpenseTrackApp(),
    ),
  );
}
