import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaksi_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/transaksi_card.dart';
import 'transaksi_detail_screen.dart';

class TransaksiListScreen extends StatelessWidget {
  const TransaksiListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Transaksi'),
        backgroundColor: AppColors.primaryBrown,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<TransaksiProvider>().loadTransaksi(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Daftar transaksi kas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: context.read<TransaksiProvider>().setSearchQuery,
              decoration: const InputDecoration(
                labelText: 'Cari nama pihak / nama transaksi / status',
                prefixIcon: Icon(Icons.search),
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
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: context.read<TransaksiProvider>().clearFilters,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Reset Filter'),
              ),
            ),
            const SizedBox(height: 8),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage.isNotEmpty && provider.filteredTransaksi.isEmpty)
              _ErrorBlock(
                message: provider.errorMessage,
                onRetry: () => context.read<TransaksiProvider>().loadTransaksi(),
              )
            else if (provider.filteredTransaksi.isEmpty)
              _EmptyBlock(
                title: 'Belum ada transaksi',
                subtitle: 'Data transaksi akan tampil di sini setelah ditambahkan.',
              )
            else
              ...provider.filteredTransaksi.map(
                (transaksi) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TransaksiCard(
                    transaksi: transaksi,
                    onTap: () async {
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
  const _EmptyBlock({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2D4C4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.goldSoft),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
