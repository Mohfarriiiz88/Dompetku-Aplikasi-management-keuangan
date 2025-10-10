import 'package:flutter/foundation.dart';
import '../providers/home_provider.dart' show TransactionItem, TxType; // pakai model & dummy yang sudah ada

/// Rentang waktu tab
enum HistoryRange { today, week, month }

class HistoryProvider extends ChangeNotifier {
  HistoryProvider({List<TransactionItem>? seed}) {
    _all = seed ?? _dummy(); // pakai data dari Home kalau mau; di sini dummy fallback
    _rebuild();
  }

  // ====== State dasar ======
  List<TransactionItem> _all = [];
  List<TransactionItem> _view = [];
  List<TransactionItem> get view => _view;

  HistoryRange range = HistoryRange.today;

  // filter tambahan
  final Set<String> _selectedCategories = {}; // kosong = semua kategori
  bool sortNewestFirst = true;

  // daftar kategori unik (untuk filter sheet)
  List<String> get categories {
    final s = <String>{};
    for (final e in _all) {
      s.add(e.category);
    }
    final list = s.toList()..sort();
    return list;
  }

  // ====== Actions ======
  void setRange(HistoryRange r) {
    if (r == range) return;
    range = r;
    _rebuild();
  }

  void toggleCategory(String c) {
    if (_selectedCategories.contains(c)) {
      _selectedCategories.remove(c);
    } else {
      _selectedCategories.add(c);
    }
    _rebuild();
  }

  void clearCategory() {
    _selectedCategories.clear();
    _rebuild();
  }

  void setSort(bool newestFirst) {
    sortNewestFirst = newestFirst;
    _rebuild();
  }

  // ====== Core filter ======
  void _rebuild() {
    final now = DateTime.now();

    bool inRange(DateTime t) {
      final d = DateTime(t.year, t.month, t.day);
      final dn = DateTime(now.year, now.month, now.day);
      switch (range) {
        case HistoryRange.today:
          return d == dn;
        case HistoryRange.week:
          return t.isAfter(now.subtract(const Duration(days: 7)));
        case HistoryRange.month:
          return t.isAfter(now.subtract(const Duration(days: 30)));
      }
    }

    final afterRange = _all.where((e) => inRange(e.time));
    final afterCategory = _selectedCategories.isEmpty
        ? afterRange
        : afterRange.where((e) => _selectedCategories.contains(e.category));

    final list = afterCategory.toList()
      ..sort((a, b) => sortNewestFirst
          ? b.time.compareTo(a.time)
          : a.time.compareTo(b.time));

    _view = list;
    notifyListeners();
  }

  // ====== Dummy fallback ======
  List<TransactionItem> _dummy() {
    final now = DateTime.now();
    return [
      TransactionItem(
          title: 'Transfer dari Bapa',
          category: 'Transfer',
          amount: 1000000,
          type: TxType.income,
          time: now.subtract(const Duration(hours: 2))),
      TransactionItem(
          title: 'Makan Soto',
          category: 'Makan malam',
          amount: 20000,
          type: TxType.expense,
          time: now.subtract(const Duration(days: 1, hours: 5))),
      TransactionItem(
          title: 'Kopi kenangan',
          category: 'Jajan',
          amount: 22000,
          type: TxType.expense,
          time: now.subtract(const Duration(days: 2, hours: 1))),
      TransactionItem(
          title: 'Nasi padang',
          category: 'Makan siang',
          amount: 12000,
          type: TxType.expense,
          time: now.subtract(const Duration(days: 5))),
    ];
  }
}
