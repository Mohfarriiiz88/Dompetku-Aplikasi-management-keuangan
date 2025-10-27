import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';

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
  bool hasFetched = false; // true after first fetch completes

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
          return !t.time.isBefore(
                DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
              ) &&
              t.time.isBefore(
                DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
              );
        case 2: // bulan ini
        default:
          return (t.time.year == now.year && t.time.month == now.month);
      }
    }).toList()..sort((a, b) => b.time.compareTo(a.time));
  }

  int get totalIncome => filtered
      .where((e) => e.type == TxType.income)
      .fold(0, (p, e) => p + e.amount);
  int get totalExpense => filtered
      .where((e) => e.type == TxType.expense)
      .fold(0, (p, e) => p + e.amount);
  int get balance => totalIncome - totalExpense;

  // ===== Unfiltered totals (all transactions) =====
  int get totalIncomeAll => _all
      .where((e) => e.type == TxType.income)
      .fold(0, (p, e) => p + e.amount);
  int get totalExpenseAll => _all
      .where((e) => e.type == TxType.expense)
      .fold(0, (p, e) => p + e.amount);
  int get totalBalanceAll => totalIncomeAll - totalExpenseAll;

  void setSegment(int i) {
    if (i == segment) return;
    segment = i;
    notifyListeners();
  }

  void setNavIndex(int i) {
    if (i == navIndex) return;
    navIndex = i;
    notifyListeners();
  }

  /// Fetch transactions from backend and replace local list
  Future<void> fetchTransactions({String? token}) async {
    if (!useApi || baseUrl.isEmpty) return;
    try {
      final url = Uri.parse('$baseUrl/api/v1/transactions');
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';
      final resp = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>?;
        if (data != null) {
          _all.clear();
          for (final item in data) {
            final m = item as Map<String, dynamic>;
            final jenis = (m['jenis'] as String?) ?? 'pengeluaran';
            final kategori = (m['kategori'] as String?) ?? '';
            final jumlahNum = m['jumlah'];
            final amount = (jumlahNum is int)
                ? jumlahNum
                : (jumlahNum is double
                      ? jumlahNum.toInt()
                      : int.tryParse(jumlahNum?.toString() ?? '0') ?? 0);
            final created =
                DateTime.tryParse(m['created_at']?.toString() ?? '') ??
                DateTime.now();
            final title = (m['keterangan'] as String?) ?? kategori;
            final type = jenis.toLowerCase() == 'pemasukan'
                ? TxType.income
                : TxType.expense;
            _all.add(
              TransactionItem(
                title: title,
                category: kategori,
                time: created,
                amount: amount,
                type: type,
              ),
            );
          }
          notifyListeners();
          hasFetched = true;
        }
      }
    } catch (e) {
      if (kDebugMode) print('[HOME FETCH TX] $e');
      hasFetched =
          true; // mark fetched to avoid showing dummy totals indefinitely
    }
  }
}
