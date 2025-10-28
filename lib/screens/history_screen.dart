import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme.dart';
import '../providers/home_provider.dart'
    show HomeProvider, TransactionItem, TxType;
import '../providers/auth_provider.dart';
import '../widgets/floating_navbar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Use HomeProvider so History reads transactions from the same
      // backend source as the Home draggable sheet.
      create: (_) => HomeProvider(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final token = Provider.of<AuthProvider>(context, listen: false).token;
        if (token != null) {
          Provider.of<HomeProvider>(
            context,
            listen: false,
          ).fetchTransactions(token: token);
        } else {
          Provider.of<HomeProvider>(context, listen: false).fetchTransactions();
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HomeProvider>();

    return Scaffold(
      backgroundColor: AppColors.greySurface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  // keep a simple filter/action icon placeholder
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list_rounded),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _Segmented(
                index: hp.segment,
                labels: const ['Hari ini', 'Minggu ini', 'Bulan ini'],
                onChanged: (i) => hp.setSegment(i),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: hp.filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada transaksi',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                      itemCount: hp.filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _TxCard(item: hp.filtered[i]),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppFloatingNavBar(currentIndex: 1),
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
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm • ${d.day} ${mons[d.month - 1]} ${d.year}';
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
            width: 40,
            height: 40,
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
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.category}\n${_dateFmt(item.time)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            _rp(item.amount),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
