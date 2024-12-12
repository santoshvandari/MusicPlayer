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
    _requestPermissionAndLoadFiles();
  }

  Future<void> _requestPermissionAndLoadFiles() async {
    try {
      // Request storage permission
      PermissionStatus status = await Permission.storage.request();
      debugPrint("Permission Status: $status");

      if (true) {
        // Attempt to load songs
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
      } else {
        setState(() {
          _errorMessage = 'Storage permission denied';
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
              _requestPermissionAndLoadFiles();
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
                        onPressed: _requestPermissionAndLoadFiles,
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
                        return ListTile(
                          leading: const Icon(Icons.music_note),
                          title: Text(
                            song.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            song,
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
