import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum TxCategory { pemasukan, pengeluaran }

extension TxCategoryLabel on TxCategory {
  String get label => this == TxCategory.pemasukan ? 'Pemasukan' : 'Pengeluaran';
}

class TransactionFormProvider extends ChangeNotifier {
  // Controllers dipusatkan di provider
  final namaKategoriC = TextEditingController();
  final jenisC        = TextEditingController();
  final jumlahC       = TextEditingController();
  final metodeC       = TextEditingController();
  final keteranganC   = TextEditingController();

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

    _loading = true; notifyListeners();
    // TODO: panggil repository/API di sini
    await Future.delayed(const Duration(milliseconds: 700));
    _loading = false; notifyListeners();
    return true;
  }

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
