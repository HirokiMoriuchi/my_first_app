import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // ★ Hiveをインポート
import '../models/project_model.dart';
import '../main.dart'; // ★ projectBoxName をインポートするため
// import 'projects_screen.dart'; // ProjectsScreenのstaticメンバーへの依存をなくす

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<Project> _archivedProjects = []; // この画面で表示するアーカイブ済みプロジェクトのリスト
  late Box<Project> _projectBox; // ★ HiveのBoxを保持する変数

  @override
  void initState() {
    super.initState();
    _projectBox = Hive.box<Project>(projectBoxName); // ★ main.dartで開いたBoxを取得
    _loadArchivedProjectsFromHive();

    // ★ Boxの変更を監視してUIを自動更新する (よりリアクティブな方法)
    _projectBox.watch().listen((event) {
      // Boxに変更があった場合（追加、更新、削除）にリストを再ロード
      _loadArchivedProjectsFromHive();
    });
  }

  void _loadArchivedProjectsFromHive() {
    if (!mounted) return; // mountedチェック

    final allProjectsFromDb = _projectBox.values.toList();
    setState(() {
      _archivedProjects = allProjectsFromDb.where((project) => project.isArchived).toList();
      // 必要であればソート
      // _archivedProjects.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 例: 新しい順
    });
  }

  // プロジェクトをアクティブに戻す（アンアーカイブする）
  Future<void> _unarchiveProject(Project projectToUnarchive) async {
    if (!mounted) return;

    // isArchivedフラグをfalseに更新してHiveに保存
    projectToUnarchive.isArchived = false;
    await _projectBox.put(projectToUnarchive.id, projectToUnarchive);

    // _loadArchivedProjectsFromHive(); // watch()を使っていれば自動で再ロードされるが、即時反映のため呼んでも良い
    // もしくは、メモリ上のリストからも直接削除してUIを即時更新
    setState(() {
      _archivedProjects.removeWhere((p) => p.id == projectToUnarchive.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('「${projectToUnarchive.title}」をプロジェクトリストに戻しました。')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アーカイブ済みプロジェクト'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'リストを更新',
            onPressed: _loadArchivedProjectsFromHive, // 手動リフレッシュ
          ),
        ],
      ),
      body: _archivedProjects.isEmpty
          ? const Center(
        child: Text(
          'アーカイブされたプロジェクトはありません。',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: _archivedProjects.length,
        itemBuilder: (context, index) {
          final project = _archivedProjects[index];
          return Card(
            key: ValueKey(project.id),
            child: ListTile(
              title: Text(
                project.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey[700],
                ),
              ),
              subtitle: Text(
                'タスク数: ${project.tasks.length} - ${project.createdAt.toLocal().toString().substring(0, 10)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              onTap: () {
                // ここで詳細画面に遷移させることもできる（読み取り専用モードなど）
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ProjectDetailScreen(project: project, isReadOnly: true), // 仮のパラメータ
                //   ),
                // );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${project.title} の詳細表示 (未実装)')),
                );
              },
              trailing: IconButton(
                icon: Icon(Icons.unarchive_outlined, color: Colors.grey[600]),
                tooltip: 'プロジェクトを戻す',
                onPressed: () {
                  _unarchiveProject(project);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}