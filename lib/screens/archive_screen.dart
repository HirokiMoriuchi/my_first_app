import 'package:flutter/material.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アーカイブ'),
      ),
      body: const Center(
        child: Text(
          'アーカイブされたプロジェクトがここに表示されます',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}