import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme.dart';
import '../providers/statistics_provider.dart';
import '../widgets/paged_bar_chart.dart';


class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatisticsProvider(),
      child: const _StatisticsView(),
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StatisticsProvider>();

    return Scaffold(
      backgroundColor: AppColors.greySurface,
      appBar: AppBar(
        backgroundColor: AppColors.greySurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Statistik', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        child: Column(
          children: [
            // summary cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Total\nPemasukan',
                    value: p.formatJt(p.totalIncome),
                    valueColor: AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Total\nPengeluaran',
                    value: p.formatJt(p.totalExpense),
                    valueColor: AppColors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // chart card
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.03),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(),
                    const SizedBox(height: 10),
                    // legend
                    Row(
                      children: const [
                        _LegendDot(color: AppColors.green, label: 'Pemasukan'),
                        SizedBox(width: 16),
                        _LegendDot(color: AppColors.red, label: 'Pengeluaran'),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // chart
                    Expanded(
  child: PagedBarChart(
    months: p.months,
    incomes: p.incomes,
    expenses: p.expenses,
  ),
),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodySmall!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.1)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: .2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vertikal Bar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        SizedBox(height: 2),
        Text('Statistik keuanganmu perbulan', style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }
}
