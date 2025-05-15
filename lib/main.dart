import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// アプリ全体の「土台」となるStatelessWidget (ここはシンプルにMaterialAppを返すだけ)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme( // const を追加
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      title: 'Hiroki First App',
      home: const MyHomePage(), // Scaffold部分をStatefulWidgetに分離
    ); // MaterialAppの末尾にセミコロンを追加
  }
}

// 画面の主要部分とBottomNavigationBarの状態を管理するStatefulWidget
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // 現在選択されているアイテムのインデックスを保持

  // アイテムがタップされたときに呼ばれる関数
  void _onItemTapped(int index) {
    setState(() { // 状態を更新することをFlutterに伝える
      _selectedIndex = index; // 選択されたインデックスを更新
    });
  }

  // 各タブで表示する仮のウィジェット（実際のアプリでは各画面ウィジェットに置き換えます）
  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('ホームの内容')),
    Center(child: Text('検索の内容')),
    Center(child: Text('設定の内容')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hiroki First App'),
        // ThemeDataで指定しているので、ここでは不要ならコメントアウトまたは削除
        // backgroundColor: Colors.black,
      ),
      body: _widgetOptions.elementAt(_selectedIndex), // 選択されたインデックスに応じて表示するウィジェットを切り替え
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "ホーム",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "検索",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "設定",
          ),
        ],
        currentIndex: _selectedIndex, // 現在選択されているアイテムのインデックスを指定
        selectedItemColor: Colors.amber[800], // 選択されたアイテムの色（任意）
        onTap: _onItemTapped, // タップされたときの処理を指定
      ),
    );
  }
}