import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/currency_input_formatter.dart';
import '../../core/utils/validators.dart';
import '../../models/wallet_model.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Form Tambah / Edit Dompet.
/// Kalau [wallet] diisi -> mode edit (saldo tidak bisa diubah manual,
/// karena saldo dihitung otomatis dari transaksi & transfer).
class AddWalletScreen extends StatefulWidget {
  final WalletModel? wallet;
  const AddWalletScreen({super.key, this.wallet});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');
  String _type = AppConstants.walletTypes.first;
  bool _isSaving = false;

  bool get _isEditMode => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    final w = widget.wallet;
    if (w != null) {
      _nameController.text = w.name;
      _type = w.type;
      _balanceController.text =
          CurrencyFormatter.format(w.balance).replaceAll('Rp', '').trim();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final provider = context.read<WalletProvider>();
      if (_isEditMode) {
        final updated = widget.wallet!.copyWith(
          name: _nameController.text.trim(),
          type: _type,
        );
        await provider.updateWallet(updated);
      } else {
        final newWallet = WalletModel(
          id: '',
          name: _nameController.text.trim(),
          balance: CurrencyFormatter.parse(_balanceController.text),
          type: _type,
          createdAt: DateTime.now(),
        );
        await provider.addWallet(newWallet);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Dompet' : 'Tambah Dompet')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Nama Dompet',
              hint: 'mis. Cash, BCA, GoPay',
              validator: (v) => Validators.required(v, field: 'Nama dompet'),
            ),
            const SizedBox(height: 16),
            Text('Jenis Dompet', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _type,
              items: AppConstants.walletTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 16),
            if (!_isEditMode)
              CustomTextField(
                controller: _balanceController,
                label: 'Saldo Awal',
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                prefixText: const Text('Rp '),
              )
            else
              Text(
                'Saldo diperbarui otomatis dari transaksi & transfer, tidak bisa diedit manual di sini.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            const SizedBox(height: 28),
            CustomButton(
              label: _isEditMode ? 'Simpan Perubahan' : 'Simpan Dompet',
              onPressed: _save,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
