import 'package:flutter/foundation.dart';

class ProfileProvider extends ChangeNotifier {
  // ======= state profil (dummy awal) =======
  String _username = 'Moh Fariz';
  String _phone = '081234567890';
  String _gender = 'Laki-laki';
  DateTime _birthday = DateTime(2001, 5, 12);
  String _status = 'Aktif';
  String? _photoUrl; // null -> pakai placeholder

  bool _loading = false;

  // ======= getters =======
  String get username => _username;
  String get phone => _phone;
  String get gender => _gender;
  DateTime get birthday => _birthday;
  String get status => _status;
  String? get photoUrl => _photoUrl;
  bool get loading => _loading;

  // ======= update foto (dummy) =======
  Future<void> changePhotoDummy() async {
    // simulasi ganti foto; real case: panggil image picker lalu upload
    _photoUrl = null; // tetap null agar placeholder jalan; ubah sesuai use case
    notifyListeners();
  }

  // ======= simpan perubahan =======
  Future<void> updateProfile({
    required String username,
    required String phone,
    required String gender,
    required DateTime birthday,
    required String status,
  }) async {
    if (_loading) return;
    _loading = true;
    notifyListeners();

    // simulasi panggilan API
    await Future.delayed(const Duration(milliseconds: 800));

    _username = username;
    _phone = phone;
    _gender = gender;
    _birthday = birthday;
    _status = status;

    _loading = false;
    notifyListeners();
  }
}
