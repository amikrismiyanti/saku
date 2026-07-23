import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/empty_state.dart';

enum _ReportPeriod { harian, mingguan, bulanan, tahunan }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  _ReportPeriod _period = _ReportPeriod.bulanan;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tx = context.read<TransactionProvider>();
      if (tx.transactions.isEmpty) tx.loadTransactions();
    });
  }

  /// Menghasilkan daftar (label, start, end) bucket waktu sesuai periode terpilih.
  List<(String, DateTime, DateTime)> _buckets() {
    final now = DateTime.now();
    final result = <(String, DateTime, DateTime)>[];

    switch (_period) {
      case _ReportPeriod.harian:
        for (int i = 6; i >= 0; i--) {
          final day = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: i));
          result.add((_dayLabel(day), day, day.add(const Duration(days: 1))));
        }
        break;
      case _ReportPeriod.mingguan:
        for (int i = 5; i >= 0; i--) {
          final end = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: 7 * i));
          final start = end.subtract(const Duration(days: 7));
          result.add(('M${6 - i}', start, end));
        }
        break;
      case _ReportPeriod.bulanan:
        for (int i = 5; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i, 1);
          final nextMonth = DateTime(month.year, month.month + 1, 1);
          result.add((_monthLabel(month), month, nextMonth));
        }
        break;
      case _ReportPeriod.tahunan:
        for (int i = 4; i >= 0; i--) {
          final year = now.year - i;
          result.add(('$year', DateTime(year, 1, 1), DateTime(year + 1, 1, 1)));
        }
        break;
    }
    return result;
  }

  String _dayLabel(DateTime d) =>
      const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][d.weekday - 1];
  String _monthLabel(DateTime d) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ][d.month - 1];

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final buckets = _buckets();

    final incomeBars = <double>[];
    final expenseBars = <double>[];
    for (final b in buckets) {
      final totals = txProvider.totalsForRange(b.$2, b.$3);
      incomeBars.add(totals.income);
      expenseBars.add(totals.expense);
    }

    final rangeStart = buckets.first.$2;
    final rangeEnd = buckets.last.$3;
    final categoryTotals =
        txProvider.expenseByCategoryForRange(rangeStart, rangeEnd);
    final totalExpenseInRange =
        categoryTotals.values.fold(0.0, (a, b) => a + b);
    final totalIncomeInRange = incomeBars.fold(0.0, (a, b) => a + b);

    final maxY =
        [...incomeBars, ...expenseBars].fold(0.0, (a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<_ReportPeriod>(
            segments: const [
              ButtonSegment(value: _ReportPeriod.harian, label: Text('Harian')),
              ButtonSegment(
                  value: _ReportPeriod.mingguan, label: Text('Mingguan')),
              ButtonSegment(
                  value: _ReportPeriod.bulanan, label: Text('Bulanan')),
              ButtonSegment(
                  value: _ReportPeriod.tahunan, label: Text('Tahunan')),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'Total Pemasukan',
                  value: totalIncomeInRange,
                  color: AppColors.income,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  label: 'Total Pengeluaran',
                  value: totalExpenseInRange,
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Pemasukan vs Pengeluaran',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: maxY == 0
                ? const Center(
                    child: Text('Belum ada data',
                        style: TextStyle(color: AppColors.textSecondary)))
                : BarChart(
                    BarChartData(
                      maxY: maxY * 1.2,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= buckets.length)
                                return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(buckets[i].$1,
                                    style: const TextStyle(fontSize: 10)),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(buckets.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                                toY: incomeBars[i],
                                color: AppColors.income,
                                width: 8,
                                borderRadius: BorderRadius.circular(3)),
                            BarChartRodData(
                                toY: expenseBars[i],
                                color: AppColors.expense,
                                width: 8,
                                borderRadius: BorderRadius.circular(3)),
                          ],
                          barsSpace: 4,
                        );
                      }),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          const _LegendRow(),
          const SizedBox(height: 28),
          const Text('Pengeluaran Berdasarkan Kategori',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          if (categoryTotals.isEmpty)
            const EmptyState(message: 'Belum ada pengeluaran di periode ini')
          else
            _CategoryPieSection(
                categoryTotals: categoryTotals, total: totalExpenseInRange),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _SummaryTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            Text(CurrencyFormatter.format(value),
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    Widget dot(Color c) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dot(AppColors.income),
        const SizedBox(width: 6),
        const Text('Pemasukan', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 20),
        dot(AppColors.expense),
        const SizedBox(width: 6),
        const Text('Pengeluaran', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _CategoryPieSection extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final double total;
  const _CategoryPieSection(
      {required this.categoryTotals, required this.total});

  @override
  Widget build(BuildContext context) {
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: List.generate(entries.length, (i) {
                final color =
                    AppColors.chartPalette[i % AppColors.chartPalette.length];
                final pct = total == 0 ? 0 : entries[i].value / total * 100;
                return PieChartSectionData(
                  value: entries[i].value,
                  color: color,
                  title: '${pct.toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(entries.length, (i) {
          final color =
              AppColors.chartPalette[i % AppColors.chartPalette.length];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(entries[i].key)),
                Text(CurrencyFormatter.format(entries[i].value),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
