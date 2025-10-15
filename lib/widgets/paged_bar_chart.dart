import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import 'simple_bar_chart.dart';

/// Menampilkan bar chart per 6 bulan per "slide" (page),
/// swipe ke samping untuk lihat 6 bulan berikutnya.
class PagedBarChart extends StatefulWidget {
  final List<String> months;
  final List<double> incomes;
  final List<double> expenses;

  /// Tinggi internal chart dikontrol oleh parent (mis. Expanded + LayoutBuilder).
  const PagedBarChart({
    super.key,
    required this.months,
    required this.incomes,
    required this.expenses,
  });

  @override
  State<PagedBarChart> createState() => _PagedBarChartState();
}

class _PagedBarChartState extends State<PagedBarChart> {
  final _pageCtrl = PageController();
  int _page = 0;

  List<T> _pageSlice<T>(List<T> src, int start, int count) {
    final end = math.min(start + count, src.length);
    return src.sublist(start, end);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.months.length;
    final pageCount = (total / 6).ceil().clamp(1, 999);

    return Column(
      children: [
        // ==== PAGE CONTENT ====
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;

              // hitung barWidth & groupSpace dinamis supaya pas 6 grup
              // rule of thumb responsif:
              final barWidth = w * 0.03;                            // ~3% lebar
              final bw = barWidth.clamp(8.0, 16.0);                 // clamp aman
              const innerSpace = 6.0;                               // antar 2 bar
              // rumus: groupSpace = (areaWidth/6) - (2*barWidth + innerSpace)
              // padding horizontal di SimpleBarChart: 8 + 8
              final areaWidth = (w - 16);
              double groupSpace = (areaWidth / 6) - (2 * bw + innerSpace);
              groupSpace = groupSpace.clamp(10.0, 28.0);

              return PageView.builder(
                controller: _pageCtrl,
                physics: const PageScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: pageCount,
                itemBuilder: (_, i) {
                  final start = i * 6;
                  final m = _pageSlice(widget.months, start, 6);
                  final inc = _pageSlice(widget.incomes, start, 6);
                  final exp = _pageSlice(widget.expenses, start, 6);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4), // ruang kecil titles
                    child: SimpleBarChart(
                      months: m,
                      incomes: inc,
                      expenses: exp,
                      barWidth: bw,
                      groupSpace: groupSpace,
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // ==== PAGE INDICATOR (opsional, kecil & rapi) ====
        if (pageCount > 1) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (i) {
              final selected = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: selected ? 20 : 6,
                decoration: BoxDecoration(
                  color: selected ? AppColors.purple : Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
