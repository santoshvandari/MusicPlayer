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
    try {
      await _audioPlayer.setSource(DeviceFileSource(widget.songPath));

      final duration = await _audioPlayer.getDuration();
      if (duration != null) {
        setState(() {
          _totalDuration = duration;
        });
      }

      await _audioPlayer.resume();

      _audioPlayer.onPositionChanged.listen((Duration position) {
        setState(() {
          _currentPosition = position;
        });
      });

      _audioPlayer.onDurationChanged.listen((Duration duration) {
        setState(() {
          _totalDuration = duration;
        });
      });

      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D2671), Color(0xFFC33764)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              _buildAppBar(),

              // Album Art
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/default_album.png'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          spreadRadius: 10,
                          blurRadius: 20,
                        ),
                      ],
                    ),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Artist Name', // Replace with actual artist
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Slider and Time
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Slider(
                      value: _currentPosition.inSeconds.toDouble(),
                      min: 0.0,
                      max: _totalDuration.inSeconds.toDouble() == 0.0
                          ? 1.0
                          : _totalDuration.inSeconds.toDouble(),
                      activeColor: Colors.white,
                      inactiveColor: Colors.white24,
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
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            _formatDuration(_totalDuration),
                            style: const TextStyle(color: Colors.white),
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
                      icon: const Icon(Icons.skip_previous,
                          color: Colors.white, size: 40),
                      onPressed: () {
                        // Previous track functionality
                      },
                    ),
                    const SizedBox(width: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white38,
                            spreadRadius: 3,
                            blurRadius: 15,
                          ),
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
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.skip_next,
                          color: Colors.white, size: 40),
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
                      icon: const Icon(Icons.shuffle, color: Colors.white),
                      onPressed: () {
                        // Shuffle functionality
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.repeat, color: Colors.white),
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
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Add more options functionality
            },
          ),
        ],
      ),
    );
  }
}
