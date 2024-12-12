import 'package:flutter/material.dart';

void main() {
  runApp(const MusicPlayer());
}

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Music Player'),
        ),
        body: Center(
          child: Text('Hello, World!'),
        ),
      ),
    );
  }
}
