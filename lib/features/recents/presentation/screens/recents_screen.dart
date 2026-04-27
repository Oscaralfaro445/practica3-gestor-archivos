import 'package:flutter/material.dart';

class RecentsScreen extends StatelessWidget {
  const RecentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recientes')),
      body: const Center(child: Text('Recientes — Sección 2')),
    );
  }
}
