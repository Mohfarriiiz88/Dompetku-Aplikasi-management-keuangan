import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:smartbudget/providers/auth_provider.dart';
import '../core/config.dart';

enum TxCategory { pemasukan, pengeluaran }

extension TxCategoryLabel on TxCategory {
  String get label =>
      this == TxCategory.pemasukan ? 'Pemasukan' : 'Pengeluaran';
}

class TransactionFormProvider extends ChangeNotifier {
  // Controllers dipusatkan di provider
  final namaKategoriC = TextEditingController();
  final jenisC = TextEditingController();
  final jumlahC = TextEditingController();
  final metodeC = TextEditingController();
  final keteranganC = TextEditingController();

  TxCategory? kategori;
  bool _loading = false;
  bool get loading => _loading;

  void setKategori(TxCategory? v) {
    kategori = v;
    notifyListeners();
  }

  // Validasi sederhana
  String? validateRequired(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  String? validateJumlah(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    final parsed = double.tryParse(v.replaceAll('.', '').replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return 'Jumlah tidak valid';
    return null;
  }

  Future<bool> submit(GlobalKey<FormState> formKey) async {
    if (_loading) return false;
    if (!formKey.currentState!.validate()) return false;
    if (kategori == null) return false;

    _loading = true;
    notifyListeners();
    try {
      if (useApi && baseUrl.isNotEmpty) {
        // create request body
        final body = {
          'jenis': kategori == TxCategory.pemasukan
              ? 'pemasukan'
              : 'pengeluaran',
          'kategori': jenisC.text.trim(),
          'jumlah':
              double.tryParse(
                jumlahC.text.replaceAll('.', '').replaceAll(',', '.'),
              ) ??
              0,
          'metode': metodeC.text.trim(),
          'keterangan': keteranganC.text.trim(),
        };

        // get token from AuthProvider via context is not available here; caller should pass token
        // As a simple approach, try to obtain token using Provider if available in scope
        String? token;
        try {
          final ctx = globalFormContext; // will be set by caller before submit
          if (ctx != null) {
            token = Provider.of<AuthProvider>(ctx, listen: false).token;
          }
        } catch (_) {}

        final url = Uri.parse('$baseUrl/api/v1/transactions');
        final headers = {'Content-Type': 'application/json'};
        if (token != null) headers['Authorization'] = 'Bearer $token';

        final resp = await http.post(
          url,
          headers: headers,
          body: jsonEncode(body),
        );
        if (kDebugMode) print('[TX SUBMIT] ${resp.statusCode} ${resp.body}');
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          _loading = false;
          notifyListeners();
          return true;
        }
        _loading = false;
        notifyListeners();
        return false;
      }

      // TODO: panggil repository/API di sini
      await Future.delayed(const Duration(milliseconds: 700));
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) print('[TX SUBMIT ERROR] $e');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // helper: a BuildContext that can be set by caller to resolve AuthProvider token
  BuildContext? globalFormContext;

  @override
  void dispose() {
    namaKategoriC.dispose();
    jenisC.dispose();
    jumlahC.dispose();
    metodeC.dispose();
    keteranganC.dispose();
    super.dispose();
  }
}
