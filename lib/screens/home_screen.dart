import 'package:flutter/material.dart';
import 'package:music/services/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _songs = [];

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadFiles();
  }

  Future<void> _requestPermissionAndLoadFiles() async {
    if (await Permission.storage.request().isGranted) {
      _songs = await AudioService.getLocalAudioFiles();
      setState(() {});
    } else {
      // Show a message if permission is denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission is required!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];
          return ListTile(
            leading: Icon(Icons.music_note),
            title: Text(song.split('/').last), // Display the file name
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NowPlayingScreen(songPath: song),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
