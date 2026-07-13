import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/notifikasi_model.dart';
import '../theme/app_theme.dart';

class NotifikasiCard extends StatelessWidget {
  const NotifikasiCard({super.key, required this.notifikasi, this.onTap});

  final Notifikasi notifikasi;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !notifikasi.isRead;

    return Card(
      color: unread ? AppColors.unreadTint : AppColors.surfaceWhite,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dot kecil gold di kiri untuk item yang belum dibaca.
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 8),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: unread ? AppColors.accentGold : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _iconColor().withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_iconData(), color: _iconColor(), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notifikasi.title,
                      style: TextStyle(
                        color: AppColors.textCardTitle,
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notifikasi.body,
                      style: const TextStyle(
                        color: AppColors.textSecondaryBrown,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _relativeTime(),
                      style: const TextStyle(
                        color: AppColors.textSecondaryBrown,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime() {
    final createdAt = notifikasi.createdAt;
    if (createdAt == null) {
      return '';
    }
    return timeago.format(createdAt.toLocal(), locale: 'id');
  }

  IconData _iconData() {
    switch (notifikasi.type) {
      case 'TRANSAKSI_BARU':
        return Icons.add_circle_outline;
      case 'TRANSAKSI_UPDATE':
        return Icons.edit_outlined;
      case 'TRANSAKSI_HAPUS':
        return Icons.delete_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _iconColor() {
    switch (notifikasi.type) {
      case 'TRANSAKSI_BARU':
        return AppColors.cashInGreen; // plus hijau
      case 'TRANSAKSI_UPDATE':
        return AppColors.accentGold; // edit gold
      case 'TRANSAKSI_HAPUS':
        return AppColors.cashOutRed; // trash merah bata
      default:
        return AppColors.primaryBrown; // info
    }
  }
}
