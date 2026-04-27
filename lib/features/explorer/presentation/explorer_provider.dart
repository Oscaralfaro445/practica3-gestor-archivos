import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../favorites/domain/favorite_model.dart';
import '../../recents/domain/recent_model.dart';

class ExplorerProvider extends ChangeNotifier {
  final List<Directory> _navigationStack = [];
  List<FileSystemEntity> _currentItems = [];
  List<FileSystemEntity> _filteredItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  SortMode _sortMode = SortMode.nameAsc;
  bool _showHidden = false;

  Directory? get currentDirectory =>
      _navigationStack.isEmpty ? null : _navigationStack.last;
  List<FileSystemEntity> get items => _filteredItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canGoBack => _navigationStack.length > 1;
  List<Directory> get navigationStack => _navigationStack;
  SortMode get sortMode => _sortMode;
  bool get showHidden => _showHidden;

  Future<void> init() async {
    try {
      // Intentar almacenamiento externo primero
      final external = await getExternalStorageDirectory();
      if (external != null) {
        // Subir dos niveles para llegar a /storage/emulated/0
        final root = external.parent.parent.parent.parent;
        await navigateTo(root);
        return;
      }
      // Fallback al directorio interno
      final appDir = await getApplicationDocumentsDirectory();
      await navigateTo(appDir);
    } catch (e) {
      final appDir = await getApplicationDocumentsDirectory();
      await navigateTo(appDir);
    }
  }

