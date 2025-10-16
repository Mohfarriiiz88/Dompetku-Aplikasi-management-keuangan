import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';

/// Model user simpel agar bisa diakses dari UI.
class AuthUser {
  final String nama;
  final String email;
  final String? img;

  const AuthUser({
    required this.nama,
    required this.email,
    this.img,
  });
}

class AuthProvider extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _token;           // simpan token kalau nanti pakai API beneran
  AuthUser? _user;          // <-- inilah yang dipakai di profile_screen
  AuthUser? get user => _user;

  // Dummy LOGIN — set token & user supaya profile_screen bisa membaca.
  Future<bool> login({required String email, required String password}) async {
    if (_loading) return false;
    _loading = true; notifyListeners();
    try {
      // If configured to use API, call backend
      if (useApi && baseUrl.isNotEmpty) {
        final url = Uri.parse('$baseUrl/api/v1/auth/login');
        final resp = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );
        if (kDebugMode) print('[API LOGIN] ${resp.statusCode} ${resp.body}');
        if (resp.statusCode == 200) {
          final body = jsonDecode(resp.body) as Map<String, dynamic>;
          _token = body['token'] as String?;
          // Minimal: set user from email, you can fetch /api/v1/me later
          _user = AuthUser(nama: email.split('@').first, email: email, img: null);
          return true;
        }
        return false;
      }

      // Fallback dummy behavior (local dev without backend)
      await Future.delayed(const Duration(milliseconds: 800));
      if (kDebugMode) print('[DUMMY LOGIN] email=$email password=$password');

      _token = 'dummy-token';
      _user = AuthUser(nama: 'Moh. Fariz', email: email, img: null);
      return true;
    } catch (_) {
      return false;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  // Dummy REGISTER — set user juga biar langsung kebaca di profil.
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    if (_loading) return false;
    _loading = true; notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 900));
      if (kDebugMode) {
        print('[DUMMY REGISTER] username=$username email=$email password=$password');
      }

      _token = 'dummy-token';
      _user  = AuthUser(nama: username, email: email, img: null);
      return true;
    } catch (_) {
      return false;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  /// Kalau nanti pakai API /auth/me, panggil ini untuk refresh profil.
  Future<void> loadProfile() async {
    if (_token == null) return;
    // Dummy: kalau belum ada user, isi default
    _user ??= const AuthUser(nama: 'Moh. Fariz', email: 'user@mail.com');
    notifyListeners();
  }

  /// Logout untuk menu Pengaturan.
  Future<void> logout() async {
    _token = null;
    _user  = null;
    notifyListeners();
  }
}
