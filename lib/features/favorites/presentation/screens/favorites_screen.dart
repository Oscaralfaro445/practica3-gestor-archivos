import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../features/favorites/domain/favorite_model.dart';
import '../../../../core/constants/file_types.dart';
import '../../../explorer/presentation/explorer_provider.dart';
import '../../../explorer/presentation/screens/explorer_screen.dart';
import '../../../explorer/presentation/screens/file_viewer_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<FavoriteModel>('favorites').listenable(),
        builder: (context, box, _) {
          final favorites = box.values.toList()
            ..sort((a, b) => b.addedAt.compareTo(a.addedAt));

          if (favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay favoritos todavía',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Toca la estrella en cualquier archivo o carpeta',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final fav = favorites[index];
              final exists = fav.isDirectory
                  ? Directory(fav.path).existsSync()
                  : File(fav.path).existsSync();

              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: FileTypes.getColor(fav.path,
                            isDirectory: fav.isDirectory)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FileTypes.getIcon(fav.path, isDirectory: fav.isDirectory),
                    color: exists
                        ? FileTypes.getColor(fav.path,
                            isDirectory: fav.isDirectory)
                        : Colors.grey,
                    size: 28,
                  ),
                ),
                title: Text(
                  fav.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: exists ? null : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  exists ? fav.path : 'Archivo ya no existe',
                  style: TextStyle(
                    fontSize: 11,
                    color: exists ? Colors.grey : Colors.red,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.star, color: Colors.amber),
                  onPressed: () => _removeFavorite(context, fav),
                ),
                onTap: exists ? () => _openFavorite(context, fav) : null,
              );
            },
          );
        },
      ),
    );
  }

  void _removeFavorite(BuildContext context, FavoriteModel fav) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitar de favoritos'),
        content: Text('¿Quitar "${fav.name}" de favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await fav.delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
  }

  void _openFavorite(BuildContext context, FavoriteModel fav) {
    if (fav.isDirectory) {
      final provider = context.read<ExplorerProvider>();
      provider.navigateTo(Directory(fav.path));
      // Simplemente cierra el bottom sheet si hay alguno abierto
      // El usuario navega manualmente a la pestaña Explorador
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navegando a ${fav.name} — ve a la pestaña Explorador'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FileViewerScreen(file: File(fav.path)),
        ),
      );
    }
  }
}
