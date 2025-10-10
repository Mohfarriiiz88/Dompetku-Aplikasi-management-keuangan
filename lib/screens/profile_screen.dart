import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/floating_navbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pre-cache ripple bg agar halus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/images/bgcircle.png'), context);
    });

    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    // Data dummy jika belum ada profil dari API
    final nama = user?.nama.isNotEmpty == true ? user!.nama : 'Moh. Fariz';
    final tglLahir = '17 Januari 2003';
    final status = 'Mahasiswa';

    return Scaffold(
      body: Stack(
        children: [
          // ===== Background gradient + ripple =====
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

          // ===== Body =====
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header judul
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text(
                      'Pengaturan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Kartu profil
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ProfileInfoCard(
                    name: nama,
                    birthDate: tglLahir,
                    status: status,
                    onTap: () {}, // bisa ke halaman detail profil
                  ),
                ),
                const SizedBox(height: 16),

                // Sheet bawah (full kiri-kanan, rounded top)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.greySurface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                      children: [
                        _SettingsTile(
                          label: 'Profil',
                          onTap: () {
                            // TODO: Navigate ke edit profile
                          },
                        ),
                        const SizedBox(height: 16),
                        _SettingsTile(
                          label: 'Tentang Kami',
                          onTap: () {
                            // TODO: Navigate ke about
                          },
                        ),
                        const SizedBox(height: 16),
                        _SettingsTile(
                          label: 'Keluar',
                          textColor: AppColors.red, // biar stand out
                          onTap: () async {
                            await context.read<AuthProvider>().logout();
                            // TODO: arahkan ke halaman login jika diperlukan
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== Floating bottom navbar (reusable) =====
          const AppFloatingNavBar(currentIndex: 2), // tab Pengaturan/Settings
        ],
      ),
    );
  }
}

/// Kartu info profil (avatar + nama + tgl lahir + status)
class _ProfileInfoCard extends StatelessWidget {
  final String name;
  final String birthDate;
  final String status;
  final VoidCallback? onTap;

  const _ProfileInfoCard({
    required this.name,
    required this.birthDate,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFECEBFF), // nuansa ungu muda
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_2_outlined,
                  size: 28,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(width: 14),

              // Nama + tanggal lahir + status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      birthDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black.withOpacity(.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(.60),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu baris tombol pengaturan (kartu putih rounded)
class _SettingsTile extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? textColor;

  const _SettingsTile({
    required this.label,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
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
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textColor ?? Colors.black,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.black.withOpacity(.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
