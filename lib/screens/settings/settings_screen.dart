import 'package:flutter/material.dart';

/// Placeholder — akan diisi lengkap di tahap pengerjaan berikutnya.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Halaman "Pengaturan" akan dibangun di tahap berikutnya sesuai roadmap.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
