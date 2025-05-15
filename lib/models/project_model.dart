import 'package:hive/hive.dart';
import 'task_model.dart';

part 'project_model.g.dart'; // ★ 生成されるファイルを指定

@HiveType(typeId: 0) // ★ HiveTypeアノテーションとユニークなtypeId (Taskとは異なるもの)
class Project extends HiveObject { // ★ HiveObjectを継承
  @HiveField(0) // ★ HiveFieldアノテーションとユニークなインデックス
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<Task> tasks; // Taskのリストも保存可能

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  bool isArchived;

  // ★ Hiveがデフォルトコンストラクタを要求する場合があるため、引数なしコンストラクタも用意 (今回は不要かもしれないが念のため)
  // Project();

  Project({
    required this.id,
    required this.title,
    List<Task>? tasks,
    required this.createdAt,
    this.isArchived = false,
  }) : tasks = tasks ?? [];

  double get progress {
    if (tasks.isEmpty) {
      return 0.0;
    }
    final completedTasks = tasks.where((task) => task.isDone).length;
    return completedTasks / tasks.length;
  }

  int get unfinishedTaskCount {
    return tasks.where((task) => !task.isDone).length;
  }
}