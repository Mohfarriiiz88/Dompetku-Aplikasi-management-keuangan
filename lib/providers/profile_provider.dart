import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'auth_provider.dart';

import '../core/config.dart';

class ProfileProvider extends ChangeNotifier {
  // allow constructing from existing AuthUser so EditProfile can prefill with
  // server values.
  ProfileProvider.fromAuth(AuthUser? user) {
    if (user != null) {
      _username = user.nama;
      _phone = user.phone;
      _gender = user.gender;
      _birthday = user.birthday;
      _status = user.status;
      _photoUrl = user.img;
    }
  }
  // ======= state profil (reflect DB; nullable when not set) =======
  String? _username;
  String? _phone;
  String? _gender;
  DateTime? _birthday;
  String? _status;
  String? _photoUrl; // null -> pakai placeholder

  bool _loading = false;

  // ======= getters =======
  String? get username => _username;
  String? get phone => _phone;
  String? get gender => _gender;
  DateTime? get birthday => _birthday;
  String? get status => _status;
  String? get photoUrl => _photoUrl;
  bool get loading => _loading;

  // ======= update foto (dummy) =======
  // Upload avatar image file to backend. Expects an [XFile] from image_picker.
  Future<bool> uploadAvatar(XFile file, String? token) async {
    if (_loading) return false;
    _loading = true;
    notifyListeners();

    try {
      if (useApi && baseUrl.isNotEmpty && token != null) {
        final uri = Uri.parse('$baseUrl/api/v1/me/avatar');
        final req = http.MultipartRequest('POST', uri);
        req.headers['Authorization'] = 'Bearer $token';
        req.files.add(await http.MultipartFile.fromPath('avatar', file.path));
        final streamed = await req.send();
        final resp = await http.Response.fromStream(streamed);
        if (kDebugMode)
          print('[API UPLOAD AVATAR] ${resp.statusCode} ${resp.body}');
        if (resp.statusCode == 200) {
          try {
            final body = jsonDecode(resp.body) as Map<String, dynamic>;
            final data = body['data'] as Map<String, dynamic>?;
            final img = data != null ? data['img'] as String? : null;
            if (img != null && img.isNotEmpty) {
              _photoUrl = img;
              notifyListeners();
            }
          } catch (_) {}
          return true;
        }
        return false;
      }

      // fallback: don't change in dummy mode
      await Future.delayed(const Duration(milliseconds: 500));
      return false;
    } catch (e) {
      if (kDebugMode) print('[UPLOAD AVATAR ERROR] $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ======= simpan perubahan =======
  /// Update profile. If [token] is provided and the app is configured to use
  /// the API, this will perform a PUT /api/v1/me call. Returns `true` on
  /// success, `false` on failure.
  Future<bool> updateProfile({
    required String username,
    required String phone,
    required String gender,
    required DateTime birthday,
    required String status,
    String? token,
  }) async {
    if (_loading) return false;
    _loading = true;
    notifyListeners();

    try {
      // If configured, call backend
      if (useApi && baseUrl.isNotEmpty && token != null) {
        final url = Uri.parse('$baseUrl/api/v1/me');
        final body = jsonEncode({
          'nama': username,
          'phone': phone,
          'gender': gender,
          // send UTC timestamp to avoid timezone shifts on the server side
          'birthday': birthday.toUtc().toIso8601String(),
          'status': status,
        });
        final resp = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );
        if (kDebugMode)
          print('[API UPDATE PROFILE] ${resp.statusCode} ${resp.body}');
        if (resp.statusCode == 200) {
          // update local state to match saved values
          _username = username;
          _phone = phone;
          _gender = gender;
          _birthday = birthday;
          _status = status;
          return true;
        }
        return false;
      }

      // Fallback dummy behaviour
      await Future.delayed(const Duration(milliseconds: 800));
      _username = username;
      _phone = phone;
      _gender = gender;
      _birthday = birthday;
      _status = status;
      return true;
    } catch (e) {
      if (kDebugMode) print('[PROFILE UPDATE ERROR] $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
