import 'package:hive/hive.dart';

part 'task_model.g.dart'; // ★ 生成されるファイルを指定

@HiveType(typeId: 1) // ★ HiveTypeアノテーションとユニークなtypeId
class Task extends HiveObject { // ★ HiveObjectを継承
  @HiveField(0) // ★ HiveFieldアノテーションとユニークなインデックス
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isDone;

  @HiveField(3)
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.createdAt,
  });
}