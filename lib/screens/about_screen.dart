import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme.dart';
import '../providers/app_info_provider.dart';
import '../widgets/custom_button.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppInfoProvider(),
      child: const _AboutView(),
    );
  }
}

class _AboutView extends StatelessWidget {
  const _AboutView();

  @override
  Widget build(BuildContext context) {
    final info = context.watch<AppInfoProvider>();

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final sidePad = math.max(16.0, w * 0.06);
        final headerH = math.min(220.0, w * 0.55);

        return Scaffold(
          backgroundColor: AppColors.greySurface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Tentang Kami',
              style: TextStyle(fontWeight: FontWeight.w800,fontSize: 18),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 24 + MediaQuery.of(context).padding.bottom),
              child: Column(
                children: [
                  // ===== Header brand dengan gradient + ripple =====
                  Container(
                    height: headerH,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.brand,
                      image: DecorationImage(
                        image: AssetImage('assets/images/bgcircle.png'),
                        fit: BoxFit.cover,
                        opacity: .18,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: sidePad),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.appName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            info.tagline,
                            style: TextStyle(
                              color: Colors.white.withOpacity(.88),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== Kartu Deskripsi =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePad),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        info.description,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(height: 1.45),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== Kartu Fitur (chips) =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePad),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Fitur Utama'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final f in info.features)
                                _ChipPill(label: f),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== Kontak & Versi =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePad),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const _SectionTitle('Kontak & Bantuan'),
                          const SizedBox(height: 10),
                          _InfoTile(
                            icon: Icons.mail_rounded,
                            title: 'Email',
                            subtitle: info.email,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Buka email: ${info.email}')),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _InfoTile(
                            icon: Icons.phone_rounded,
                            title: 'Telepon',
                            subtitle: info.phone,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Hubungi: ${info.phone}')),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _InfoTile(
                            icon: Icons.location_on_rounded,
                            title: 'Alamat',
                            subtitle: info.address,
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _KeyValueText(
                                  label: 'Versi',
                                  value: info.version,
                                ),
                              ),
                              Expanded(
                                child: _KeyValueText(
                                  label: 'Build',
                                  value: info.buildNumber,
                                  alignEnd: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Aksi: Kebijakan & Ketentuan (pakai CustomButton agar seragam)
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  label: 'Kebijakan Privasi',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Buka Kebijakan Privasi (dummy)')),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  label: 'Syarat & Ketentuan',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Buka S&K (dummy)')),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.purple,
          ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  final String label;
  const _ChipPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.yellow.withOpacity(.16),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.yellow.withOpacity(.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  color: AppColors.greySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline_rounded, color: AppColors.purple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyValueText extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _KeyValueText({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label\n',
              style: const TextStyle(color: Colors.black54),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
      ),
    );
  }
}
