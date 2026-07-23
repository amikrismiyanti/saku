import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/currency_input_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../models/savings_goal_model.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddSavingsScreen extends StatefulWidget {
  const AddSavingsScreen({super.key});

  @override
  State<AddSavingsScreen> createState() => _AddSavingsScreenState();
}

class _AddSavingsScreenState extends State<AddSavingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController(text: '0');
  DateTime? _deadline;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final goal = SavingsGoalModel(
        id: '',
        name: _nameController.text.trim(),
        targetAmount: CurrencyFormatter.parse(_targetController.text),
        currentAmount: CurrencyFormatter.parse(_currentController.text),
        deadline: _deadline,
        status: 'ongoing',
        createdAt: DateTime.now(),
      );
      await context.read<SavingsProvider>().addGoal(goal);
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
      appBar: AppBar(title: const Text('Tambah Target Tabungan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Nama Target',
              hint: 'mis. Beli HP Baru',
              validator: (v) => Validators.required(v, field: 'Nama target'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _targetController,
              label: 'Nominal Target',
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              prefixText: const Text('Rp '),
              validator: (v) => Validators.amount(_targetController.text),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _currentController,
              label: 'Sudah Terkumpul (opsional)',
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              prefixText: const Text('Rp '),
            ),
            const SizedBox(height: 16),
            Text('Deadline (opsional)',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            CustomTextField(
              controller: TextEditingController(
                  text:
                      _deadline == null ? '' : DateFormatter.full(_deadline!)),
              label: '',
              hint: 'Pilih tanggal',
              readOnly: true,
              onTap: _pickDeadline,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
            const SizedBox(height: 28),
            CustomButton(
              label: 'Simpan Target',
              onPressed: _save,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
