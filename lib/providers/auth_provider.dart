import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';

/// Model user simpel agar bisa diakses dari UI.
class AuthUser {
  final String nama;
  final String email;
  final String? img;
  final int? balance;

  const AuthUser({
    required this.nama,
    required this.email,
    this.img,
    this.balance,
  });
}

class AuthProvider extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _token; // simpan token kalau nanti pakai API beneran
  AuthUser? _user; // <-- inilah yang dipakai di profile_screen
  AuthUser? get user => _user;
  String? get token => _token;

  // Dummy LOGIN — set token & user supaya profile_screen bisa membaca.
  Future<bool> login({required String email, required String password}) async {
    if (_loading) return false;
    _loading = true;
    notifyListeners();
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
          final data = body['data'] as Map<String, dynamic>?;
          _token = data != null ? data['token'] as String? : null;
          // fetch profile after getting token
          await loadProfile();
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
      _loading = false;
      notifyListeners();
    }
  }

  // Dummy REGISTER — set user juga biar langsung kebaca di profil.
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    if (_loading) return false;
    _loading = true;
    notifyListeners();
    try {
      // If configured to use API, call backend register
      if (useApi && baseUrl.isNotEmpty) {
        final url = Uri.parse('$baseUrl/api/v1/auth/register');
        final resp = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nama': username,
            'email': email,
            'password': password,
          }),
        );
        if (kDebugMode) print('[API REGISTER] ${resp.statusCode} ${resp.body}');
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return true;
        }
        return false;
      }

      // Fallback dummy behaviour
      await Future.delayed(const Duration(milliseconds: 900));
      if (kDebugMode)
        print(
          '[DUMMY REGISTER] username=$username email=$email password=$password',
        );
      _token = 'dummy-token';
      _user = AuthUser(nama: username, email: email, img: null);
      return true;
    } catch (_) {
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Kalau nanti pakai API /auth/me, panggil ini untuk refresh profil.
  Future<void> loadProfile() async {
    if (_token == null) return;
    try {
      final url = Uri.parse('$baseUrl/api/v1/me');
      final resp = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      if (kDebugMode) print('[API ME] ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>?;
        if (data != null) {
          final bal = data['balance'];
          int? balInt;
          if (bal is int) balInt = bal;
          if (bal is double) balInt = bal.toInt();
          _user = AuthUser(
            nama: data['nama']?.toString() ?? '',
            email: data['email']?.toString() ?? '',
            img: data['img']?.toString(),
            balance: balInt,
          );
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) print('[API ME ERROR] $e');
    }
    // fallback: keep existing user or dummy
    _user ??= const AuthUser(nama: 'Moh. Fariz', email: 'user@mail.com');
    notifyListeners();
  }

  /// Logout untuk menu Pengaturan.
  Future<void> logout() async {
    _token = null;
    _user = null;
    notifyListeners();
  }
}
