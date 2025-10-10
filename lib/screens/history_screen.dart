import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme.dart';
import '../providers/history_provider.dart';
import '../providers/home_provider.dart' show TransactionItem, TxType;
import '../widgets/floating_navbar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryProvider(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HistoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.greySurface,
      body: Stack(
        children: [
          // ===== HEADER =====
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'Riwayat',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Tombol filter (sheet)
                  InkWell(
                    onTap: () => _openFilterSheet(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.tune_rounded, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== BODY =====
          Padding(
            padding: const EdgeInsets.only(top: 64),
            child: Column(
              children: [
                // Segmented tabs (Hari ini / Minggu ini / Bulan ini)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _Segmented(
                    index: switch (hp.range) {
                      HistoryRange.today => 0,
                      HistoryRange.week => 1,
                      HistoryRange.month => 2,
                    },
                    labels: const ['Hari ini', 'Minggu ini', 'Bulan ini'],
                    onChanged: (i) => hp.setRange(
                      [HistoryRange.today, HistoryRange.week, HistoryRange.month][i],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // List transaksi
                Expanded(
                  child: hp.view.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada transaksi',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                          itemCount: hp.view.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _TxCard(item: hp.view[i]),
                        ),
                ),
              ],
            ),
          ),

          // ===== NAVBAR =====
          const AppFloatingNavBar(currentIndex: 1),
        ],
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    final hp = context.read<HistoryProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).padding.bottom + 12,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: StatefulBuilder(
          builder: (ctx, setState) {
            // state lokal untuk preview sebelum Apply
            final selected = <String>{}; // tidak dipakai persist; demo simple
            bool newest = hp.sortNewestFirst;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Filter kategori',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: hp.categories.map((c) {
                    final sel = selected.contains(c);
                    return FilterChip(
                      label: Text(c),
                      selected: sel,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            selected.add(c);
                          } else {
                            selected.remove(c);
                          }
                        });
                      },
                      selectedColor: AppColors.yellow.withOpacity(.25),
                      checkmarkColor: Colors.black,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Urutkan',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Terbaru'),
                      selected: newest,
                      onSelected: (_) => setState(() => newest = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Terlama'),
                      selected: !newest,
                      onSelected: (_) => setState(() => newest = false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          hp.clearCategory();
                          hp.setSort(true);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Terapkan
                          for (final c in hp.categories) {
                            // buang dahulu
                            // (implementasi praktis; kalau mau persist, pindah state ke provider)
                          }
                          // Untuk demo simpel: set sorting saja
                          hp.setSort(newest);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Terapkan'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Segmented control (sama gaya dengan Home)
class _Segmented extends StatelessWidget {
  final int index;
  final List<String> labels;
  final void Function(int) onChanged;

  const _Segmented({
    required this.index,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.greySurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.purple : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Kartu transaksi (matching dengan gaya yang sudah kamu pakai)
class _TxCard extends StatelessWidget {
  final TransactionItem item;
  const _TxCard({required this.item});

  String _dateFmt(DateTime d) {
    const mons = [
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember'
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm • ${d.day} ${mons[d.month-1]} ${d.year}';
  }

  String _rp(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final rev = s.length - i;
      buf.write(s[i]);
      if (rev > 1 && rev % 3 == 1) buf.write('.');
    }
    return 'Rp. $buf';
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == TxType.income;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isIncome
                  ? AppColors.green.withOpacity(.12)
                  : AppColors.red.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: isIncome ? AppColors.green : AppColors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${item.category}\n${_dateFmt(item.time)}',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          Text(_rp(item.amount),
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
