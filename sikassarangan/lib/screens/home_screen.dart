import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/notifikasi_provider.dart';
import '../providers/transaksi_provider.dart';
import '../services/push_notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaksi_card.dart';
import 'notifikasi_screen.dart';
import 'transaksi_detail_screen.dart';
import 'transaksi_form_screen.dart';
import 'transaksi_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _pushSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransaksiProvider>().loadDashboard();
      context.read<NotifikasiProvider>().loadUnreadCount();
    });

    // Setiap push masuk (foreground / tap), segarkan daftar & unread count.
    _pushSub = PushNotificationService.instance.onMessage.listen((_) {
      if (!mounted) {
        return;
      }
      context.read<NotifikasiProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _pushSub?.cancel();
    super.dispose();
  }

  Future<void> _openNotifikasi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
    );
    if (mounted) {
      // Segarkan badge setelah kembali dari layar notifikasi.
      context.read<NotifikasiProvider>().loadUnreadCount();
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Anda akan keluar dari akun ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) {
      return;
    }

    // Bersihkan data lokal lalu sign-out; AuthGate akan pindah ke LoginScreen.
    context.read<NotifikasiProvider>().reset();
    await context.read<AuthProvider>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();
    final auth = context.watch<AuthProvider>();
    final displayName = auth.appUser?.name ?? 'Pengguna';

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
            await context.read<NotifikasiProvider>().loadUnreadCount();
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
                      children: [
                        const Text(
                          'Selamat datang,',
                          style: TextStyle(
                            color: AppColors.textSecondaryBrown,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primaryBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<NotifikasiProvider>(
                    builder: (context, notif, _) => Badge(
                      isLabelVisible: notif.unreadCount > 0,
                      backgroundColor: AppColors.cashOutRed,
                      textColor: AppColors.textOnBrown,
                      label: Text(
                        notif.unreadCount > 99 ? '99+' : '${notif.unreadCount}',
                      ),
                      offset: const Offset(-4, 4),
                      child: IconButton(
                        onPressed: _openNotifikasi,
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.primaryBrown,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') {
                        _confirmLogout();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: AppColors.textCardTitle,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (auth.appUser?.email != null)
                              Text(
                                auth.appUser!.email,
                                style: const TextStyle(
                                  color: AppColors.textSecondaryBrown,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 20, color: AppColors.cashOutRed),
                            SizedBox(width: 10),
                            Text('Keluar'),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
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
