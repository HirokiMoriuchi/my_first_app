import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project; // 表示するプロジェクトを受け取る

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late List<Task> _tasks; // プロジェクト内のタスクリストを保持
  final TextEditingController _taskController = TextEditingController(); // タスク追加用

  @override
  void initState() {
    super.initState();
    // 受け取ったプロジェクトのタスクリストのコピーを状態として持つ
    // これにより、この画面内でタスクを変更しても元のプロジェクトオブジェクトに直接影響しない
    // (戻る時に変更後のプロジェクトを渡すことで更新を反映する)
    _tasks = List<Task>.from(widget.project.tasks);
  }

  // タスクの完了状態を切り替える
  void _toggleTaskDone(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
  }

  // 新しいタスクを追加する
  void _addTask(String title) {
    if (title.trim().isEmpty) return; // 空のタスクは追加しない

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      createdAt: DateTime.now(),
    );
    setState(() {
      _tasks.add(newTask);
    });
    _taskController.clear(); // 入力フィールドをクリア
  }

  // 画面を閉じる前に、変更を元のプロジェクトに反映させる準備
  Project _getUpdatedProject() {
    // widget.project (元のプロジェクト) の tasks を現在の _tasks で更新した新しい Project インスタンスを作成
    // もしくは、元の project オブジェクトの tasks プロパティを直接書き換えることもできるが、
    // 不変性を保つ方が推奨される場合もある。ここでは新しいインスタンスを返すアプローチ。
    return Project(
      id: widget.project.id,
      title: widget.project.title, // タイトルはここでは変更しない
      tasks: _tasks, // 更新されたタスクリスト
      createdAt: widget.project.createdAt,
      isArchived: widget.project.isArchived, // アーカイブ状態もここでは変更しない
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope( // Flutter 3.20 以降で推奨される戻るボタンの制御方法
      canPop: false, // 通常の戻る操作を一旦無効化
      onPopInvoked: (didPop) {
        if (didPop) return; // システムによって既にpopされた場合は何もしない
        // 変更されたプロジェクトを返して画面を閉じる
        Navigator.of(context).pop(_getUpdatedProject());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.project.title), // プロジェクトのタイトルを表示
          // leading: IconButton( // PopScope を使う場合は、leadingのカスタマイズがより明確になる
          //   icon: Icon(Icons.arrow_back),
          //   onPressed: () {
          //     Navigator.of(context).pop(_getUpdatedProject());
          //   },
          // ),
        ),
        body: Column(
          children: [
            // タスクリスト表示部分
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                child: Text(
                  'タスクはありません。\n下の入力欄から追加しましょう！',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return CheckboxListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough // 完了なら取り消し線
                            : null,
                        color: task.isDone ? Colors.grey : null, // 完了なら少し薄く
                      ),
                    ),
                    value: task.isDone,
                    onChanged: (bool? value) {
                      _toggleTaskDone(index);
                    },
                    controlAffinity: ListTileControlAffinity.leading, // チェックボックスを左側に
                    activeColor: Theme.of(context).colorScheme.secondary, // チェック時の色
                  );
                },
              ),
            ),
            // タスク追加入力部分
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        hintText: '新しいタスクを入力...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      ),
                      onSubmitted: (value) { // Enterキーで追加
                        _addTask(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _addTask(_taskController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.add, color: Colors.black), // アイコンの色を調整
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}