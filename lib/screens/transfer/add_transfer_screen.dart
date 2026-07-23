import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/currency_input_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../models/transfer_model.dart';
import '../../providers/transfer_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddTransferScreen extends StatefulWidget {
  const AddTransferScreen({super.key});

  @override
  State<AddTransferScreen> createState() => _AddTransferScreenState();
}

class _AddTransferScreenState extends State<AddTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _fromWalletId;
  String? _toWalletId;
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromWalletId == null || _toWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dompet asal dan tujuan')),
      );
      return;
    }
    if (_fromWalletId == _toWalletId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dompet asal dan tujuan tidak boleh sama')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final transfer = TransferModel(
        id: '',
        fromWalletId: _fromWalletId!,
        toWalletId: _toWalletId!,
        amount: CurrencyFormatter.parse(_amountController.text),
        date: _date,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: DateTime.now(),
      );
      await context.read<TransferProvider>().addTransfer(transfer);
      if (mounted) {
        await context.read<WalletProvider>().loadWallets();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer berhasil')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal transfer: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = context.watch<WalletProvider>().wallets;

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Antar Dompet')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Dari Dompet', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _fromWalletId,
              hint: const Text('Pilih dompet asal'),
              items: wallets
                  .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                  .toList(),
              onChanged: (v) => setState(() => _fromWalletId = v),
            ),
            const SizedBox(height: 16),
            Text('Ke Dompet', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _toWalletId,
              hint: const Text('Pilih dompet tujuan'),
              items: wallets
                  .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                  .toList(),
              onChanged: (v) => setState(() => _toWalletId = v),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _amountController,
              label: 'Nominal',
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              prefixText: const Text('Rp '),
              validator: (v) => Validators.amount(_amountController.text),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: TextEditingController(text: DateFormatter.full(_date)),
              label: 'Tanggal',
              readOnly: true,
              onTap: _pickDate,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Keterangan (opsional)',
              hint: 'mis. simpan sisa gaji',
              maxLines: 2,
            ),
            const SizedBox(height: 28),
            CustomButton(
              label: 'Simpan Transfer',
              onPressed: _save,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
