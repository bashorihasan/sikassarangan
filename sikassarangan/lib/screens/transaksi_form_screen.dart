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
  final _tanggalController = TextEditingController();

  String _jenisTransaksi = 'KAS_MASUK';
  String _status = 'PENDING';
  DateTime _tanggalTransaksi = DateTime.now();

  bool get _isEdit => widget.transaksi != null;

  static final _tanggalFormat = DateFormat('dd MMMM yyyy', 'id_ID');

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
      _tanggalTransaksi = transaksi.tanggalTransaksi;
    }
    _tanggalController.text = _tanggalFormat.format(_tanggalTransaksi);
  }

  @override
  void dispose() {
    _namaTransaksiController.dispose();
    _nominalController.dispose();
    _namaPihakController.dispose();
    _tanggalController.dispose();
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEdit ? 'Perbarui data transaksi' : 'Isi transaksi kas baru',
                  style: const TextStyle(
                    color: AppColors.textCardTitle,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pastikan nominal dan status sudah sesuai sebelum disimpan.',
                  style: TextStyle(
                    color: AppColors.textSecondaryBrown,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _namaTransaksiController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama Transaksi',
                    hintText: 'Contoh: Iuran HUT RI',
                  ),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tanggalController,
                  readOnly: true,
                  onTap: _pickTanggal,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Transaksi',
                    hintText: 'Pilih tanggal transaksi',
                    helperText: 'Tanggal transaksi benar-benar terjadi',
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Tanggal transaksi wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: _namaPihakController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pihak',
                    hintText: 'Contoh: Warga RT 05',
                  ),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 18),
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
                              color: AppColors.primaryBrown,
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
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cashOutRed.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      provider.errorMessage,
                      style: const TextStyle(color: AppColors.cashOutRed),
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

  Future<void> _pickTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalTransaksi,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      // Simpan tanggalnya saja (tanpa komponen jam) supaya konsisten.
      _tanggalTransaksi = DateTime(picked.year, picked.month, picked.day);
      _tanggalController.text = _tanggalFormat.format(_tanggalTransaksi);
    });
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
      tanggalTransaksi: _tanggalTransaksi,
      createdAt: widget.transaksi?.createdAt,
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
