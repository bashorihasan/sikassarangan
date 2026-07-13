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

  static final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  @override
  Widget build(BuildContext context) {
    final amountColor = transaksi.isKasMasuk
        ? AppColors.cashInGreen
        : AppColors.cashOutRed;
    final arrowIcon = transaksi.isKasMasuk
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: amountColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(arrowIcon, color: amountColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaksi.namaTransaksi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textCardTitle,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaksi.namaPihak,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondaryBrown,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.event_outlined,
                          size: 13,
                          color: AppColors.textSecondaryBrown,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _dateFormat.format(transaksi.tanggalTransaksi.toLocal()),
                          style: const TextStyle(
                            color: AppColors.textSecondaryBrown,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StatusBadge(
                          label: transaksi.isKasMasuk ? 'KAS MASUK' : 'KAS KELUAR',
                          backgroundColor: transaksi.isKasMasuk
                              ? AppColors.lunasBackground
                              : AppColors.reimburseBackground,
                          foregroundColor: transaksi.isKasMasuk
                              ? AppColors.lunasText
                              : AppColors.reimburseText,
                          icon: transaksi.isKasMasuk
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_up_rounded,
                        ),
                        StatusBadge(
                          label: transaksi.status,
                          backgroundColor: _statusBackground(transaksi.status),
                          foregroundColor: _statusForeground(transaksi.status),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _currencyFormat.format(transaksi.nominal),
                style: TextStyle(
                  color: amountColor,
                  fontSize: compact ? 14 : 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'REIMBURSE':
        return AppColors.reimburseBackground;
      case 'LUNAS':
        return AppColors.lunasBackground;
      default:
        return AppColors.pendingBackground;
    }
  }

  Color _statusForeground(String status) {
    switch (status) {
      case 'REIMBURSE':
        return AppColors.reimburseText;
      case 'LUNAS':
        return AppColors.lunasText;
      default:
        return AppColors.pendingText;
    }
  }
}
