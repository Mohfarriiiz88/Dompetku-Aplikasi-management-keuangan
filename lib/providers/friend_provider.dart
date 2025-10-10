import 'package:flutter/foundation.dart';
import '../models/friend_model.dart';

class FriendProvider extends ChangeNotifier {
  /// dummy data (10 teman)
  final List<FriendModel> _all = List.generate(
    10,
    (i) => FriendModel(
      name: 'Arda Yakarim',
      phone: '08177726817${(i + 1).toString().padLeft(2, '0')}',
    ),
  );

  /// indeks yg dianggap “punya hutang” (sekadar contoh)
  final Set<int> _debtIdx = {1, 3, 4, 7};

  String _query = '';
  int _tabIndex = 0; // 0 = semua, 1 = hutang

  int get tabIndex => _tabIndex;
  String get query => _query;

  void setTab(int i) {
    if (_tabIndex == i) return;
    _tabIndex = i;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  /// hasil akhir sesuai tab + pencarian
  List<FriendModel> get items {
    Iterable<FriendModel> src = _all;

    if (_tabIndex == 1) {
      src = src.where((e) => _debtIdx.contains(_all.indexOf(e)));
    }

    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase().trim();
      src = src.where(
        (e) => e.name.toLowerCase().contains(q) || e.phone.contains(q),
      );
    }

    return src.toList(growable: false);
  }
}
