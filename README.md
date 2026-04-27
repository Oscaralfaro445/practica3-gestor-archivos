# practica3_gestor_archivos

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Práctica 3 — Ejercicio 4: Gestor de Archivos Flutter

**ESCOM — Instituto Politécnico Nacional**  
Desarrollo de Aplicaciones Móviles Nativas

## Descripción

Gestor de archivos multiplataforma desarrollado con Flutter.
Permite explorar, visualizar y gestionar archivos del dispositivo
con persistencia local y soporte para iOS y Android.

## Características

- Explorador de archivos con navegación jerárquica
- Breadcrumb para navegación rápida entre carpetas
- Búsqueda en tiempo real dentro de cualquier carpeta
- Íconos y miniaturas por tipo de archivo
- Visor de imágenes con zoom y visor de texto/código
- Sistema de favoritos persistente
- Historial de archivos recientes con tiempo relativo
- Operaciones: renombrar, eliminar, crear carpetas
- Dos temas: Guinda (IPN) y Azul (ESCOM)
- Modo claro y oscuro
- Almacenamiento local con Hive (sin internet)

## Arquitectura

Clean Architecture con tres capas:

- **Presentación**: Screens, Widgets, Providers
- **Dominio**: Entidades (FavoriteModel, RecentModel)
- **Datos**: Repositorios Hive, acceso al sistema de archivos

## Tecnologías

| Paquete              | Propósito                      |
| -------------------- | ------------------------------ |
| `provider`           | Gestión de estado              |
| `hive`               | Almacenamiento local           |
| `path_provider`      | Rutas del sistema de archivos  |
| `open_file`          | Abrir archivos con app externa |
| `permission_handler` | Permisos Android/iOS           |

## Instalación

```bash
git clone https://github.com/TuUsuario/practica3-gestor-archivos.git
cd practica3-gestor-archivos
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## APK

`build/app/outputs/flutter-apk/app-release.apk`
