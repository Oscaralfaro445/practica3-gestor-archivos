import 'package:hive/hive.dart';

part 'favorite_model.g.dart';

@HiveType(typeId: 0)
class FavoriteModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String path;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final bool isDirectory;

  @HiveField(4)
  final DateTime addedAt;

  FavoriteModel({
    required this.id,
    required this.path,
    required this.name,
    required this.isDirectory,
    required this.addedAt,
  });
}
