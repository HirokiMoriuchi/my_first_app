import 'task_model.dart'; // 作成したTaskモデルを読み込む

class Project {
  String id;
  String title;
  List<Task> tasks; // Taskのリストを持つ
  DateTime createdAt;
  bool isArchived;

  Project({
    required this.id,
    required this.title,
    List<Task>? tasks, // ? をつけて、null許容にする
    required this.createdAt,
    this.isArchived = false, // デフォルトはアーカイブされていない
  }) : tasks = tasks ?? []; // tasksがnullなら空のリストを代入

  // タスクの進捗を計算するヘルパーメソッド (例)
  double get progress {
    if (tasks.isEmpty) {
      return 0.0;
    }
    final completedTasks = tasks.where((task) => task.isDone).length;
    return completedTasks / tasks.length;
  }

  // 未完了のタスク数を取得するヘルパーメソッド
  int get unfinishedTaskCount {
    return tasks.where((task) => !task.isDone).length;
  }
}