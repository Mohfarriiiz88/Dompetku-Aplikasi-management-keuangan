import 'package:flutter/foundation.dart';

class AppInfoProvider extends ChangeNotifier {
  final String appName = 'SmartBudget';
  final String tagline = 'Kelola uang jadi simpel, rencana finansial lebih terarah.';
  final String description =
      'SmartBudget adalah aplikasi manajemen keuangan pribadi yang membantu '
      'kamu mencatat pemasukan & pengeluaran, memantau kategori, serta melihat '
      'statistik keuangan bulanan. Fokus pada kemudahan, visual yang jelas, '
      'dan otomatisasi sederhana agar budgeting terasa menyenangkan.';

  final List<String> features = const [
    'Catat transaksi kilat',
    'Kategori fleksibel',
    'Laporan & statistik',
    'Mode gelap/terang (opsional)',
    'Keamanan data lokal',
  ];

  final String version = '1.0.0';
  final String buildNumber = '100';
  final String email = 'support@smartbudget.app';
  final String phone = '+62 811-2222-3333';
  final String address = 'Jakarta, Indonesia';
}
