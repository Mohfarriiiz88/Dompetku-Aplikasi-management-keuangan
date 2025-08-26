import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes/app_routes.dart';
import '../core/theme/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final ok = await context.read<AuthProvider>().login(
      email: emailC.text.trim(),
      password: passC.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Dummy login success' : 'Gagal'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;

          return Scaffold(
            body: Stack(
              children: [
                // BACKGROUND: gradient brand
                Container(
                  decoration: const BoxDecoration(gradient: AppGradients.brand),
                ),
                // BG CIRCLE dari aset
                // ===== BACKGROUND: gradient + bgcircle.png via DecorationImage =====
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppGradients.brand, // #0E0B28 -> #282180
                      image: DecorationImage(
                        image: AssetImage('assets/images/bgcircle.png'),
                        fit: BoxFit.cover,
                        opacity: 0.25, // ripple tipis
                        filterQuality: FilterQuality.low,
                      ),
                    ),
                  ),
                ),

                // Brand text di bagian atas
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 150),
                      child: const Text(
                        'Dompetku.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),

                // PANEL FORM full kiri–kanan–bawah
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Panel (tinggi menyesuaikan konten)
                      Container(
                        width: w,
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                        decoration: BoxDecoration(
                          color: AppColors.greySurface,
                          borderRadius: AppRadius.sheet,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.15),
                              blurRadius: 18,
                              offset: const Offset(0, -6),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 16),

                              const Text(
                                'E-mail',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: emailC,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'E-mail',
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'E-mail wajib diisi'
                                    : null,
                              ),
                              const SizedBox(height: 14),

                              const Text(
                                'Kata sandi',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: passC,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: 'Kata sandi',
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Minimal 6 karakter'
                                    : null,
                              ),
                              const SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Lupa kata sandi?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Tombol Masuk (dummy)
                              CustomButton(
                                label: 'Masuk',
                                loading: auth.loading,
                                onPressed: auth.loading ? null : _submit,
                              ),

                              SizedBox(
                                height:
                                    MediaQuery.of(context).padding.bottom + 4,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Ilustrasi koin dari aset, “melayang” di atas panel
                      Positioned(
                        top: -120,
                        left: 20,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/koin.png'),
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),

                      // FAB kuning (ikon panah kanan) panggil dummy login juga
                      Positioned(
                        top: -24,
                        right: 24,
                        child: FloatingActionButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.register,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
