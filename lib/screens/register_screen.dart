import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smartbudget/routes/app_routes.dart';
import 'package:smartbudget/core/theme/theme.dart';
import 'package:smartbudget/providers/auth_provider.dart';
import 'package:smartbudget/widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  void dispose() {
    usernameC.dispose();
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final ok = await context.read<AuthProvider>().register(
          username: usernameC.text.trim(),
          email: emailC.text.trim(),
          password: passC.text,
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Dummy register success' : 'Gagal mendaftar'),
      behavior: SnackBarBehavior.floating,
    ));
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

          // Relatif & adaptif (sama seperti login)
          double panelTopFactor = 0.42;
          if (h < 700) panelTopFactor -= 0.05;
          if (viewInsets > 0) panelTopFactor -= 0.10;
          panelTopFactor = panelTopFactor.clamp(0.25, 0.55);

          return Scaffold(
            body: Stack(
              children: [
                // Background
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppGradients.brand,
                      image: DecorationImage(
                        image: AssetImage('assets/images/bgcircle.png'),
                        fit: BoxFit.cover,
                        opacity: .25,
                        filterQuality: FilterQuality.low,
                      ),
                    ),
                  ),
                ),

                // Brand
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

                // Panel form (relatif & anti-overflow)
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
                                          'Daftar',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        const Text(
                                          'Username',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: usernameC,
                                          decoration: const InputDecoration(
                                            hintText: 'Username',
                                          ),
                                          validator: (v) => (v == null ||
                                                  v.trim().isEmpty)
                                              ? 'Username wajib diisi'
                                              : null,
                                        ),
                                        const SizedBox(height: 14),

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
                                            hintText: 'E-Mail',
                                          ),
                                          validator: (v) {
                                            if (v == null ||
                                                v.trim().isEmpty) {
                                              return 'E-Mail wajib diisi';
                                            }
                                            final ok = RegExp(
                                                    r'^[^@]+@[^@]+\.[^@]+$')
                                                .hasMatch(v.trim());
                                            return ok
                                                ? null
                                                : 'Format e-mail tidak valid';
                                          },
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
                                        const SizedBox(height: 40),

                                        CustomButton(
                                          label: 'Daftar',
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

                      // Koin
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

                      // FAB -> Login
                      Positioned(
                        top: -24,
                        right: 24,
                        child: FloatingActionButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
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