  Future<void> navigateTo(Directory directory) async {
    _isLoading = true;
    _searchQuery = '';
    notifyListeners();

    try {
      final items = directory.listSync(followLinks: false);
      _currentItems = _sortItems(items);
      _navigationStack.add(directory);
      _applyFilter();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'No se puede acceder a esta carpeta';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> goBack() async {
    if (!canGoBack) return;
    _navigationStack.removeLast();
    _isLoading = true;
    _searchQuery = '';
    notifyListeners();

    try {
      final items = _navigationStack.last.listSync(followLinks: false);
      _currentItems = _sortItems(items);
      _applyFilter();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error al retroceder';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> navigateToStackIndex(int index) async {
    while (_navigationStack.length > index + 1) {
      _navigationStack.removeLast();
    }
    _isLoading = true;
    _searchQuery = '';
    notifyListeners();

    try {
      final items = _navigationStack.last.listSync(followLinks: false);
      _currentItems = _sortItems(items);
      _applyFilter();
    } catch (e) {
      _errorMessage = 'Error de navegación';
    }

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    _filteredItems = _currentItems.where((item) {
      final name = item.path.split('/').last;
      if (!_showHidden && name.startsWith('.')) return false;
      if (_searchQuery.isEmpty) return true;
      return name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void setSortMode(SortMode mode) {
    _sortMode = mode;
    _currentItems = _sortItems(_currentItems);
    _applyFilter();
    notifyListeners();
  }

  void toggleHidden() {
    _showHidden = !_showHidden;
    _applyFilter();
    notifyListeners();
  }

  List<FileSystemEntity> _sortItems(List<FileSystemEntity> items) {
    final dirs = items.whereType<Directory>().toList();
    final files = items.whereType<File>().toList();

    switch (_sortMode) {
      case SortMode.nameAsc:
        dirs.sort((a, b) => a.path
            .split('/')
            .last
            .toLowerCase()
            .compareTo(b.path.split('/').last.toLowerCase()));
        files.sort((a, b) => a.path
            .split('/')
            .last
            .toLowerCase()
            .compareTo(b.path.split('/').last.toLowerCase()));
      case SortMode.nameDesc:
        dirs.sort((a, b) => b.path
            .split('/')
            .last
            .toLowerCase()
            .compareTo(a.path.split('/').last.toLowerCase()));
        files.sort((a, b) => b.path
            .split('/')
            .last
            .toLowerCase()
            .compareTo(a.path.split('/').last.toLowerCase()));
      case SortMode.sizeDesc:
        files.sort((a, b) =>
            (b as File).lengthSync().compareTo((a as File).lengthSync()));
      case SortMode.dateDesc:
        files.sort((a, b) => (b as File)
            .lastModifiedSync()
            .compareTo((a as File).lastModifiedSync()));
    }
    return [...dirs, ...files];
  }

  // ── Favoritos — usa Box<FavoriteModel> con tipo explícito ──

  bool isFavorite(String path) {
    final box = Hive.box<FavoriteModel>('favorites');
    return box.values.any((v) => v.path == path);
  }

  Future<void> toggleFavorite(FileSystemEntity entity) async {
    final box = Hive.box<FavoriteModel>('favorites');
    final name = entity.path.split('/').last;
    final isDir = entity is Directory;

    final existing = box.values.where((f) => f.path == entity.path).toList();

    if (existing.isNotEmpty) {
      await existing.first.delete();
    } else {
      final fav = FavoriteModel(
        id: const Uuid().v4(),
        path: entity.path,
        name: name,
        isDirectory: isDir,
        addedAt: DateTime.now(),
      );
      await box.put(fav.id, fav);
    }
    notifyListeners();
  }

  // ── Recientes — usa Box<RecentModel> con tipo explícito ────

  Future<void> addToRecents(FileSystemEntity entity) async {
    final box = Hive.box<RecentModel>('recents');
    final name = entity.path.split('/').last;

    final existing = box.values.where((r) => r.path == entity.path).toList();
    for (final r in existing) {
      await r.delete();
    }

    final recent = RecentModel(
      id: const Uuid().v4(),
      path: entity.path,
      name: name,
      openedAt: DateTime.now(),
    );
    await box.put(recent.id, recent);

    final all = box.values.toList()
      ..sort((a, b) => b.openedAt.compareTo(a.openedAt));
    if (all.length > 50) {
      for (final old in all.skip(50)) {
        await old.delete();
      }
    }
  }

  Future<void> refresh() async {
    if (currentDirectory == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final items = currentDirectory!.listSync(followLinks: false);
      _currentItems = _sortItems(items);
      _applyFilter();
    } catch (e) {
      _errorMessage = 'Error al recargar';
    }

    _isLoading = false;
    notifyListeners();
  }

// ── Operaciones de archivos ────────────────────────────────

  Future<bool> renameEntity(FileSystemEntity entity, String newName) async {
    try {
      final parentPath = entity.parent.path;
      final newPath = '$parentPath/$newName';

      if (entity is File) {
        await entity.rename(newPath);
      } else if (entity is Directory) {
        await entity.rename(newPath);
      }

      await refresh();
      return true;
    } catch (e) {
      _errorMessage = 'Error al renombrar: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEntity(FileSystemEntity entity) async {
    try {
      if (entity is File) {
        await entity.delete();
      } else if (entity is Directory) {
        await entity.delete(recursive: true);
      }
      await refresh();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> copyEntity(FileSystemEntity entity, String destPath) async {
    try {
      final name = entity.path.split('/').last;
      if (entity is File) {
        await entity.copy('$destPath/$name');
      }
      await refresh();
      return true;
    } catch (e) {
      _errorMessage = 'Error al copiar: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createFolder(String name) async {
    if (currentDirectory == null) return false;
    try {
      // Verificar que estamos en un directorio donde tenemos acceso
      final newDir = Directory('${currentDirectory!.path}/$name');
      await newDir.create();
      await refresh();
      return true;
    } catch (e) {
      // Si falla por permisos, crear en el directorio interno de la app
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final newDir = Directory('${appDir.path}/$name');
        await newDir.create();
        _errorMessage =
            'Carpeta creada en almacenamiento interno (sin permisos en esta ubicación)';
        notifyListeners();
        return true;
      } catch (e2) {
        _errorMessage = 'Error al crear carpeta: $e2';
        notifyListeners();
        return false;
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

enum SortMode { nameAsc, nameDesc, sizeDesc, dateDesc }
