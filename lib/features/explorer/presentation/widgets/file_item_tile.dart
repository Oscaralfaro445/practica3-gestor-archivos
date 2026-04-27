import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/file_types.dart';

class FileItemTile extends StatelessWidget {
  final FileSystemEntity entity;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onLongPress;

  const FileItemTile({
    super.key,
    required this.entity,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDir = entity is Directory;
    final name = entity.path.split('/').last;
    final icon = FileTypes.getIcon(entity.path, isDirectory: isDir);
    final color = FileTypes.getColor(entity.path, isDirectory: isDir);

    String subtitle = '';
    if (!isDir) {
      try {
        final file = entity as File;
        final size = FileTypes.formatSize(file.lengthSync());
        final date = DateFormat('dd/MM/yyyy').format(file.lastModifiedSync());
        subtitle = '$size  ·  $date';
      } catch (_) {
        subtitle = 'Archivo';
      }
    } else {
      subtitle = 'Carpeta';
    }

    // Miniatura para imágenes
    Widget leading;
    if (!isDir && FileTypes.isImage(entity.path)) {
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(entity.path),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _iconWidget(icon, color),
        ),
      );
    } else {
      leading = _iconWidget(icon, color);
    }

    return ListTile(
      leading: leading,
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_outline,
          color: isFavorite ? Colors.amber : Colors.grey,
          size: 20,
        ),
        onPressed: onFavoriteToggle,
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget _iconWidget(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
