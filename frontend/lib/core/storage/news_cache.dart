import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class CachedNewsArticle extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final DateTime publishedAt;

  CachedNewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.publishedAt,
  });
}
