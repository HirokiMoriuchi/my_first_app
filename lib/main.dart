import 'package:flutter/material.dart';
import 'screens/projects_screen.dart'; // 作成したファイルを読み込む
import 'screens/archive_screen.dart';  // 作成したファイルを読み込む
import 'screens/settings_screen.dart'; // 作成したファイルを読み込む

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App', // アプリのタイトルを変更
      theme: ThemeData.dark().copyWith( // ダークテーマをベースにカスタマイズ
        scaffoldBackgroundColor: const Color(0xFF1F1F1F), // 背景色を少し調整 (真っ黒よりは濃いグレー)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2C), // AppBarの背景色
          foregroundColor: Colors.white,      // AppBarの文字やアイコンの色
          elevation: 0, // AppBarの影を消す (フラットデザイン風)
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF2C2C2C),    // BottomNavigationBarの背景色
          selectedItemColor: Colors.tealAccent, // 選択されたアイテムの色 (アクセントカラー)
          unselectedItemColor: Colors.grey,     // 選択されていないアイテムの色
        ),
        // アクセントカラーを定義 (ボタンなどに使用)
        colorScheme: ThemeData.dark().colorScheme.copyWith(
          secondary: Colors.tealAccent[400], // FABボタンなどに使われるアクセントカラー
          brightness: Brightness.dark, // 全体のテーマの明るさをダークに
        ),
        // (オプション) カードのテーマ
        cardTheme: CardTheme(
          color: const Color(0xFF2C2C2C), // カードの背景色
          elevation: 2.0, // カードの影
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // カードの角を丸くする
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // カード周りの余白
        ),
        // (オプション) フローティングアクションボタンのテーマ
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.tealAccent[400],
          foregroundColor: Colors.black,
        ),
      ),
      home: const MyHomePage(),
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

  // 各タブで表示する画面ウィジェットのリスト
  static const List<Widget> _widgetOptions = <Widget>[
    ProjectsScreen(),  // 作成した ProjectsScreen を指定
    ArchiveScreen(),   // 作成した ArchiveScreen を指定
    SettingsScreen(),  // 作成した SettingsScreen を指定
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBarは各画面で定義するので、ここでは不要
      // appBar: AppBar(
      //   title: const Text('ToDo App'),
      // ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt), // プロジェクトっぽいアイコンに変更
            label: 'プロジェクト',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined), // アーカイブっぽいアイコンに変更
            label: 'アーカイブ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), // 設定っぽいアイコンに変更
            label: '設定',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}