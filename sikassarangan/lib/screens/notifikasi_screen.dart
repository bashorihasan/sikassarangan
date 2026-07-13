import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notifikasi_model.dart';
import '../providers/notifikasi_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/notifikasi_card.dart';
import 'transaksi_detail_screen.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotifikasiProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotifikasiProvider>().loadMore();
    }
  }

  Future<void> _onTapNotifikasi(Notifikasi notifikasi) async {
    await context.read<NotifikasiProvider>().markAsRead(notifikasi.id);

    if (!mounted) {
      return;
    }

    // Buka detail transaksi terkait (kecuali transaksi yang sudah dihapus).
    if (notifikasi.isTransaksi &&
        notifikasi.type != 'TRANSAKSI_HAPUS' &&
        notifikasi.relatedId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TransaksiDetailScreen(transaksiId: notifikasi.relatedId!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotifikasiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: const Text(
                'Tandai semua dibaca',
                style: TextStyle(color: AppColors.textOnBrown),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accentGold,
        backgroundColor: AppColors.surfaceWhite,
        onRefresh: () => provider.refresh(),
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(NotifikasiProvider provider) {
    if (provider.isLoading && provider.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.items.isEmpty) {
      return _EmptyState(message: provider.errorMessage);
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: provider.items.length + (provider.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= provider.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final notifikasi = provider.items[index];
        return NotifikasiCard(
          notifikasi: notifikasi,
          onTap: () => _onTapNotifikasi(notifikasi),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    // ListView agar pull-to-refresh tetap berfungsi saat kosong.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.28),
        Column(
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: AppColors.borderSoft,
            ),
            const SizedBox(height: 14),
            Text(
              message.isNotEmpty ? message : 'Belum ada notifikasi',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondaryBrown,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
