import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/statistics_screen.dart';
import '../screens/friend_list_screen.dart';
import '../screens/transaction_form_screen.dart';
import '../core/theme/theme.dart';
import '../providers/home_provider.dart';
import '../widgets/floating_navbar.dart';
import '../widgets/white_blur_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // precache agar mulus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/images/bgcircle.png'), context);
    });

    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HomeProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // ===== BACKGROUND: gradient + ripple =====
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

          // ===== HEADER AREA (tetap) =====
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HeaderPill(name: 'Moh Fariz'),
                  const SizedBox(height: 16),
                  _WalletCard(balance: hp.balance),
                  const SizedBox(height: 16),
                  const _QuickActions(),
                  const SizedBox(height: 8), // beri jarak tipis dari sheet
                ],
              ),
            ),
          ),

          // ===== DRAGGABLE "TERBARU" (SHEET) =====
          _DraggableFeedSheet(hp: hp),

          // ===== Floating bottom navbar reusable =====
          const AppFloatingNavBar(currentIndex: 0),
        ],
      ),
    );
  }
}

/// ================= DRAGGABLE FEED SHEET =================
class _DraggableFeedSheet extends StatelessWidget {
  final HomeProvider hp;
  const _DraggableFeedSheet({required this.hp});

  @override
  Widget build(BuildContext context) {
    // tinggi nav bar custom agar list tidak ketutup
    const double navBarReserve = 96;

    return DraggableScrollableSheet(
      initialChildSize: 0.58, // start posisi (≈ 58% tinggi layar)//
      minChildSize: 0.45,     // bisa diturunkan sampai sini
      maxChildSize: 0.95,     // bisa ditarik hampir penuh
      snap: true,
      snapSizes: const [0.58, 0.95],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.greySurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController, // << penting agar drag/scroll nyambung
            padding: const EdgeInsets.fromLTRB(16, 8, 16, navBarReserve),
            children: [
              // handle
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 60,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // judul
              const Text(
                'Terbaru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              // segmented tabs
              _Segmented(
                index: hp.segment,
                onChanged: hp.setSegment,
                labels: const ['Hari ini', 'Minggu ini', 'Bulan ini'],
              ),
              const SizedBox(height: 12),

              // list content
              if (hp.filtered.isEmpty) ...[
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Aktivitas tidak ditemukan',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ] else ...[
                // rakit list dengan separator manual
                for (int i = 0; i < hp.filtered.length; i++) ...[
                  _TxTile(item: hp.filtered[i]),
                  if (i != hp.filtered.length - 1) const SizedBox(height: 12),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

/// ================= HEADER & WALLET =================
class _HeaderPill extends StatelessWidget {
  final String name;
  const _HeaderPill({required this.name});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.yellow,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: const [
          SizedBox(
            width: 20,
            height: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
          SizedBox(width: 8),
          Text('Moh Fariz',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final int balance;
  const _WalletCard({required this.balance});

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
    return WhiteBlurCard(
      height: 120,
      width: double.infinity,
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Isi Dompetmu',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Colors.white.withOpacity(.6),
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _rp(balance <= 0 ? 1000000 : balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// ================= QUICK ACTIONS =================
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    // builder untuk satu tombol (ikon bulat + label di bawah)
    Widget action({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkResponse(
            onTap: onTap,
            radius: 40,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.purple, size: 28),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.1,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Catat Keuangan -> buka form
        action(
          icon: Icons.request_quote_rounded,
          label: 'Catat\nKeuangan',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
            );
          },
        ),

        // Cetak (dummy)
        action(
          icon: Icons.print_rounded,
          label: 'Cetak',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur Cetak (coming soon)')),
            );
          },
        ),

        // Statistik (dummy)
        action(
          icon: Icons.bar_chart_rounded,
          label: 'Statistik',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StatisticsScreen()),
            );
          },
        ),

        // Teman -> FriendListView
        action(
          icon: Icons.group_rounded,
          label: 'Teman',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FriendListScreen()),
            );
          },
        ),
      ],
    );
  }
}

/// ================= SEGMENTED + TILE (tanpa perubahan) =================
class _Segmented extends StatelessWidget {
  final int index;
  final void Function(int) onChanged;
  final List<String> labels;

  const _Segmented(
      {required this.index, required this.onChanged, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: AppColors.greySurface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: Colors.black.withOpacity(.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
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

class _TxTile extends StatelessWidget {
  final TransactionItem item;
  const _TxTile({required this.item});

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
              offset: const Offset(0, 6))
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
              isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: isIncome ? AppColors.green : AppColors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style:
                        const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${item.category}\n${_dateFmt(item.time)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
  