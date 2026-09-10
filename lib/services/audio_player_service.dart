import 'dart:async';
import 'package:flutter/foundation.dart';

class TrackModel {
  final String id;
  final String title;
  final String artist;
  final String category;
  final String coverIcon;
  final int durationSeconds;

  const TrackModel({
    required this.id,
    required this.title,
    required this.artist,
    this.category = 'Music',
    this.coverIcon = '🎵',
    this.durationSeconds = 225, // 3:45
  });
}

class AudioPlayerService extends ChangeNotifier {
  TrackModel? _currentTrack;
  bool _isPlaying = false;
  int _positionSeconds = 0;
  Timer? _timer;

  TrackModel? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  bool get hasTrack => _currentTrack != null;
  int get positionSeconds => _positionSeconds;
  int get durationSeconds => _currentTrack?.durationSeconds ?? 225;

  double get progressPercent {
    if (durationSeconds == 0) return 0.0;
    final progress = _positionSeconds / durationSeconds;
    return progress.clamp(0.0, 1.0);
  }

  String get formattedPosition => _formatDuration(_positionSeconds);
  String get formattedDuration => _formatDuration(durationSeconds);

  void playTrack(TrackModel track) {
    if (_currentTrack?.id == track.id) {
      if (!_isPlaying) {
        play();
      }
      return;
    }

    _currentTrack = track;
    _positionSeconds = 0;
    _isPlaying = true;
    _startTimer();
    notifyListeners();
  }

  void play() {
    if (_currentTrack == null) return;
    _isPlaying = true;
    _startTimer();
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    _stopTimer();
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    _positionSeconds = 0;
    _currentTrack = null;
    _stopTimer();
    notifyListeners();
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void seekTo(int seconds) {
    _positionSeconds = seconds.clamp(0, durationSeconds);
    notifyListeners();
  }

  void seekPercent(double percent) {
    final target = (percent * durationSeconds).round();
    seekTo(target);
  }

  void skipNext() {
    if (_currentTrack == null) return;
    _positionSeconds = 0;
    notifyListeners();
  }

  void skipPrevious() {
    _positionSeconds = 0;
    notifyListeners();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying) {
        if (_positionSeconds < durationSeconds) {
          _positionSeconds++;
          notifyListeners();
        } else {
          // Track completed
          _positionSeconds = 0;
          _isPlaying = false;
          _stopTimer();
          notifyListeners();
        }
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    final mStr = mins < 10 ? '0$mins' : '$mins';
    final sStr = secs < 10 ? '0$secs' : '$secs';
    return '$mStr:$sStr';
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
