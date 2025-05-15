import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // Hiveをインポート
import '../models/project_model.dart';
// import '../models/task_model.dart'; // Projectモデル経由で参照される
import 'add_project_screen.dart';
import 'project_detail_screen.dart';
import '../main.dart'; // projectBoxName をインポートするため

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  // ★★★ 追加: ArchiveScreenからアーカイブ済みリストにアクセスするためのstaticゲッター ★★★
  static List<Project> get archivedProjectsList => _ProjectsScreenState._archivedProjects;
  // ★★★ 追加: ArchiveScreenからStateをリフレッシュさせるための簡易的なstaticメソッド（注意して使用） ★★★
  // static Function? refreshArchiveScreen; // より直接的な更新をしたい場合のコールバック用（今回は使わない）

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Project> _projects = []; // アクティブなプロジェクトリスト (インスタンス変数)

  // ★★★ _archivedProjects を static に変更 ★★★
  static List<Project> _archivedProjects = []; // アーカイブ済みプロジェクトリスト (static変数)

  late Box<Project> _projectBox;

  @override
  void initState() {
    super.initState();
    _projectBox = Hive.box<Project>(projectBoxName);
    _loadProjectsFromHive();

    // ★★★ ArchiveScreenの更新用コールバックを登録するならここ (今回は使わない) ★★★
    // ProjectsScreen.refreshArchiveScreen = () {
    //   if (mounted) { // ArchiveScreenのStateがmountedの場合のみ呼ぶ
    //      // ArchiveScreenのStateのインスタンスを取得してメソッドを呼ぶのは難しい
    //      // ArchiveScreen側でdidChangeDependenciesを使うか、より高度な状態管理が必要
    //   }
    // };
  }

  void _loadProjectsFromHive() {
    final allProjectsFromDb = _projectBox.values.toList();
    if (mounted) {
      setState(() {
        _projects = allProjectsFromDb.where((project) => !project.isArchived).toList();
        // ★ staticな _archivedProjects を更新
        _ProjectsScreenState._archivedProjects = allProjectsFromDb.where((project) => project.isArchived).toList();
      });
    }
  }

  Future<void> _saveProjectToHive(Project project) async {
    await _projectBox.put(project.id, project);
    _loadProjectsFromHive();
  }

  void _addProject(Project project) {
    _saveProjectToHive(project);
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

  void _navigateToProjectDetailScreen(Project project) async {
    final resultFromDetail = await Navigator.push<Project>(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(project: project),
      ),
    );
    if (resultFromDetail != null) {
      _saveProjectToHive(resultFromDetail); // これでHiveが更新され、_loadProjectsFromHiveでリストも更新される
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロジェクト'),
      ),
      body: _projects.isEmpty
          ? const Center(
        child: Text(
          'アクティブなプロジェクトがありません。',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final project = _projects[index];
          return Card(
            key: ValueKey(project.id),
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
                  value: project.progress,
                  strokeWidth: 3.0,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    project.progress == 1.0 ? Colors.greenAccent : Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              onTap: () {
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