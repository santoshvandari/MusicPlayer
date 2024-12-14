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
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    // Play the audio
    await _audioPlayer.play(DeviceFileSource(widget.songPath));

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position;
      });
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

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

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Add more options functionality
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Album Art / Music Visualization
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/default_album.png'), // Replace with actual album art
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white24,
                      spreadRadius: 5,
                      blurRadius: 20,
                    )
                  ],
                ),
              ),
            ),

            // Song Information
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.songPath.split('/').last.replaceAll('.mp3', ''),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Artist Name', // Replace with actual artist
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Slider and Time
            // Slider and Time
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Slider(
                    value: _totalDuration.inSeconds > 0
                        ? _currentPosition.inSeconds
                            .clamp(0, _totalDuration.inSeconds)
                            .toDouble()
                        : 0.0,
                    max: _totalDuration.inSeconds > 0
                        ? _totalDuration.inSeconds.toDouble()
                        : 1.0,
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                    onChanged: (value) {
                      if (_totalDuration.inSeconds > 0) {
                        final position = Duration(seconds: value.toInt());
                        _audioPlayer.seek(position);
                        setState(() {
                          _currentPosition = position;
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_currentPosition),
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          _formatDuration(_totalDuration),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Control Buttons
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous,
                        color: Colors.white, size: 40),
                    onPressed: () {
                      // Previous track functionality
                    },
                  ),
                  SizedBox(width: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white38,
                          spreadRadius: 3,
                          blurRadius: 15,
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 50,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.skip_next, color: Colors.white, size: 40),
                    onPressed: () {
                      // Next track functionality
                    },
                  ),
                ],
              ),
            ),

            // Additional Controls
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.shuffle, color: Colors.white),
                    onPressed: () {
                      // Shuffle functionality
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.repeat, color: Colors.white),
                    onPressed: () {
                      // Repeat functionality
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
