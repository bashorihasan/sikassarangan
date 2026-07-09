import 'package:flutter/material.dart';
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

  static const String _displayName = 'Panitia Hari Besar Nasional';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransaksiFormScreen()),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accentGold,
          backgroundColor: AppColors.surfaceWhite,
          onRefresh: () async {
            await context.read<TransaksiProvider>().loadDashboard();
            if (context.mounted && provider.errorMessage.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(provider.errorMessage)),
              );
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Selamat datang,',
                          style: TextStyle(
                            color: AppColors.textSecondaryBrown,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _displayName,
                          style: TextStyle(
                            color: AppColors.primaryBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBrown,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.accentGold,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SummaryCard(
                saldo: provider.saldo,
                totalKasMasuk: provider.totalKasMasuk,
                totalKasKeluar: provider.totalKasKeluar,
              ),
              const SizedBox(height: 18),
              if (provider.errorMessage.isNotEmpty) ...[
                _InlineNotice(message: provider.errorMessage),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Transaksi terbaru',
                      style: TextStyle(
                        color: AppColors.textCardTitle,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
              const SizedBox(height: 10),
              if (provider.isLoading && provider.transaksi.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.recentTransaksi.isEmpty)
                const _EmptyHomeState()
              else
                ...provider.recentTransaksi.take(5).map(
                      (transaksi) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TransaksiCard(
                          transaksi: transaksi,
                          compact: true,
                          onTap: () async {
                            if (transaksi.id == null) {
                              return;
                            }
        
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransaksiDetailScreen(
                                  transaksiId: transaksi.id!,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHomeState extends StatelessWidget {
  const _EmptyHomeState();

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
        'Belum ada transaksi tersimpan.',
        style: TextStyle(
          color: AppColors.textSecondaryBrown,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cashOutRed.withValues(alpha: 0.2)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.cashOutRed,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
