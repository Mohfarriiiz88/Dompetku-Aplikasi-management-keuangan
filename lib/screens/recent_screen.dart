import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme.dart';
import '../providers/recent_provider.dart';
import '../widgets/transaction_card.dart';

class RecentScreen extends StatelessWidget {
  const RecentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecentProvider(),
      child: const _RecentView(),
    );
  }
}

class _RecentView extends StatelessWidget {
  const _RecentView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecentProvider>();

    return DefaultTabController(
      length: 3,
      initialIndex: Period.values.indexOf(p.period),
      child: Scaffold(
        body: Stack(
          children: [
            // Header gradasi ungu
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.brand,
                  image: DecorationImage(
                    image: AssetImage('assets/images/bgcircle.png'),
                    fit: BoxFit.cover,
                    opacity: .25,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Text('Terbaru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 12),

                  // Sheet putih
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.greySurface,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            width: 60,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // TabBar segment
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.greySurface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: TabBar(
                                onTap: (i) => p.setPeriod(i),
                                indicator: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                labelColor: AppColors.purple,
                                unselectedLabelColor: Colors.black87,
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.w700),
                                tabs: const [
                                  Tab(text: 'Hari ini'),
                                  Tab(text: 'Minggu ini'),
                                  Tab(text: 'Bulan ini'),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Tab content
                          Expanded(
                            child: TabBarView(
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _ListTab(getItems: () => context.read<RecentProvider>().items),
                                _ListTab(getItems: () => context.read<RecentProvider>().items),
                                _ListTab(getItems: () => context.read<RecentProvider>().items),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListTab extends StatelessWidget {
  const _ListTab({required this.getItems});
  final List Function() getItems;

  @override
  Widget build(BuildContext context) {
    // rebuild saat provider berubah
    final items = context.watch<RecentProvider>().items;

    if (items.isEmpty) {
      return const Center(
        child: Text('Aktivitas tidak ditemukan',
            style: TextStyle(fontWeight: FontWeight.w700)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemBuilder: (_, i) => TransactionCard(item: items[i]),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: items.length,
    );
  }
}
