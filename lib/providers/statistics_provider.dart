import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';

/// State statistik (dummy) + helper format
class StatisticsProvider extends ChangeNotifier {
  // Label bulan
  final List<String> months = const [
    'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'
  ];

  // per-month totals (rupiah)
  final List<double> incomes = List<double>.filled(12, 0.0);
  final List<double> expenses = List<double>.filled(12, 0.0);

  bool loading = false;

  double get totalIncome => incomes.fold(0.0, (p, e) => p + e);
  double get totalExpense => expenses.fold(0.0, (p, e) => p + e);

  String formatJt(double n) {
    // convert to millions (juta) with 2 decimals
    final juta = n / 1000000.0;
    final s = juta.toStringAsFixed(2).replaceAll('.', ',');
    return 'Rp. $s Jt';
  }

  /// Fetch transactions from backend and aggregate into monthly incomes/expenses.
  Future<void> fetchFromApi({String? token}) async {
    if (!useApi || baseUrl.isEmpty) return;
    loading = true;
    notifyListeners();
    try {
      final url = Uri.parse('$baseUrl/api/v1/transactions');
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';
      final resp = await http.get(url, headers: headers).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>?;
        if (data != null) {
          // reset
          for (int i = 0; i < 12; i++) {
            incomes[i] = 0.0;
            expenses[i] = 0.0;
          }
          for (final item in data) {
            final m = item as Map<String, dynamic>;
            final jumlahRaw = m['jumlah'];
            double jumlah = 0.0;
            if (jumlahRaw is int) jumlah = jumlahRaw.toDouble();
            else if (jumlahRaw is double) jumlah = jumlahRaw;
            else jumlah = double.tryParse(jumlahRaw?.toString() ?? '0') ?? 0.0;

            final jenis = (m['jenis'] as String?)?.toLowerCase() ?? 'pengeluaran';
            final created = DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now();
            final idx = (created.month - 1).clamp(0, 11);
            if (jenis == 'pemasukan') incomes[idx] += jumlah;
            else expenses[idx] += jumlah;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('[STATS FETCH] $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
