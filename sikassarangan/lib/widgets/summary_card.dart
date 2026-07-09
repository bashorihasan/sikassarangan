import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.saldo,
    required this.totalKasMasuk,
    required this.totalKasKeluar,
  });

  final double saldo;
  final double totalKasMasuk;
  final double totalKasKeluar;

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryBrown,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo kas saat ini',
            style: TextStyle(
              color: AppColors.textSecondaryBrown,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(saldo),
            style: const TextStyle(
              color: AppColors.textOnBrown,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _BalanceBreakdownItem(
                  label: 'Kas masuk',
                  value: _currencyFormat.format(totalKasMasuk),
                  icon: Icons.keyboard_arrow_down_rounded,
                  color: AppColors.cashInGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BalanceBreakdownItem(
                  label: 'Kas keluar',
                  value: _currencyFormat.format(totalKasKeluar),
                  icon: Icons.keyboard_arrow_up_rounded,
                  color: AppColors.cashOutRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceBreakdownItem extends StatelessWidget {
  const _BalanceBreakdownItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textOnBrown,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textOnBrown,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
