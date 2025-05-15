import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // ★ hive_flutterをインポート
import 'models/project_model.dart'; // ★ Projectモデルをインポート
import 'models/task_model.dart';   // ★ Taskモデルをインポート
import 'screens/projects_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/settings_screen.dart';

// HiveのBox名
const String projectBoxName = "projects";

Future<void> main() async { // ★ async であることを確認
  // Flutterエンジンとウィジェットツリーのバインディングを初期化
  // これがないと、runAppより前のFlutterフレームワーク機能呼び出しでエラーになることがある
  WidgetsFlutterBinding.ensureInitialized();

  // Hiveの初期化 (プラットフォームに応じたパスを指定)
  await Hive.initFlutter();

  // アダプターの登録
  // これらを登録し忘れると、Boxを開くときやオブジェクトを読み書きするときにエラーになる
  if (!Hive.isAdapterRegistered(0)) { // typeId: 0 (Project)
    Hive.registerAdapter(ProjectAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) { // typeId: 1 (Task)
    Hive.registerAdapter(TaskAdapter());
  }

  // Boxを開く
  // この処理も非同期なので、完了を待つ
  try {
    await Hive.openBox<Project>(projectBoxName);
  } catch (e) {
    print('Failed to open Hive box: $e');
    // ここでエラーが発生した場合、アプリが正常に起動できない可能性がある
    // 開発中は、例えばBoxファイルを削除してみるなどの対応が必要な場合もある
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1F1F1F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF2C2C2C),
          selectedItemColor: Colors.tealAccent,
          unselectedItemColor: Colors.grey,
        ),
        colorScheme: ThemeData.dark().colorScheme.copyWith(
          secondary: Colors.tealAccent[400],
          brightness: Brightness.dark,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF2C2C2C),
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.tealAccent[400],
          foregroundColor: Colors.black,
        ),
      ),
      home: const MyHomePage(),
      // ★ アプリ終了時にHiveのBoxを閉じる (任意だが推奨)
      // これはMaterialAppのdisposeでは直接行えないため、
      // WidgetsBindingObserver を使うか、
      // main関数の最後に Hive.close() を呼ぶ (ただしアプリが即座に終了する場合のみ有効)
      // 今回は一旦省略し、問題が解決してから検討
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions(BuildContext context) => <Widget>[
    const ProjectsScreen(),
    const ArchiveScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ★ アプリ終了時にHiveのBoxを閉じる (より確実な方法)
  // @override
  // void dispose() {
  //   Hive.close(); // 全ての開いているBoxを閉じる
  //   super.dispose();
  // }
  // ただし、MyHomePageが常にアプリのルートウィジェットとは限らないため、
  // WidgetsBindingObserver を使うのがより堅牢です。

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions(context).elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'プロジェクト',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            label: 'アーカイブ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: '設定',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}