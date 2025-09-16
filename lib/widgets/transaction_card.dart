import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import '../providers/home_provider.dart' show TransactionItem, TxType;

class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key, required this.item, this.onTap});
  final TransactionItem item;
  final VoidCallback? onTap;

  String _dateFmt(DateTime d) {
    const mons = [
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember'
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm  •  ${d.day} ${mons[d.month-1]} ${d.year}';
  }

  String _rp(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final rev = s.length - i;
      buf.write(s[i]);
      if (rev > 1 && rev % 3 == 1) buf.write('.');
    }
    return 'Rp. $buf';
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == TxType.income;

    final badgeColor = isIncome ? AppColors.green : AppColors.red;
    final badgeBg = badgeColor.withOpacity(.12);
    final icon = isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
              child: Icon(icon, color: badgeColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('${item.category}\n${_dateFmt(item.time)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            Text(_rp(item.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
