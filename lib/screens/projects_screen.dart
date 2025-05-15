import 'package:flutter/material.dart';
import '../models/project_model.dart';
// import '../models/task_model.dart'; // 必要に応じて
import 'add_project_screen.dart';
import 'project_detail_screen.dart'; // ★ 追加: 詳細画面をインポート

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Project> _projects = [ /* ... existing dummy data ... */ ];

  void _addProject(Project project) {
    setState(() {
      _projects.insert(0, project);
    });
  }

  void _navigateToAddTaskScreen() async {
    final newProject = await Navigator.push<Project>(
      context,
      MaterialPageRoute(builder: (context) => const AddProjectScreen()),
    );
    if (newProject != null) {
      _addProject(newProject);
    }
  }

  // ★ 追加: プロジェクト詳細画面に遷移し、結果を受け取るメソッド
  void _navigateToProjectDetailScreen(Project project) async {
    final updatedProject = await Navigator.push<Project>(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(project: project),
      ),
    );

    if (updatedProject != null) {
      setState(() {
        // リスト内で該当するプロジェクトを見つけて更新する
        final index = _projects.indexWhere((p) => p.id == updatedProject.id);
        if (index != -1) {
          _projects[index] = updatedProject;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeProjects = _projects.where((p) => !p.isArchived).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロジェクト'),
      ),
      body: activeProjects.isEmpty
          ? const Center(
              child: Text(
                'プロジェクトがありません。\n右下のボタンから作成しましょう！',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
        itemCount: activeProjects.length,
        itemBuilder: (context, index) {
          final project = activeProjects[index];
          return Card(
            child: ListTile(
              title: Text(
                project.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: project.tasks.isEmpty
                  ? const Text('タスクなし')
                  : Text(
                '未完了 ${project.unfinishedTaskCount}件 / 全 ${project.tasks.length}件',
                style: TextStyle(color: Colors.grey[400]),
              ),
              trailing: project.tasks.isEmpty
                  ? null
                  : SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  value: project.progress, // ★ ここで進捗が更新される
                  strokeWidth: 3.0,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    project.progress == 1.0 ? Colors.greenAccent : Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              onTap: () { // ★ 変更: 詳細画面へ遷移
                _navigateToProjectDetailScreen(project);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTaskScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}