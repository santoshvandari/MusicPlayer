import 'package:flutter/material.dart';
import 'package:music/screens/now_playing_screen.dart';
import 'package:music/services/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _songs = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await AudioService.getLocalAudioFiles();

      if (songs.isNotEmpty) {
        setState(() {
          _songs = songs;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No audio files found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading audio files: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _loadSongs();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadSongs,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _songs.isEmpty
                  ? const Center(
                      child: Text('No songs found'),
                    )
                  : ListView.builder(
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        final song = _songs[index];
                        final filepath = song.split("/0/")[1];
                        return ListTile(
                          leading: const Icon(Icons.music_note),
                          title: Text(
                            song.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            filepath,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NowPlayingScreen(
                                  songPath: song,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
