import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/transaction_type.dart';
import '../../providers/expense_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/icon_helper.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  TransactionType? _typeFilter;
  String? _categoryFilter;
  DateTime? _monthFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final initial = _monthFilter ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      helpText: 'Select any day in the month',
    );
    if (picked != null) {
      setState(() => _monthFilter = DateTime(picked.year, picked.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final items = provider.filteredTransactions(
      query: _searchController.text,
      type: _typeFilter,
      categoryId: _categoryFilter,
      month: _monthFilter,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _typeFilter == null,
                  onSelected: (_) => setState(() => _typeFilter = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Income'),
                  selected: _typeFilter == TransactionType.income,
                  onSelected: (_) => setState(
                    () => _typeFilter = TransactionType.income,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Expense'),
                  selected: _typeFilter == TransactionType.expense,
                  onSelected: (_) => setState(
                    () => _typeFilter = TransactionType.expense,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(
                    _monthFilter == null
                        ? 'Month'
                        : Formatters.monthYear(_monthFilter!),
                  ),
                  selected: _monthFilter != null,
                  onSelected: (_) async {
                    if (_monthFilter != null) {
                      setState(() => _monthFilter = null);
                    } else {
                      await _pickMonth();
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(
                    _categoryFilter == null
                        ? 'Category'
                        : provider.categoryById(_categoryFilter!)?.name ??
                            'Category',
                  ),
                  selected: _categoryFilter != null,
                  onSelected: (_) async {
                    if (_categoryFilter != null) {
                      setState(() => _categoryFilter = null);
                      return;
                    }
                    final selected = await showModalBottomSheet<String>(
                      context: context,
                      showDragHandle: true,
                      builder: (ctx) {
                        return SafeArea(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              const ListTile(
                                title: Text(
                                  'Filter by category',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              ...provider.categories.map(
                                (c) => ListTile(
                                  leading: Icon(
                                    materialIcon(c.iconCodePoint),
                                    color: Color(c.colorValue),
                                  ),
                                  title: Text(c.name),
                                  subtitle: Text(c.type.label),
                                  onTap: () => Navigator.pop(ctx, c.id),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                    if (selected != null) {
                      setState(() => _categoryFilter = selected);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No matching transactions',
                    message: 'Try adjusting your search or filters.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final tx = items[index];
                      return TransactionTile(
                        transaction: tx,
                        category: provider.categoryById(tx.categoryId),
                        currency: provider.currency,
                        onDelete: () => provider.deleteTransaction(tx.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
