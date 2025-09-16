import 'package:flutter/foundation.dart';
import 'home_provider.dart' show TransactionItem, TxType;

enum Period { today, week, month }

class RecentProvider extends ChangeNotifier {
  Period period = Period.today;

  // Dummy data
  final List<TransactionItem> _all = [
    TransactionItem(
      title: 'Transfer dari Bapa',
      category: 'Transfer',
      amount: 1000000,
      time: DateTime.now().subtract(const Duration(hours: 1)),
      type: TxType.income,
    ),
    TransactionItem(
      title: 'Makan Soto',
      category: 'Makan malam',
      amount: 20000,
      time: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      type: TxType.expense,
    ),
    TransactionItem(
      title: 'Kopi kenangan',
      category: 'Jajan',
      amount: 22000,
      time: DateTime.now().subtract(const Duration(days: 3)),
      type: TxType.expense,
    ),
    TransactionItem(
      title: 'Nasi padang',
      category: 'Makan siang',
      amount: 12000,
      time: DateTime.now().subtract(const Duration(days: 18)),
      type: TxType.expense,
    ),
  ];

  void setPeriod(int index) {
    period = Period.values[index];
    notifyListeners();
  }

  List<TransactionItem> get items {
    final now = DateTime.now();
    switch (period) {
      case Period.today:
        return _all.where((e) =>
          e.time.year == now.year && e.time.month == now.month && e.time.day == now.day).toList();
      case Period.week:
        final start = now.subtract(Duration(days: now.weekday - 1)); // Senin
        final end = start.add(const Duration(days: 7));
        return _all.where((e) => e.time.isAfter(start) && e.time.isBefore(end)).toList();
      case Period.month:
        final startM = DateTime(now.year, now.month, 1);
        final endM = DateTime(now.year, now.month + 1, 1);
        return _all.where((e) => e.time.isAfter(startM) && e.time.isBefore(endM)).toList();
    }
  }
}
