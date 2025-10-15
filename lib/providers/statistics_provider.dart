import 'package:flutter/foundation.dart';

/// State statistik (dummy) + helper format
class StatisticsProvider extends ChangeNotifier {
  // Label bulan
  final List<String> months = const [
    'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'
  ];

  // Dummy data dalam juta
  final List<double> incomes  = [1.8, 2.1, 1.65, 1.3, 1.95, 2.09, 2.0, 1.75, 2.2, 2.1, 2.0, 2.3];
  final List<double> expenses = [1.1, 1.35, 1.2, 0.95, 1.4, 1.51, 1.2, 1.1, 1.45, 1.3, 1.4, 1.55];

  double get totalIncome  => incomes.fold(0.0, (p, e) => p + e);
  double get totalExpense => expenses.fold(0.0, (p, e) => p + e);

  String formatJt(double n) {
    final s = n.toStringAsFixed(2).replaceAll('.', ',');
    return 'Rp. $s Jt';
  }
}
