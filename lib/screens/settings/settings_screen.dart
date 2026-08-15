import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/expense_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final settings = provider.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Dark mode'),
              subtitle: const Text('Switch between light and dark theme'),
              value: settings.isDarkMode,
              onChanged: provider.setDarkMode,
              secondary: Icon(
                settings.isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.attach_money_rounded),
              title: const Text('Currency'),
              subtitle: Text(settings.currency),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickCurrency(context, provider),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_view_week_rounded),
              title: const Text('First day of week'),
              subtitle: Text(_weekdayLabel(settings.firstDayOfWeek)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickFirstDay(context, provider),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.delete_forever_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Clear all data',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              subtitle: const Text('Remove all transactions and reset settings'),
              onTap: () => _clearData(context, provider),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: const Text('App version'),
              subtitle: Text(AppConstants.appVersion),
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(int day) {
    const labels = {
      DateTime.monday: 'Monday',
      DateTime.tuesday: 'Tuesday',
      DateTime.wednesday: 'Wednesday',
      DateTime.thursday: 'Thursday',
      DateTime.friday: 'Friday',
      DateTime.saturday: 'Saturday',
      DateTime.sunday: 'Sunday',
    };
    return labels[day] ?? 'Monday';
  }

  Future<void> _pickCurrency(
    BuildContext context,
    ExpenseProvider provider,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              title: Text(
                'Select currency',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ...AppConstants.supportedCurrencies.map(
              (code) => ListTile(
                title: Text(
                  '$code (${AppConstants.currencySymbols[code]})',
                ),
                trailing: provider.currency == code
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(ctx, code),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await provider.setCurrency(selected);
    }
  }

  Future<void> _pickFirstDay(
    BuildContext context,
    ExpenseProvider provider,
  ) async {
    final days = [
      DateTime.monday,
      DateTime.sunday,
      DateTime.saturday,
    ];
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'First day of week',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ...days.map(
              (d) => ListTile(
                title: Text(_weekdayLabel(d)),
                trailing: provider.settings.firstDayOfWeek == d
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(ctx, d),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await provider.setFirstDayOfWeek(selected);
    }
  }

  Future<void> _clearData(
    BuildContext context,
    ExpenseProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This will permanently delete all transactions, custom categories, and reset settings. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear everything'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.clearAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared')),
        );
      }
    }
  }
}
