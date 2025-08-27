import 'package:flutter/material.dart';

enum TxType { income, expense }

class TransactionItem {
  final String title;
  final String category;
  final DateTime time;
  final int amount; // rupiah
  final TxType type;

  const TransactionItem({
    required this.title,
    required this.category,
    required this.time,
    required this.amount,
    required this.type,
  });
}

class HomeProvider extends ChangeNotifier {
  int segment = 0; // 0: hari ini, 1: minggu ini, 2: bulan ini
  int navIndex = 0;

  // ===== Dummy data =====
  final List<TransactionItem> _all = [
    TransactionItem(
      title: 'Transfer dari Bapa',
      category: 'Transfer',
      time: DateTime(2025, 8, 25, 21, 9),
      amount: 1000000,
      type: TxType.income,
    ),
    TransactionItem(
      title: 'Makan Soto',
      category: 'Makan malam',
      time: DateTime(2025, 8, 25, 20, 27),
      amount: 20000,
      type: TxType.expense,
    ),
    TransactionItem(
      title: 'Kopi kenangan',
      category: 'Jajan',
      time: DateTime(2025, 8, 25, 14, 27),
      amount: 22000,
      type: TxType.expense,
    ),
    TransactionItem(
      title: 'Gaji Agustus',
      category: 'Gaji',
      time: DateTime(2025, 8, 24, 10, 0),
      amount: 4500000,
      type: TxType.income,
    ),
    TransactionItem(
      title: 'BBM motor',
      category: 'Transport',
      time: DateTime(2025, 8, 20, 9, 11),
      amount: 12000,
      type: TxType.expense,
    ),
  ];

  List<TransactionItem> get filtered {
    final now = DateTime.now();
    bool inSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    return _all.where((t) {
      switch (segment) {
        case 0: // hari ini
          return inSameDay(t.time, now);
        case 1: // minggu ini
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 7));
          return !t.time.isBefore(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)) &&
                 t.time.isBefore(DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day));
        case 2: // bulan ini
        default:
          return (t.time.year == now.year && t.time.month == now.month);
      }
    }).toList()
      ..sort((a, b) => b.time.compareTo(a.time));
  }

  int get totalIncome =>
      filtered.where((e) => e.type == TxType.income).fold(0, (p, e) => p + e.amount);
  int get totalExpense =>
      filtered.where((e) => e.type == TxType.expense).fold(0, (p, e) => p + e.amount);
  int get balance => totalIncome - totalExpense;

  void setSegment(int i) {
    if (i == segment) return;
    segment = i; notifyListeners();
  }

  void setNavIndex(int i) {
    if (i == navIndex) return;
    navIndex = i; notifyListeners();
  }
}
