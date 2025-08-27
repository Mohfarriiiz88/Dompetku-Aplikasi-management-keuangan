import 'package:flutter/material.dart';
import 'package:smartbudget/screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import 'app_routes.dart';

class AppRouter {
  /// Pakai Uri.parse(settings.name) seperti contohmu untuk dukung query/segment
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');
    switch (uri.path) {
      case AppRoutes.login:
        return _fade(const LoginScreen(), settings);
      case AppRoutes.register:
        return _fade(const RegisterScreen(), settings);
      case AppRoutes.home:
        return _fade(const HomeScreen(), settings);

      default:
        // fallback sederhana
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route tidak ditemukan')),
          ),
        );
    }
  }

  // Animasi transisi ringan
  static PageRoute _fade(Widget page, RouteSettings s) => PageRouteBuilder(
        settings: s,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      );
}
