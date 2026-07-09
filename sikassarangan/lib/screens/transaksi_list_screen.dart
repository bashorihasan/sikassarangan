import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaksi_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/transaksi_card.dart';
import 'transaksi_detail_screen.dart';

class TransaksiListScreen extends StatefulWidget {
  const TransaksiListScreen({super.key});

  @override
  State<TransaksiListScreen> createState() => _TransaksiListScreenState();
}

class _TransaksiListScreenState extends State<TransaksiListScreen> {
  final _searchController = TextEditingController();
  final _namaPihakController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _namaPihakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Transaksi'),
      ),
      body: RefreshIndicator(
        color: AppColors.accentGold,
        backgroundColor: AppColors.surfaceWhite,
        onRefresh: () async {
          await context.read<TransaksiProvider>().loadTransaksi();
          if (context.mounted && provider.errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.errorMessage)),
            );
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const Text(
              'Daftar transaksi kas',
              style: TextStyle(
                color: AppColors.textCardTitle,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: context.read<TransaksiProvider>().setSearchQuery,
              decoration: const InputDecoration(
                labelText: 'Cari transaksi, status, atau pihak',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _namaPihakController,
              onChanged: context.read<TransaksiProvider>().setNamaPihakFilter,
              decoration: const InputDecoration(
                labelText: 'Filter nama pihak',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: provider.statusFilter.isEmpty ? null : provider.statusFilter,
              decoration: const InputDecoration(
                labelText: 'Filter status',
              ),
              items: const [
                DropdownMenuItem(value: 'REIMBURSE', child: Text('REIMBURSE')),
                DropdownMenuItem(value: 'LUNAS', child: Text('LUNAS')),
                DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
              ],
              onChanged: (value) {
                context.read<TransaksiProvider>().setStatusFilter(value ?? '');
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _namaPihakController.clear();
                  context.read<TransaksiProvider>().clearFilters();
                },
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: const Text('Reset filter'),
              ),
            ),
            const SizedBox(height: 8),
            if (provider.errorMessage.isNotEmpty && provider.filteredTransaksi.isEmpty)
              _ErrorBlock(
                message: provider.errorMessage,
                onRetry: () async {
                  await context.read<TransaksiProvider>().loadTransaksi();
                },
              )
            else if (provider.filteredTransaksi.isEmpty)
              const _EmptyBlock()
            else
              ...provider.filteredTransaksi.map(
                (transaksi) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TransaksiCard(
                    transaksi: transaksi,
                    onTap: () async {
                      if (transaksi.id == null) {
                        return;
                      }

                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransaksiDetailScreen(
                            transaksiId: transaksi.id!,
                          ),
                        ),
                      );

                      if (updated == true && context.mounted) {
                        await context.read<TransaksiProvider>().loadTransaksi();
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSoft, width: 0.5),
      ),
      child: const Text(
        'Belum ada transaksi.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondaryBrown,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cashOutRed.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.cashOutRed),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textCardTitle,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
