import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';

class NowPlayingScreen extends StatefulWidget {
  final List<String> songs;
  final int initialIndex;

  const NowPlayingScreen({
    super.key,
    required this.songs,
    required this.initialIndex,
  });

  @override
  _NowPlayingScreenState createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  late final AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource _playlist;
  bool _isPlaying = false;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _audioPlayer = AudioPlayer();

    // Build playlist
    _playlist = ConcatenatingAudioSource(
      children:
          widget.songs.map((song) => AudioSource.uri(Uri.parse(song))).toList(),
    );

    await _audioPlayer.setAudioSource(_playlist,
        initialIndex: widget.initialIndex);

    // Listeners for UI updates
    _audioPlayer.positionStream.listen((position) {
      setState(() => _currentPosition = position);
    });

    _audioPlayer.durationStream.listen((duration) {
      setState(() => _totalDuration = duration ?? Duration.zero);
    });

    _audioPlayer.playerStateStream.listen((state) {
      setState(() => _isPlaying = state.playing);
    });

    _audioPlayer.shuffleModeEnabledStream.listen((enabled) {
      setState(() => _isShuffleEnabled = enabled);
    });

    _audioPlayer.loopModeStream.listen((loopMode) {
      setState(() => _loopMode = loopMode);
    });

    // Start playback
    await _audioPlayer.play();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> _skipToNext() async {
    await _audioPlayer.seekToNext();
  }

  Future<void> _skipToPrevious() async {
    await _audioPlayer.seekToPrevious();
  }

  Future<void> _toggleShuffle() async {
    final enabled = !_isShuffleEnabled;
    await _audioPlayer.setShuffleModeEnabled(enabled);
  }

  Future<void> _toggleRepeat() async {
    final nextMode = _loopMode == LoopMode.off
        ? LoopMode.one
        : _loopMode == LoopMode.one
            ? LoopMode.all
            : LoopMode.off;
    await _audioPlayer.setLoopMode(nextMode);
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
    final currentIndex = _audioPlayer.currentIndex ?? 0;
    final songName =
        widget.songs[currentIndex].split('/').last.replaceAll('.mp3', '');

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
          max: _totalDuration.inSeconds.toDouble().clamp(0.0, double.infinity),
          activeColor: Colors.white,
          inactiveColor: Colors.white24,
          onChanged: (value) {
            final position = Duration(seconds: value.toInt());
            _audioPlayer.seek(position);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_currentPosition),
                  style: const TextStyle(color: Colors.white)),
              Text(_formatDuration(_totalDuration),
                  style: const TextStyle(color: Colors.white)),
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
          onPressed: _skipToPrevious,
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 50,
          ),
          onPressed: _togglePlayPause,
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
          onPressed: _skipToNext,
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
            _loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
            color: _loopMode != LoopMode.off ? Colors.blue : Colors.white,
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
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
