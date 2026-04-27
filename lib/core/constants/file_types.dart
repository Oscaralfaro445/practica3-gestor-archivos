import 'package:flutter/material.dart';

class FileTypes {
  FileTypes._();

  // Devuelve el ícono correspondiente según la extensión del archivo
  static IconData getIcon(String path, {bool isDirectory = false}) {
    if (isDirectory) return Icons.folder;

    final ext = path.split('.').last.toLowerCase();

    switch (ext) {
      // Imágenes
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
        return Icons.image;

      // Video
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return Icons.video_file;

      // Audio
      case 'mp3':
      case 'aac':
      case 'wav':
      case 'flac':
      case 'm4a':
        return Icons.audio_file;

      // Documentos
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;

      // Texto y código
      case 'txt':
      case 'md':
        return Icons.article;
      case 'dart':
      case 'py':
      case 'js':
      case 'ts':
      case 'java':
      case 'kt':
      case 'swift':
      case 'json':
      case 'xml':
      case 'html':
      case 'css':
        return Icons.code;

      // Comprimidos
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return Icons.folder_zip;

      // APK
      case 'apk':
        return Icons.android;

      default:
        return Icons.insert_drive_file;
    }
  }

  // Devuelve el color del ícono según el tipo
  static Color getColor(String path, {bool isDirectory = false}) {
    if (isDirectory) return const Color(0xFFFFA726); // Naranja para carpetas

    final ext = path.split('.').last.toLowerCase();

    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return const Color(0xFF42A5F5); // Azul para imágenes

      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return const Color(0xFFEF5350); // Rojo para video

      case 'mp3':
      case 'aac':
      case 'wav':
      case 'm4a':
        return const Color(0xFFAB47BC); // Morado para audio

      case 'pdf':
        return const Color(0xFFEF5350); // Rojo para PDF

      case 'doc':
      case 'docx':
        return const Color(0xFF1565C0); // Azul oscuro para Word

      case 'xls':
      case 'xlsx':
        return const Color(0xFF2E7D32); // Verde para Excel

      case 'dart':
      case 'py':
      case 'js':
      case 'json':
      case 'html':
        return const Color(0xFF00ACC1); // Cyan para código

      case 'zip':
      case 'rar':
      case '7z':
        return const Color(0xFF8D6E63); // Café para comprimidos

      default:
        return const Color(0xFF78909C); // Gris para el resto
    }
  }

  // Formatea el tamaño del archivo en formato legible
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Verifica si el archivo es una imagen (para mostrar miniatura)
  static bool isImage(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  // Verifica si el archivo es de texto (para mostrar contenido)
  static bool isText(String path) {
    final ext = path.split('.').last.toLowerCase();
    return [
      'txt',
      'md',
      'dart',
      'py',
      'js',
      'ts',
      'json',
      'xml',
      'html',
      'css',
      'java',
      'kt',
      'swift',
      'yaml',
      'yml',
      'sh',
      'bat'
    ].contains(ext);
  }
}
