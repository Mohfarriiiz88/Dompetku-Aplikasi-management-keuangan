import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

          // ===== BODY: header + sheet full =====
          // ===== BODY: header + sheet full =====
SafeArea(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header, Wallet, Quick Actions tetap punya padding 20
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HeaderPill(name: 'Moh Fariz'),
            SizedBox(height: 16),
            // NOTE: _WalletCard butuh balance -> pindahkan const kalau perlu
          ],
        ),
      ),

      // kalau _WalletCard & _QuickActions butuh akses hp, tulis begini:
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _WalletCard(balance: hp.balance),
      ),
      const SizedBox(height: 16),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _QuickActions(),
      ),
      const SizedBox(height: 16),

      // >>> Sheet full-bleed ke kiri & kanan (tidak ada padding di sini)
      Expanded(
        child: _FeedSheet(hp: hp),
      ),
    ],
  ),
),

          // ===== Floating bottom navbar reusable =====
          const AppFloatingNavBar(currentIndex: 0),
        ],
      ),
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
              blurRadius: 10, offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          const Text('Moh Fariz', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
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
    // bisa di-tweak: blurSigma: 20, opacity: .9,
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
            color: Colors.white,            // karena kartu putih
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
    Widget item(IconData icon, String label) => Column(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Icon(icon, color: AppColors.purple),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        item(Icons.trending_up, 'Uang\nMasuk'),
        item(Icons.trending_down, 'Uang\nKeluar'),
        item(Icons.print_rounded, 'Cetak'),
        item(Icons.bar_chart, 'Statistik'),
      ],
    );
  }
}

/// ================= FEED SHEET (FULL) =================
class _FeedSheet extends StatelessWidget {
  final HomeProvider hp;
  const _FeedSheet({required this.hp});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // penting untuk full lebar
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
            width: 60, height: 6,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 14),

          // konten internal boleh punya padding sendiri
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Text('Terbaru', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _Segmented(
              index: hp.segment,
              onChanged: hp.setSegment,
              labels: const ['Hari ini', 'Minggu ini', 'Bulan ini'],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: hp.filtered.isEmpty
                ? const Center(
                    child: Text('Aktivitas tidak ditemukan',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: hp.filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _TxTile(item: hp.filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}


class _Segmented extends StatelessWidget {
  final int index;
  final void Function(int) onChanged;
  final List<String> labels;

  const _Segmented({required this.index, required this.onChanged, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.greySurface, borderRadius: BorderRadius.circular(16)),
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
                      ? [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 10, offset: const Offset(0, 4))]
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIncome ? AppColors.green.withOpacity(.12) : AppColors.red.withOpacity(.12),
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
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${item.category}\n${_dateFmt(item.time)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          Text(_rp(item.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
