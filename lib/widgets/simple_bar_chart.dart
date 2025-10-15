import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Widget chart dengan animasi tanpa paket eksternal.
class SimpleBarChart extends StatefulWidget {
  final List<String> months;        // label X
  final List<double> incomes;       // data pemasukan (Jt)
  final List<double> expenses;      // data pengeluaran (Jt)
  final double groupSpace;          // jarak antar kelompok bulan
  final double barWidth;            // lebar tiap bar (hijau/merah)
  final EdgeInsets padding;         // padding dalam canvas

  const SimpleBarChart({
    super.key,
    required this.months,
    required this.incomes,
    required this.expenses,
    this.groupSpace = 18,
    this.barWidth = 12,
    this.padding = const EdgeInsets.fromLTRB(12, 12, 12, 24),
  });

  @override
  State<SimpleBarChart> createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _t = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant SimpleBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // trigger animasi saat data berubah
    if (oldWidget.incomes != widget.incomes ||
        oldWidget.expenses != widget.expenses) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (_, __) {
        return CustomPaint(
          painter: _BarChartPainter(
            months: widget.months,
            incomes: widget.incomes,
            expenses: widget.expenses,
            t: _t.value,
            groupSpace: widget.groupSpace,
            barWidth: widget.barWidth,
            padding: widget.padding,
            textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
          ),
        );
      },
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<String> months;
  final List<double> incomes;
  final List<double> expenses;
  final double t; // 0..1 animasi
  final double groupSpace;
  final double barWidth;
  final EdgeInsets padding;
  final TextStyle? textStyle;

  _BarChartPainter({
    required this.months,
    required this.incomes,
    required this.expenses,
    required this.t,
    required this.groupSpace,
    required this.barWidth,
    required this.padding,
    this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintAxis = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;

    final area = Rect.fromLTWH(
      padding.left,
      padding.top,
      size.width - padding.horizontal,
      size.height - padding.vertical,
    );

    // background grid halus
    const gridCount = 4;
    for (int i = 0; i <= gridCount; i++) {
      final y = area.bottom - (area.height / gridCount) * i;
      paintAxis.color = i == 0 ? Colors.black45 : Colors.black12;
      canvas.drawLine(Offset(area.left, y), Offset(area.right, y), paintAxis);
    }

    // skala berdasarkan max value
    final maxVal = [
      ...incomes,
      ...expenses,
    ].fold<double>(0, (m, v) => math.max(m, v));
    final safeMax = (maxVal <= 0 ? 1 : maxVal) * 1.2;

    final totalGroups = months.length;
    if (totalGroups == 0) return;

    // lebar group = 2 bar + space di dalam + jarak antar group
    final double innerSpace = 6;
    final double groupW = (barWidth * 2) + innerSpace + groupSpace;

    // start X, center-kan konten jika tak penuh
    final allWidth = groupW * totalGroups;
    double startX = area.left + (area.width - allWidth) / 2;
    if (startX < area.left) startX = area.left;

    // helper lukis bar
    void drawBar({
      required double xCenter,
      required double value,   // Jt
      required Color color,
    }) {
      final h = (value / safeMax) * area.height * t; // ikut animasi
      final top = area.bottom - h;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xCenter - barWidth / 2, top, barWidth, h),
        const Radius.circular(4),
      );
      final p = Paint()..color = color;
      canvas.drawRRect(rect, p);
    }

    // teks bulan
    final tp = TextPainter(textDirection: TextDirection.ltr);

    double cursor = startX + groupSpace / 2;
    for (int i = 0; i < totalGroups; i++) {
      final xIncome = cursor + barWidth / 2;
      final xExpense = xIncome + innerSpace + barWidth;

      // bar hijau (income) & merah (expense)
      drawBar(xCenter: xIncome, value: incomes[i], color: AppColors.green);
      drawBar(xCenter: xExpense, value: expenses[i], color: AppColors.red);

      // label bulan
      tp.text = TextSpan(text: months[i], style: textStyle);
      tp.layout();
      final labelX = (xIncome + xExpense) / 2 - tp.width / 2;
      tp.paint(canvas, Offset(labelX, area.bottom + 4));

      cursor += groupW;
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) {
    return old.t != t ||
        old.months != months ||
        old.incomes != incomes ||
        old.expenses != expenses ||
        old.barWidth != barWidth ||
        old.groupSpace != groupSpace ||
        old.padding != padding;
  }
}
