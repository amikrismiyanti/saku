import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_categories.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/currency_input_formatter.dart';
import '../../core/utils/validators.dart';
import '../../models/budget_model.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _category;
  bool _isSaving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _category == null) {
      if (_category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori dulu ya')),
        );
      }
      return;
    }
    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final budget = BudgetModel(
        id: '',
        category: _category!,
        amount: CurrencyFormatter.parse(_amountController.text),
        month: now.month,
        year: now.year,
        createdAt: now,
      );
      await context.read<BudgetProvider>().addBudget(budget);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Gagal menyimpan: kategori ini mungkin sudah punya budget bulan ini ($e)')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Budget')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Kategori', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _category,
              hint: const Text('Pilih kategori pengeluaran'),
              items: AppCategories.expense
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _amountController,
              label: 'Batas Anggaran Bulan Ini',
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter()
              ],
              prefixText: const Text('Rp '),
              validator: (v) => Validators.amount(_amountController.text),
            ),
            const SizedBox(height: 28),
            CustomButton(
                label: 'Simpan Budget', onPressed: _save, isLoading: _isSaving),
          ],
        ),
      ),
    );
  }
}
