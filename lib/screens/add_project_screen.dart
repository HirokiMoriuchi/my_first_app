import 'package:flutter/material.dart';
import '../models/project_model.dart'; // Projectモデルを読み込む

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>(); // フォームの状態を管理するためのキー
  String _projectTitle = ''; // 入力されたプロジェクトタイトルを保持する変数

  void _saveProject() {
    // バリデーション（入力チェック）を実行
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // フォームのonSavedを実行して _projectTitle を更新

      // 新しいProjectオブジェクトを作成
      final newProject = Project(
        // IDはユニークなものが必要。ここでは現在時刻をミリ秒に変換したものを使う（簡易的）
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _projectTitle,
        createdAt: DateTime.now(),
        tasks: [], // 最初はタスクなし
      );
      // 前の画面に新しいプロジェクトを渡して戻る
      Navigator.of(context).pop(newProject);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新しいプロジェクトを作成'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // フォームにキーを設定
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'プロジェクトタイトル',
                  hintText: '例: 夏休みの旅行計画',
                  border: OutlineInputBorder(), // 枠線をつける
                ),
                validator: (value) { // 入力値のバリデーション
                  if (value == null || value.trim().isEmpty) {
                    return 'プロジェクトタイトルを入力してください。';
                  }
                  return null; // 問題なければnullを返す
                },
                onSaved: (value) { // 保存時の処理
                  _projectTitle = value!;
                },
                autofocus: true, // 画面表示時に自動でフォーカス
              ),
              const SizedBox(height: 24.0), // 少しスペースを空ける
              ElevatedButton(
                onPressed: _saveProject, // 保存ボタンが押されたら_saveProjectを実行
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary, // テーマのアクセントカラーを使用
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                child: const Text('作成する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}