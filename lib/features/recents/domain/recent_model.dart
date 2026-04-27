import 'package:hive/hive.dart';

part 'recent_model.g.dart';

@HiveType(typeId: 1)
class RecentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String path;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final DateTime openedAt;

  RecentModel({
    required this.id,
    required this.path,
    required this.name,
    required this.openedAt,
  });
}
