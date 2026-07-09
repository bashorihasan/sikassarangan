import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/transaksi_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaksi_card.dart';
import 'transaksi_detail_screen.dart';
import 'transaksi_form_screen.dart';
import 'transaksi_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('siKasSarangan'),
        backgroundColor: AppColors.primaryBrown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<TransaksiProvider>().loadDashboard(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Lihat semua transaksi',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransaksiListScreen()),
              );
            },
            icon: const Icon(Icons.list_alt_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransaksiFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<TransaksiProvider>().loadDashboard(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBrown, AppColors.deepBrown],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Kas',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelola pemasukan dan pengeluaran kegiatan RT/panitia dengan rapi.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tema cokelat-gold dengan sentuhan tradisional yang elegan.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (provider.errorMessage.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    provider.errorMessage,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 900
                      ? 3
                      : width >= 600
                          ? 2
                          : 1;

                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      SummaryCard(
                        label: 'Total Kas Masuk',
                        value: _currencyFormat.format(provider.totalKasMasuk),
                        subtitle: 'Pemasukan seluruh transaksi',
                        icon: Icons.south_west_rounded,
                        accentColor: AppColors.goldSoft,
                      ),
                      SummaryCard(
                        label: 'Total Kas Keluar',
                        value: _currencyFormat.format(provider.totalKasKeluar),
                        subtitle: 'Pengeluaran seluruh transaksi',
                        icon: Icons.north_east_rounded,
                        accentColor: AppColors.brickRed,
                      ),
                      SummaryCard(
                        label: 'Saldo Akhir',
                        value: _currencyFormat.format(provider.saldo),
                        subtitle: 'Sisa dana tersedia',
                        icon: Icons.account_balance_wallet_rounded,
                        accentColor: AppColors.success,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi Terbaru',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransaksiListScreen(),
                        ),
                      );
                    },
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (provider.recentTransaksi.isEmpty)
                _EmptyHomeState(
                  onCreate: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TransaksiFormScreen()),
                    );
                  },
                )
              else
                ...provider.recentTransaksi.map(
                  (transaksi) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TransaksiCard(
                      transaksi: transaksi,
                      compact: true,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransaksiDetailScreen(transaksiId: transaksi.id!),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyHomeState extends StatelessWidget {
  const _EmptyHomeState({required this.onCreate});

  final VoidCallback onCreate;

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
          const Icon(Icons.receipt_long_outlined, size: 54, color: AppColors.goldSoft),
          const SizedBox(height: 12),
          const Text(
            'Belum ada transaksi tersimpan.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan transaksi pertama untuk melihat ringkasan kas.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Transaksi'),
          ),
        ],
      ),
    );
  }
}
