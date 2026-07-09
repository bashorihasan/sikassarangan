import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaksi_model.dart';
import '../providers/transaksi_provider.dart';
import '../theme/app_theme.dart';

class TransaksiFormScreen extends StatefulWidget {
  const TransaksiFormScreen({super.key, this.transaksi});

  final Transaksi? transaksi;

  @override
  State<TransaksiFormScreen> createState() => _TransaksiFormScreenState();
}

class _TransaksiFormScreenState extends State<TransaksiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaTransaksiController = TextEditingController();
  final _nominalController = TextEditingController();
  final _namaPihakController = TextEditingController();

  String _jenisTransaksi = 'KAS_MASUK';
  String _status = 'PENDING';

  bool get _isEdit => widget.transaksi != null;

  @override
  void initState() {
    super.initState();

    final transaksi = widget.transaksi;
    if (transaksi != null) {
      _namaTransaksiController.text = transaksi.namaTransaksi;
      _nominalController.text = _formatRupiahInput(transaksi.nominal);
      _namaPihakController.text = transaksi.namaPihak;
      _jenisTransaksi = transaksi.jenisTransaksi;
      _status = transaksi.status;
    }
  }

  @override
  void dispose() {
    _namaTransaksiController.dispose();
    _nominalController.dispose();
    _namaPihakController.dispose();
    super.dispose();
  }

  static final _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Transaksi' : 'Tambah Transaksi'),
        backgroundColor: AppColors.primaryBrown,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEdit ? 'Perbarui data transaksi' : 'Isi transaksi kas baru',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pastikan nominal dan status sudah sesuai sebelum disimpan.',
                  style: TextStyle(color: Color(0xFF766355)),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _namaTransaksiController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama Transaksi',
                    hintText: 'Contoh: Iuran HUT RI',
                  ),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nominalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _RupiahInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Nominal',
                    hintText: 'Rp 0',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nominal wajib diisi';
                    }
                    final nominal = _parseNominal(value);
                    if (nominal <= 0) {
                      return 'Nominal harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _jenisTransaksi,
                  items: const [
                    DropdownMenuItem(
                      value: 'KAS_MASUK',
                      child: Text('KAS_MASUK'),
                    ),
                    DropdownMenuItem(
                      value: 'KAS_KELUAR',
                      child: Text('KAS_KELUAR'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _jenisTransaksi = value);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Jenis Transaksi',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  items: const [
                    DropdownMenuItem(value: 'REIMBURSE', child: Text('REIMBURSE')),
                    DropdownMenuItem(value: 'LUNAS', child: Text('LUNAS')),
                    DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Status',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _namaPihakController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pihak',
                    hintText: 'Contoh: Warga RT 05',
                  ),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: provider.isSubmitting ? null : _submit,
                    icon: provider.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(provider.isSubmitting ? 'Menyimpan...' : 'Simpan'),
                  ),
                ),
                if (provider.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
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
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini wajib diisi';
    }
    return null;
  }

  double _parseNominal(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(digits) ?? 0;
  }

  String _formatRupiahInput(double value) {
    return _rupiahFormat.format(value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final transaksi = Transaksi(
      id: widget.transaksi?.id,
      namaTransaksi: _namaTransaksiController.text.trim(),
      nominal: _parseNominal(_nominalController.text),
      jenisTransaksi: _jenisTransaksi,
      status: _status,
      namaPihak: _namaPihakController.text.trim(),
      createdAt: widget.transaksi?.createdAt,
      updatedAt: widget.transaksi?.updatedAt,
    );

    final provider = context.read<TransaksiProvider>();
    final result = _isEdit
        ? await provider.updateTransaksi(widget.transaksi!.id!, transaksi)
        : await provider.createTransaksi(transaksi);

    if (!mounted) {
      return;
    }

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Transaksi berhasil diperbarui' : 'Transaksi berhasil disimpan',
          ),
        ),
      );
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.errorMessage.isNotEmpty
            ? provider.errorMessage
            : 'Gagal menyimpan transaksi'),
      ),
    );
  }
}

class _RupiahInputFormatter extends TextInputFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.tryParse(digits) ?? 0;
    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
