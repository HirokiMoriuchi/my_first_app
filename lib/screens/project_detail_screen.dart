import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late String _projectTitle;
  late List<Task> _tasks;
  late List<TextEditingController> _taskTextControllers;
  late List<FocusNode> _taskFocusNodes;

  @override
  void initState() {
    super.initState();
    _projectTitle = widget.project.title;
    // widget.project.tasks のディープコピーを作成
    _tasks = widget.project.tasks.map((task) => Task(
        id: task.id,
        title: task.title,
        isDone: task.isDone,
        createdAt: task.createdAt
    )).toList();


    _taskTextControllers = [];
    _taskFocusNodes = [];

    if (_tasks.isEmpty) {
      _addEmptyTaskToList(requestFocus: true);
    } else {
      for (var task in _tasks) {
        final controller = TextEditingController(text: task.title);
        final focusNode = FocusNode();
        _taskTextControllers.add(controller);
        _taskFocusNodes.add(focusNode);
        _addFocusListener(focusNode, controller, task.id);
      }
    }
  }

  void _addFocusListener(FocusNode focusNode, TextEditingController controller, String taskId) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus && mounted) {
        final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
        if (taskIndex != -1) {
          final newTitle = controller.text.trim();
          // タイトルが実際に変更された場合のみsetStateを呼ぶ
          if (_tasks[taskIndex].title != newTitle) {
            setState(() {
              _tasks[taskIndex].title = newTitle;
            });
          }
          // フォーカスが外れたときに空のタスクを削除するロジック（最後の1つは除く）
          if (newTitle.isEmpty && _tasks.length > 1) {
            // 少し遅延させて削除（他の操作と競合しないように）
            Future.delayed(Duration.zero, () {
              if(mounted) _deleteTaskAt(taskIndex, moveFocus: false);
            });
          }
        }
      }
    });
  }

  void _addEmptyTaskToList({String initialText = '', bool requestFocus = false, int? insertAtIndex}) {
    final newTaskId = DateTime.now().millisecondsSinceEpoch.toString();
    final newTask = Task(
      id: newTaskId,
      title: initialText.trim(),
      createdAt: DateTime.now(),
    );
    final newController = TextEditingController(text: newTask.title);
    final newFocusNode = FocusNode();

    _addFocusListener(newFocusNode, newController, newTaskId);

    if (mounted) {
      setState(() {
        if (insertAtIndex != null && insertAtIndex <= _tasks.length) { // <= に変更
          _tasks.insert(insertAtIndex, newTask);
          _taskTextControllers.insert(insertAtIndex, newController);
          _taskFocusNodes.insert(insertAtIndex, newFocusNode);
        } else {
          _tasks.add(newTask);
          _taskTextControllers.add(newController);
          _taskFocusNodes.add(newFocusNode);
        }
      });

      if (requestFocus) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            newFocusNode.requestFocus();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _taskTextControllers) {
      controller.dispose();
    }
    for (var focusNode in _taskFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _toggleTaskDone(int index) {
    if (mounted && index < _tasks.length) {
      setState(() {
        _tasks[index].isDone = !_tasks[index].isDone;
      });
      _checkAndPromptArchive();
    }
  }

  void _insertNewTaskAt(int index, {String initialText = ''}) {
    _addEmptyTaskToList(initialText: initialText, requestFocus: true, insertAtIndex: index);
    // _checkAndPromptArchive(); // 新しいタスク追加時は通常未完了なので、アーカイブチェックは不要か、あるいは条件付きで
  }

  void _deleteTaskAt(int index, {bool moveFocus = true}) {
    if (mounted && index < _tasks.length) {
      // フォーカスを安全な場所に移す
      if (moveFocus && _taskFocusNodes.isNotEmpty && index < _taskFocusNodes.length && _taskFocusNodes[index].hasFocus) {
        if (index > 0 && index -1 < _taskFocusNodes.length) {
          _taskFocusNodes[index - 1].requestFocus();
        } else if (_tasks.length > 1 && index + 1 < _taskFocusNodes.length) {
          _taskFocusNodes[index + 1].requestFocus();
        }
      }

      // 削除前にコントローラーとフォーカスノードを破棄
      _taskTextControllers[index].dispose();
      _taskFocusNodes[index].dispose();

      setState(() {
        _tasks.removeAt(index);
        _taskTextControllers.removeAt(index);
        _taskFocusNodes.removeAt(index);

        if (_tasks.isEmpty) {
          _addEmptyTaskToList(requestFocus: true);
        }
      });
      _checkAndPromptArchive();
    }
  }

  Project _getUpdatedProject({bool archiving = false}) {
    List<Task> finalTasks = [];
    for (int i = 0; i < _tasks.length; i++) {
      if (i < _taskTextControllers.length) {
        final currentText = _taskTextControllers[i].text.replaceAll(RegExp(r'\n+$'), '').trim();
        // 最後の1タスクで、かつそれが空の場合でも、isDoneの状態は保持したいので、タイトルが空でも追加。
        // ただし、完全に不要ならここでフィルタリングする。
        // ここでは、UI上存在するものは（タイトルが空でも）一旦そのまま返す方針。
        // 保存時に最終的に空タスクをどう扱うかは永続化の層で決めても良い。
        _tasks[i].title = currentText;
        finalTasks.add(_tasks[i]);

      }
    }
    return Project(
      id: widget.project.id,
      title: _projectTitle,
      tasks: finalTasks,
      createdAt: widget.project.createdAt,
      isArchived: archiving || widget.project.isArchived, // アーカイブ実行時または既存のアーカイブ状態
    );
  }

  void _checkAndPromptArchive() {
    if (!mounted || _tasks.isEmpty) return;

    bool allTasksDone = _tasks.every((task) => task.isDone);

    if (allTasksDone) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _showArchiveDialog();
        }
      });
    }
  }

  void _showArchiveDialog() {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('プロジェクト完了！'),
          content: const Text('全てのタスクが完了しました。\nこのプロジェクトをアーカイブしますか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('いいえ'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
                if (mounted) {
                  bool focusedOnEmptyTask = false;
                  if (_tasks.isNotEmpty) {
                    for (int i = 0; i < _tasks.length; i++) {
                      if (i < _taskTextControllers.length && _taskTextControllers[i].text.trim().isEmpty) {
                        if (i < _taskFocusNodes.length) _taskFocusNodes[i].requestFocus();
                        focusedOnEmptyTask = true;
                        break;
                      }
                    }
                  }
                  if (!focusedOnEmptyTask) {
                    _insertNewTaskAt(_tasks.length);
                  }
                }
              },
            ),
            TextButton(
              child: const Text('はい、アーカイブする'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
                // _archiveProject(); // _archiveProjectはここで呼ばず、pop(true)の結果で処理する
              },
            ),
          ],
        );
      },
    ).then((confirmArchive) { // ダイアログが閉じた後の処理
      if (confirmArchive == true) {
        _archiveProjectAndPop();
      }
    });
  }

  void _archiveProjectAndPop() {
    if (mounted) {
      // _getUpdatedProjectを呼び出す際にarchivingをtrueにして、アーカイブ状態のプロジェクトを取得
      final projectToArchive = _getUpdatedProject(archiving: true);
      Navigator.of(context).pop(projectToArchive);
    }
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // 通常の戻る操作では、アーカイブせずに現在の状態でプロジェクトを返す
        Navigator.of(context).pop(_getUpdatedProject(archiving: false));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_projectTitle),
        ),
        body: Column(
          children: [
            Expanded(
              child: ReorderableListView.builder( // タスクの並び替えを可能にする (オプション)
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  // Keyの指定がReorderableListViewには必須
                  // ValueKey以外にもObjectKey(task)なども使える
                  final taskKey = ValueKey(_tasks[index].id + _tasks[index].title); // Keyはタスクごとに一意に

                  if (index >= _tasks.length || index >= _taskTextControllers.length || index >= _taskFocusNodes.length) {
                    return SizedBox.shrink(key: ValueKey('empty_shrink_$index'));
                  }
                  final task = _tasks[index];
                  final controller = _taskTextControllers[index];

                  return ListTile( // ReorderableListViewの子は通常ListTileなどが使われる
                    key: taskKey,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (bool? value) {
                        _toggleTaskDone(index);
                      },
                      activeColor: Theme.of(context).colorScheme.secondary,
                    ),
                    title: TextField(
                      controller: controller,
                      focusNode: _taskFocusNodes[index],
                      decoration: InputDecoration(
                        hintText: 'タスクを入力...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                      ),
                      style: TextStyle(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isDone ? Colors.grey[600] : Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16,
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      onChanged: (text) {
                        if (text.endsWith('\n')) {
                          final currentLineText = text.substring(0, text.length - 1);
                          controller.text = currentLineText;
                          if (mounted && index < _tasks.length) {
                            _tasks[index].title = currentLineText.trim(); // setStateは不要、フォーカスアウトで更新
                          }
                          controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: controller.text.length),
                          );
                          _insertNewTaskAt(index + 1);
                        }
                      },
                      onSubmitted: (value){
                        // 通常のEnter（改行）はonChangedで処理されるので、
                        // onSubmittedはソフトウェアキーボードの「完了」アクションなどで呼ばれる。
                        // ここでは現在の行の値を確定し、もし次の行がなければ新しい行を追加する。
                        if (mounted && index < _tasks.length) {
                          _tasks[index].title = value.trim();
                          controller.text = value.trim();
                        }
                        if (index == _tasks.length - 1) { // 最後のタスクで完了した場合
                          _insertNewTaskAt(index + 1);
                        } else if (index + 1 < _taskFocusNodes.length) {
                          _taskFocusNodes[index + 1].requestFocus();
                        }
                      },
                    ),
                    trailing: IconButton( // ReorderableListViewのデフォルトのドラッグハンドルと競合しないように注意
                      icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
                      onPressed: () {
                        _deleteTaskAt(index);
                      },
                    ),
                  );
                },
                onReorder: (oldIndex, newIndex) { // 並び替え処理
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final Task item = _tasks.removeAt(oldIndex);
                    _tasks.insert(newIndex, item);

                    final TextEditingController controllerItem = _taskTextControllers.removeAt(oldIndex);
                    _taskTextControllers.insert(newIndex, controllerItem);

                    final FocusNode focusNodeItem = _taskFocusNodes.removeAt(oldIndex);
                    _taskFocusNodes.insert(newIndex, focusNodeItem);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}