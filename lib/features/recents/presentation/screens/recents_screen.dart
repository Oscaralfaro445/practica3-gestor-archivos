import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../features/recents/domain/recent_model.dart';
import '../../../../core/constants/file_types.dart';
import '../../../explorer/presentation/screens/file_viewer_screen.dart';

class RecentsScreen extends StatelessWidget {
  const RecentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Limpiar historial',
            onPressed: () => _clearAll(context),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<RecentModel>('recents').listenable(),
        builder: (context, box, _) {
          final recents = box.values.toList()
            ..sort((a, b) => b.openedAt.compareTo(a.openedAt));

          if (recents.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Sin archivos recientes',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Los archivos que abras aparecerán aquí',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: recents.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final recent = recents[index];
              final exists = File(recent.path).existsSync();
              final timeStr = _formatTime(recent.openedAt);

              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: FileTypes.getColor(recent.path).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FileTypes.getIcon(recent.path),
                    color:
                        exists ? FileTypes.getColor(recent.path) : Colors.grey,
                    size: 28,
                  ),
                ),
                title: Text(
                  recent.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: exists ? null : Colors.grey,
                  ),
                ),
                subtitle: Text(
                  timeStr,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () async => await recent.delete(),
                ),
                onTap: exists
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FileViewerScreen(file: File(recent.path)),
                          ),
                        )
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  void _clearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text('¿Borrar todo el historial de archivos recientes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final box = Hive.box<RecentModel>('recents');
              await box.clear();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}
