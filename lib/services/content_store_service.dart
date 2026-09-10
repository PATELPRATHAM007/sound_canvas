import 'package:flutter/foundation.dart';

class ContentStoreService extends ChangeNotifier {
  final Set<String> _likedTrackIds = {'1', 'hero'};
  final List<Map<String, String>> _publishedPosts = [];

  Set<String> get likedTrackIds => _likedTrackIds;
  List<Map<String, String>> get publishedPosts => _publishedPosts;

  bool isLiked(String trackId) {
    return _likedTrackIds.contains(trackId);
  }

  void toggleLike(String trackId) {
    if (_likedTrackIds.contains(trackId)) {
      _likedTrackIds.remove(trackId);
    } else {
      _likedTrackIds.add(trackId);
    }
    notifyListeners();
  }

  void addPost(Map<String, String> post) {
    _publishedPosts.insert(0, post);
    notifyListeners();
  }
}
