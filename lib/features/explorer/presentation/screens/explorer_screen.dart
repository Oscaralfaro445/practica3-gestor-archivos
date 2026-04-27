import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/constants/file_types.dart';
import '../explorer_provider.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/file_item_tile.dart';
import 'file_viewer_screen.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  void _showCreateFolderDialog(
      BuildContext context, ExplorerProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva carpeta'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre de la carpeta',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final ok = await provider.createFolder(name);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(ok ? 'Carpeta creada' : 'Error al crear carpeta'),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExplorerProvider>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExplorerProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return PopScope(
      canPop: !provider.canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && provider.canGoBack) {
          provider.goBack();
        }
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateFolderDialog(context, provider),
          tooltip: 'Nueva carpeta',
          child: const Icon(Icons.create_new_folder_outlined),
        ),
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    hintText: 'Buscar archivos...',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  onChanged: (q) => provider.search(q),
                )
              : const Text('Explorador'),
          leading: provider.canGoBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => provider.goBack(),
                )
              : null,
          actions: [
            // Búsqueda
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    provider.search('');
                  }
                });
              },
            ),
            // Ordenamiento
            PopupMenuButton<SortMode>(
              icon: const Icon(Icons.sort),
              onSelected: (mode) => provider.setSortMode(mode),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: SortMode.nameAsc,
                  child: Text('Nombre A-Z'),
                ),
                const PopupMenuItem(
                  value: SortMode.nameDesc,
                  child: Text('Nombre Z-A'),
                ),
                const PopupMenuItem(
                  value: SortMode.sizeDesc,
                  child: Text('Mayor tamaño'),
                ),
                const PopupMenuItem(
                  value: SortMode.dateDesc,
                  child: Text('Más reciente'),
                ),
              ],
            ),
            // Tema
            PopupMenuButton<AppThemeMode>(
              icon: const Icon(Icons.palette),
              onSelected: (mode) => themeProvider.setTheme(mode),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: AppThemeMode.guinda,
                  child: Row(children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6D1130),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Guinda — IPN'),
                  ]),
                ),
                PopupMenuItem(
                  value: AppThemeMode.azul,
                  child: Row(children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF003B8E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Azul — ESCOM'),
                  ]),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: BreadcrumbBar(
              stack: provider.navigationStack,
              onTap: (index) => provider.navigateToStackIndex(index),
            ),
          ),
        ),
        body: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(ExplorerProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(provider.errorMessage!,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.init();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Carpeta vacía', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.separated(
        itemCount: provider.items.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final entity = provider.items[index];
          final isDir = entity is Directory;

          return FileItemTile(
            entity: entity,
            isFavorite: provider.isFavorite(entity.path),
            onFavoriteToggle: () => provider.toggleFavorite(entity),
            onLongPress: () => _showContextMenu(context, entity, provider),
            onTap: () async {
              if (isDir) {
                await provider.navigateTo(entity as Directory);
              } else {
                await provider.addToRecents(entity);
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FileViewerScreen(file: entity as File),
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }

  void _showContextMenu(
    BuildContext context,
    FileSystemEntity entity,
    ExplorerProvider provider,
  ) {
    final name = entity.path.split('/').last;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado
            ListTile(
              leading: Icon(
                FileTypes.getIcon(entity.path,
                    isDirectory: entity is Directory),
                color: FileTypes.getColor(entity.path,
                    isDirectory: entity is Directory),
              ),
              title: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(entity.path,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis),
            ),
            const Divider(height: 1),

            // Favorito
            ListTile(
              leading: Icon(
                provider.isFavorite(entity.path)
                    ? Icons.star
                    : Icons.star_outline,
                color: provider.isFavorite(entity.path) ? Colors.amber : null,
              ),
              title: Text(provider.isFavorite(entity.path)
                  ? 'Quitar de favoritos'
                  : 'Agregar a favoritos'),
              onTap: () {
                provider.toggleFavorite(entity);
                Navigator.pop(ctx);
              },
            ),

            // Renombrar
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('Renombrar'),
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog(context, entity, provider);
              },
            ),

            // Eliminar
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteDialog(context, entity, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    FileSystemEntity entity,
    ExplorerProvider provider,
  ) {
    final name = entity.path.split('/').last;
    final controller = TextEditingController(text: name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renombrar'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nuevo nombre',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == name) {
                Navigator.pop(ctx);
                return;
              }
              final ok = await provider.renameEntity(entity, newName);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        ok ? 'Renombrado correctamente' : 'Error al renombrar'),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Renombrar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    FileSystemEntity entity,
    ExplorerProvider provider,
  ) {
    final name = entity.path.split('/').last;
    final isDir = entity is Directory;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text(
          isDir
              ? '¿Eliminar la carpeta "$name" y todo su contenido?'
              : '¿Eliminar el archivo "$name"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final ok = await provider.deleteEntity(entity);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        ok ? 'Eliminado correctamente' : 'Error al eliminar'),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
