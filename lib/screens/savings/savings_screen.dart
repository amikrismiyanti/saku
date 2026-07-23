import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/currency_input_formatter.dart';
import '../../providers/savings_provider.dart';
import '../../models/savings_goal_model.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/savings_goal_card.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsProvider>().loadGoals();
    });
  }

  Future<void> _confirmDelete(SavingsGoalModel goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Target?'),
        content: Text('Target "${goal.name}" akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<SavingsProvider>().deleteGoal(goal.id);
    }
  }

  Future<void> _addFundsDialog(SavingsGoalModel goal) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah Dana — ${goal.name}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            decoration:
                const InputDecoration(labelText: 'Nominal', prefixText: 'Rp '),
            validator: (v) {
              final parsed = CurrencyFormatter.parse(v ?? '');
              if (parsed <= 0) return 'Nominal harus lebih dari 0';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, CurrencyFormatter.parse(controller.text));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (amount != null && amount > 0 && mounted) {
      try {
        await context.read<SavingsProvider>().addFunds(goal, amount);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dana berhasil ditambahkan')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambah dana: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Target Tabungan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/savings/add');
          if (mounted) context.read<SavingsProvider>().loadGoals();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Target'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<SavingsProvider>().loadGoals(),
        child: provider.isLoading && provider.goals.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.goals.isEmpty
                ? LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(), // wajib, biar RefreshIndicator tetap bisa di-drag walau konten pendek
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: const Center(
                          child: EmptyState(
                            message:
                                'Belum ada target tabungan.\nTekan "Tambah Target" untuk mulai.',
                            icon: Icons.savings_outlined,
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (provider.ongoing.isNotEmpty) ...[
                        const Text('Sedang Berjalan',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                        ...provider.ongoing.map(
                          (g) => SavingsGoalCard(
                            goal: g,
                            onAddFunds: () => _addFundsDialog(g),
                            onDelete: () => _confirmDelete(g),
                          ),
                        ),
                      ],
                      if (provider.completed.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Selesai',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                        ...provider.completed.map(
                          (g) => SavingsGoalCard(
                            goal: g,
                            onDelete: () => _confirmDelete(g),
                          ),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }
}
