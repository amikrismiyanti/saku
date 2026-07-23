import 'package:flutter/material.dart';

/// Placeholder — akan diisi lengkap di tahap pengerjaan berikutnya.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalender')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Halaman "Kalender" akan dibangun di tahap berikutnya sesuai roadmap.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
