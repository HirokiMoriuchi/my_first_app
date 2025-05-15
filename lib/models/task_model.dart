class Task {
  String id;
  String title;
  bool isDone;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.isDone = false, // デフォルトは未完了
    required this.createdAt,
  });
}