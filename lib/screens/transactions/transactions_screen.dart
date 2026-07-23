import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_categories.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  TransactionType? _typeFilter; // null = semua
  String? _categoryFilter; // null = semua
  DateTimeRange? _dateFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _applyFilters(List<TransactionModel> all) {
    return all.where((t) {
      if (_typeFilter != null && t.type != _typeFilter) return false;
      if (_categoryFilter != null && t.category != _categoryFilter) return false;
      if (_dateFilter != null) {
        final start = _dateFilter!.start;
        final end = _dateFilter!.end.add(const Duration(days: 1));
        if (t.date.isBefore(start) || !t.date.isBefore(end)) return false;
      }
      if (_search.trim().isNotEmpty) {
        final q = _search.toLowerCase();
        final matchCategory = t.category.toLowerCase().contains(q);
        final matchDesc = (t.description ?? '').toLowerCase().contains(q);
        if (!matchCategory && !matchDesc) return false;
      }
      return true;
    }).toList();
  }

  Map<String, List<TransactionModel>> _groupByDate(List<TransactionModel> list) {
    final sorted = [...list]..sort((a, b) => b.date.compareTo(a.date));
    final map = <String, List<TransactionModel>>{};
    for (final t in sorted) {
      final key = DateFormatter.full(t.date);
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  Future<void> _showFilterSheet() async {
    final allCategories = [...AppCategories.income, ...AppCategories.expense];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filter Transaksi', style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  const Text('Jenis Transaksi', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Semua'),
                        selected: _typeFilter == null,
                        onSelected: (_) => setSheetState(() => _typeFilter = null),
                      ),
                      ChoiceChip(
                        label: const Text('Pemasukan'),
                        selected: _typeFilter == TransactionType.income,
                        onSelected: (_) => setSheetState(() => _typeFilter = TransactionType.income),
                      ),
                      ChoiceChip(
                        label: const Text('Pengeluaran'),
                        selected: _typeFilter == TransactionType.expense,
                        onSelected: (_) => setSheetState(() => _typeFilter = TransactionType.expense),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Semua'),
                        selected: _categoryFilter == null,
                        onSelected: (_) => setSheetState(() => _categoryFilter = null),
                      ),
                      ...allCategories.map(
                        (c) => ChoiceChip(
                          label: Text(c),
                          selected: _categoryFilter == c,
                          onSelected: (_) => setSheetState(() => _categoryFilter = c),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Rentang Tanggal', style: TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final range = await showDateRangePicker(
                            context: ctx,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (range != null) setSheetState(() => _dateFilter = range);
                        },
                        child: Text(_dateFilter == null
                            ? 'Pilih tanggal'
                            : '${DateFormatter.short(_dateFilter!.start)} - ${DateFormatter.short(_dateFilter!.end)}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() {
                              _typeFilter = null;
                              _categoryFilter = null;
                              _dateFilter = null;
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {}); // terapkan filter ke screen utama
                            Navigator.pop(ctx);
                          },
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final filtered = _applyFilters(txProvider.transactions);
    final grouped = _groupByDate(filtered);
    final hasActiveFilter = _typeFilter != null || _categoryFilter != null || _dateFilter != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: hasActiveFilter,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<TransactionProvider>().loadTransactions(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari kategori atau keterangan...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _search = '');
                          },
                        )
                      : null,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            Expanded(
              child: txProvider.isLoading && txProvider.transactions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const EmptyState(message: 'Tidak ada transaksi yang cocok')
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: grouped.entries.expand((entry) {
                            return [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8, top: 8),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              ...entry.value.map(
                                (t) => TransactionCard(
                                  transaction: t,
                                  onTap: () => context.push('/transactions/${t.id}', extra: t),
                                ),
                              ),
                            ];
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
