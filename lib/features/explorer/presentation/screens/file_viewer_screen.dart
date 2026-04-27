import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/constants/file_types.dart';

class FileViewerScreen extends StatelessWidget {
  final File file;
  const FileViewerScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final name = file.path.split('/').last;

    return Scaffold(
      appBar: AppBar(
        title: Text(name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Abrir con...',
            onPressed: () => OpenFile.open(file.path),
          ),
        ],
      ),
      body: _buildViewer(context),
    );
  }

  Widget _buildViewer(BuildContext context) {
    // Visor de imágenes con zoom
    if (FileTypes.isImage(file.path)) {
      return InteractiveViewer(
        child: Center(
          child: Image.file(
            file,
            errorBuilder: (_, __, ___) =>
                const Center(child: Text('No se puede mostrar la imagen')),
          ),
        ),
      );
    }

    // Visor de texto y código
    if (FileTypes.isText(file.path)) {
      return FutureBuilder<String>(
        future: file.readAsString(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No se puede leer el archivo'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => OpenFile.open(file.path),
                    child: const Text('Abrir con app externa'),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              snapshot.data ?? '',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          );
        },
      );
    }

    // Para otros tipos, mostrar info y botón para abrir externamente
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FileTypes.getIcon(file.path),
            size: 80,
            color: FileTypes.getColor(file.path),
          ),
          const SizedBox(height: 24),
          Text(
            file.path.split('/').last,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          FutureBuilder<int>(
            future: file.length(),
            builder: (_, snap) => Text(
              snap.hasData
                  ? FileTypes.formatSize(snap.data!)
                  : 'Calculando tamaño...',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => OpenFile.open(file.path),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir con app externa'),
          ),
        ],
      ),
    );
  }
}
