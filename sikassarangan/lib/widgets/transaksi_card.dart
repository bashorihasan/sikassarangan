import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaksi_model.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

class TransaksiCard extends StatelessWidget {
  const TransaksiCard({
    super.key,
    required this.transaksi,
    this.onTap,
    this.compact = false,
  });

  final Transaksi transaksi;
  final VoidCallback? onTap;
  final bool compact;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final amountColor = transaksi.jenisTransaksi == 'KAS_MASUK'
        ? AppColors.success
        : AppColors.brickRed;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaksi.namaTransaksi,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2B1B11),
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          transaksi.namaPihak,
                          style: const TextStyle(
                            color: Color(0xFF7E6C5E),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _currencyFormat.format(transaksi.nominal),
                    style: TextStyle(
                      color: amountColor,
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusBadge(
                    label: transaksi.jenisTransaksi,
                    backgroundColor: transaksi.jenisTransaksi == 'KAS_MASUK'
                        ? AppColors.success
                        : AppColors.brickRed,
                  ),
                  StatusBadge(
                    label: transaksi.status,
                    backgroundColor: _statusColor(transaksi.status),
                    foregroundColor: _statusForeground(transaksi.status),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'REIMBURSE':
        return AppColors.reimburse;
      case 'LUNAS':
        return AppColors.success;
      default:
        return AppColors.pending;
    }
  }

  Color _statusForeground(String status) {
    switch (status) {
      case 'REIMBURSE':
        return AppColors.primaryBrown;
      case 'LUNAS':
        return Colors.white;
      default:
        return Colors.white;
    }
  }
}
