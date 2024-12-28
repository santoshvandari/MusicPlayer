import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/services/audio_handler.dart';
import 'package:audio_service/audio_service.dart';

class NowPlayingScreen extends StatefulWidget {
  final String songPath;
  final List<String> songs;
  final int initialIndex;

  const NowPlayingScreen(
      {super.key,
      required this.songPath,
      required this.songs,
      required this.initialIndex});

  @override
  _NowPlayingScreenState createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  late MyAudioHandler _audioHandler;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isShuffleEnabled = false;
  LoopMode _repeatMode = LoopMode.off;

  @override
  void initState() {
    super.initState();
    _initializeAudioHandler();
  }

  Future<void> _initializeAudioHandler() async {
    _audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.musicplayer.channel.audio',
        androidNotificationChannelName: 'Music Player',
      ),
    );

    await _audioHandler.initializePlaylist(widget.songs, widget.initialIndex);

    // Set up position and duration listeners
    _audioHandler._player.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioHandler._player.durationStream.listen((duration) {
      if (duration != null) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _audioHandler._player.playerStateStream.listen((playerState) {
      setState(() {
        _isPlaying = playerState.playing;
      });
    });

    // Update UI with current playback state
    final playbackInfo = _audioHandler.getCurrentPlaybackInfo();
    setState(() {
      _isShuffleEnabled = playbackInfo['isShuffleEnabled'];
      _repeatMode = playbackInfo['repeatMode'];
    });
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
  }

  Future<void> _handlePrevious() async {
    await _audioHandler.skipToPrevious();
    _updatePlaybackInfo();
  }

  Future<void> _handleNext() async {
    await _audioHandler.skipToNext();
    _updatePlaybackInfo();
  }

  Future<void> _toggleShuffle() async {
    await _audioHandler.toggleShuffle();
    _updatePlaybackInfo();
  }

  Future<void> _toggleRepeat() async {
    await _audioHandler.toggleRepeatMode();
    _updatePlaybackInfo();
  }

  void _updatePlaybackInfo() {
    final playbackInfo = _audioHandler.getCurrentPlaybackInfo();
    setState(() {
      _isShuffleEnabled = playbackInfo['isShuffleEnabled'];
      _repeatMode = playbackInfo['repeatMode'];
    });
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
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
              _buildAppBar(),

              // Album Art
              Expanded(
                flex: 3,
                child: _buildAlbumArt(),
              ),

              // Song Information
              Expanded(
                flex: 1,
                child: _buildSongInfo(),
              ),

              // Slider and Time
              Expanded(
                flex: 1,
                child: _buildProgressBar(),
              ),

              // Control Buttons
              Expanded(
                flex: 1,
                child: _buildControlButtons(),
              ),

              // Additional Controls
              Expanded(
                flex: 1,
                child: _buildAdditionalControls(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        height: 300,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white24,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              spreadRadius: 10,
              blurRadius: 20,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.music_note,
            color: Colors.white,
            size: 100,
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo() {
    final currentSong =
        _audioHandler.getCurrentPlaybackInfo()['currentSong'] as String?;
    final songName = currentSong?.split('/').last.replaceAll('.mp3', '') ?? '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          songName,
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
          'Unknown Artist',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
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
              _audioHandler.seek(position);
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
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
          onPressed: _handlePrevious,
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
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
          onPressed: _handleNext,
        ),
      ],
    );
  }

  Widget _buildAdditionalControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.shuffle,
            color: _isShuffleEnabled ? Colors.blue : Colors.white,
          ),
          onPressed: _toggleShuffle,
        ),
        IconButton(
          icon: Icon(
            _repeatMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
            color: _repeatMode != LoopMode.off ? Colors.blue : Colors.white,
          ),
          onPressed: _toggleRepeat,
        ),
      ],
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

  @override
  void dispose() {
    _audioHandler.stop();
    super.dispose();
  }
}
