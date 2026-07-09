import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaksi_model.dart';
import '../providers/transaksi_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import 'transaksi_form_screen.dart';

class TransaksiDetailScreen extends StatefulWidget {
  const TransaksiDetailScreen({super.key, required this.transaksiId});

  final int transaksiId;

  @override
  State<TransaksiDetailScreen> createState() => _TransaksiDetailScreenState();
}

class _TransaksiDetailScreenState extends State<TransaksiDetailScreen> {
  late Future<Transaksi> _futureTransaksi;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _futureTransaksi = context.read<TransaksiProvider>().getTransaksiById(widget.transaksiId);
  }

  void _reload() {
    setState(() {
      _futureTransaksi = context.read<TransaksiProvider>().getTransaksiById(widget.transaksiId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: FutureBuilder<Transaksi>(
        future: _futureTransaksi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorView(
              message: 'Gagal memuat detail transaksi',
              onRetry: _reload,
            );
          }

          final transaksi = snapshot.data;
          if (transaksi == null) {
            return _ErrorView(
              message: 'Transaksi tidak ditemukan',
              onRetry: _reload,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSoft, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rincian Transaksi',
                        style: TextStyle(
                          color: AppColors.textSecondaryBrown,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        transaksi.namaTransaksi,
                        style: const TextStyle(
                          color: AppColors.textCardTitle,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _currencyFormat.format(transaksi.nominal),
                        style: const TextStyle(
                          color: AppColors.primaryBrown,
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
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
                const SizedBox(height: 16),
                _InfoPanel(
                  title: 'Detail Lengkap',
                  children: [
                    _InfoRow(label: 'Nama Pihak', value: transaksi.namaPihak),
                    _InfoRow(label: 'ID', value: transaksi.id?.toString() ?? '-'),
                    _InfoRow(label: 'Dibuat', value: _formatDate(transaksi.createdAt)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TransaksiFormScreen(transaksi: transaksi),
                            ),
                          );
                          if (updated == true) {
                            _reload();
                          }
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accentGold, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: provider.isSubmitting ? null : () => _deleteTransaksi(transaksi),
                        icon: provider.isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.cashOutRed,
                                ),
                              )
                            : const Icon(Icons.delete_outline),
                        label: Text(provider.isSubmitting ? 'Menghapus...' : 'Hapus'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.cashOutRed,
                          side: const BorderSide(color: AppColors.cashOutRed, width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
                if (provider.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteTransaksi(Transaksi transaksi) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus transaksi?'),
          content: const Text('Aksi ini tidak bisa dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cashOutRed,
                foregroundColor: AppColors.textOnBrown,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) {
      return;
    }

    await context.read<TransaksiProvider>().deleteTransaksi(transaksi.id!);

    if (!mounted) {
      return;
    }

    final provider = context.read<TransaksiProvider>();
    if (provider.errorMessage.isEmpty) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.errorMessage)),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'REIMBURSE':
        return AppColors.reimburseBackground;
      case 'LUNAS':
        return AppColors.lunasBackground;
      default:
        return AppColors.pendingBackground;
    }
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

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }

    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime.toLocal());
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSoft, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textCardTitle,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondaryBrown,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textCardTitle,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 54, color: AppColors.cashOutRed),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
