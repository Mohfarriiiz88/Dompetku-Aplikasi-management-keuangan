import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartbudget/routes/app_routes.dart';
import 'package:smartbudget/core/theme/theme.dart';
import 'package:smartbudget/providers/auth_provider.dart';
import 'package:smartbudget/widgets/custom_button.dart';

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

    if (ok) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: LayoutBuilder(
        builder: (context, c) {
          final h = c.maxHeight;
          final viewInsets = MediaQuery.of(context).viewInsets.bottom;

          // ===== Tinggi panel RELATIF & adaptif =====
          double panelTopFactor = 0.42;         // baseline
          if (h < 700) panelTopFactor -= 0.05;  // layar kecil -> panel lebih tinggi
          if (viewInsets > 0) panelTopFactor -= 0.10; // saat keyboard muncul
          panelTopFactor = panelTopFactor.clamp(0.25, 0.55);

          return Scaffold(
            body: Stack(
              children: [
                // BACKGROUND
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppGradients.brand,
                      image: DecorationImage(
                        image: AssetImage('assets/images/bgcircle.png'),
                        fit: BoxFit.cover,
                        opacity: 0.25,
                        filterQuality: FilterQuality.low,
                      ),
                    ),
                  ),
                ),

                // BRAND
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

                // ===== PANEL FORM: full kiri–kanan–bawah, responsif =====
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: h * panelTopFactor,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // panel isi seluruh area
                      Positioned.fill(
                        child: Container(
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
                          // ==== Konten anti-overflow ====
                          child: LayoutBuilder(
                            builder: (ctx, cons) {
                              return SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  20,
                                  28,
                                  20,
                                  24 + MediaQuery.of(context).padding.bottom,
                                ),
                                child: ConstrainedBox(
                                  constraints:
                                      BoxConstraints(minHeight: cons.maxHeight),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
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
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: const InputDecoration(
                                            hintText: 'E-mail',
                                          ),
                                          validator: (v) => (v == null ||
                                                  v.trim().isEmpty)
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
                                          validator: (v) => (v == null ||
                                                  v.length < 6)
                                              ? 'Minimal 6 karakter'
                                              : null,
                                        ),
                                        const SizedBox(height: 20),

                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {},
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
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
                                        const SizedBox(height: 30),

                                        CustomButton(
                                          label: 'Masuk',
                                          loading: auth.loading,
                                          onPressed:
                                              auth.loading ? null : _submit,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // KOIN
                      Positioned(
                        top: -120,
                        left: 20,
                        child: SizedBox(
                          width: 180,
                          height: 180,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/koin.png'),
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // FAB → Register
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
  