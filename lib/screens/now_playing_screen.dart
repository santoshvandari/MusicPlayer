import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class NowPlayingScreen extends StatefulWidget {
  final String songPath;

  const NowPlayingScreen({super.key, required this.songPath});

  @override
  _NowPlayingScreenState createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _playAudio();
  }

  Future<void> _playAudio() async {
    await _audioPlayer.play(DeviceFileSource(widget.songPath));
    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Now Playing'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Currently Song Playign Sreen",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          )
          // Text(
          //   widget.songPath.split('/').last,
          //   textAlign: TextAlign.center,
          //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          // ),
          // SizedBox(height: 20),
          // IconButton(
          //   icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 48),
          //   onPressed: _togglePlayPause,
          // ),
        ],
      ),
    );
  }
}
