import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_categories.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/currency_input_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Form Tambah / Edit Transaksi.
/// Kalau [transaction] diisi -> mode edit, kalau null -> mode tambah baru.
class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _paymentMethodController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _category;
  String? _walletId;
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  bool get _isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _type = tx.type;
      _category = tx.category;
      _walletId = tx.walletId;
      _date = tx.date;
      _amountController.text = CurrencyFormatter.format(tx.amount).replaceAll('Rp', '').trim();
      _descriptionController.text = tx.description ?? '';
      _paymentMethodController.text = tx.paymentMethod ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  List<String> get _categoryOptions =>
      _type == TransactionType.income ? AppCategories.income : AppCategories.expense;

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
    if (_walletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dompet dulu ya')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final amount = CurrencyFormatter.parse(_amountController.text);
      final txProvider = context.read<TransactionProvider>();

      if (_isEditMode) {
        final updated = TransactionModel(
          id: widget.transaction!.id,
          type: _type,
          amount: amount,
          category: _category!,
          walletId: _walletId!,
          date: _date,
          paymentMethod: _paymentMethodController.text.trim().isEmpty
              ? null
              : _paymentMethodController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          createdAt: widget.transaction!.createdAt,
        );
        await txProvider.updateTransaction(updated);
      } else {
        final newTx = TransactionModel(
          id: '', // diisi Supabase (default gen_random_uuid())
          type: _type,
          amount: amount,
          category: _category!,
          walletId: _walletId!,
          date: _date,
          paymentMethod: _paymentMethodController.text.trim().isEmpty
              ? null
              : _paymentMethodController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          createdAt: DateTime.now(),
        );
        await txProvider.addTransaction(newTx);
      }

      // Saldo dompet dihitung otomatis oleh trigger di database,
      // jadi tinggal refresh daftar dompet supaya UI ikut update.
      if (mounted) {
        await context.read<WalletProvider>().loadWallets();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditMode ? 'Transaksi diperbarui' : 'Transaksi ditambahkan')),
        );
        if (_isEditMode) Navigator.of(context).pop();
        _resetFormIfNeeded();
      }
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

  void _resetFormIfNeeded() {
    if (_isEditMode) return;
    _formKey.currentState?.reset();
    _amountController.clear();
    _descriptionController.clear();
    _paymentMethodController.clear();
    setState(() {
      _category = null;
      _date = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallets = context.watch<WalletProvider>().wallets;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Toggle jenis transaksi
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Pemasukan'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Pengeluaran'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) {
                setState(() {
                  _type = selection.first;
                  _category = null; // reset kategori karena opsinya beda
                });
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor:
                    _type == TransactionType.income ? AppColors.income : AppColors.expense,
                selectedForegroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _amountController,
              label: 'Nominal',
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
              prefixText: const Text('Rp '),
              validator: (v) => Validators.amount(_amountController.text),
            ),
            const SizedBox(height: 16),

            Text('Kategori', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _category,
              hint: const Text('Pilih kategori'),
              items: _categoryOptions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v),
              validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
            ),
            const SizedBox(height: 16),

            Text('Dompet', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _walletId,
              hint: const Text('Pilih dompet'),
              items: wallets
                  .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                  .toList(),
              onChanged: (v) => setState(() => _walletId = v),
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
              controller: _paymentMethodController,
              label: 'Metode Pembayaran (opsional)',
              hint: 'mis. Tunai, Transfer, QRIS',
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _descriptionController,
              label: _type == TransactionType.income
                  ? 'Sumber / Keterangan (opsional)'
                  : 'Keterangan (opsional)',
              hint: _type == TransactionType.income
                  ? 'mis. Klien A, bonus proyek X'
                  : 'mis. makan siang di kantor',
              maxLines: 2,
            ),
            const SizedBox(height: 28),

            CustomButton(
              label: _isEditMode ? 'Simpan Perubahan' : 'Simpan Transaksi',
              onPressed: _save,
              isLoading: _isSaving,
              color: _type == TransactionType.income ? AppColors.income : AppColors.expense,
            ),
          ],
        ),
      ),
    );
  }
}
