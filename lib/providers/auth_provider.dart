import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  Future<bool> login({required String email, required String password}) async {
    if (_loading) return false;
    _loading = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    if (kDebugMode) print('[DUMMY LOGIN] email=$email password=$password');
    _loading = false; notifyListeners();
    return true;
  }

  // === NEW: Register dummy ===
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    if (_loading) return false;
    _loading = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));
    if (kDebugMode) {
      print('[DUMMY REGISTER] username=$username email=$email password=$password');
    }
    _loading = false; notifyListeners();
    return true;
  }
}
