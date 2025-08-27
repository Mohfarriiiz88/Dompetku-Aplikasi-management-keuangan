import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import '../routes/app_routes.dart';

/// Navbar mengambang reusable (dipakai di banyak halaman).
/// Gunakan: AppFloatingNavBar(currentIndex: 0/1/2)
class AppFloatingNavBar extends StatelessWidget {
  final int currentIndex; // 0=Home, 1=Transaksi, 2=Settings

  const AppFloatingNavBar({super.key, required this.currentIndex});

  void _go(BuildContext context, int i) {
    switch (i) {
      case 0: Navigator.pushReplacementNamed(context, AppRoutes.home); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.home_rounded,      'Home'),
      (Icons.receipt_long_rounded, 'Transaksi'),
      (Icons.settings_rounded,  'Pengaturan'),
    ];

    return Positioned(
      left: 80,
      right: 80,
      bottom: 20 + MediaQuery.of(context).padding.bottom,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.purple,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (i) {
            final selected = currentIndex == i;
            return InkWell(
              onTap: () => _go(context, i),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.yellow : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  items[i].$1,
                  color: selected ? Colors.black : Colors.white,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
