import 'audio_player_service.dart';
import 'content_store_service.dart';
import '../ads/ad_manager.dart';
import '../ads/interstitial_ad_manager.dart';

class ServiceLocator {
  static AudioPlayerService audioPlayer = AudioPlayerService();
  static ContentStoreService contentStore = ContentStoreService();
  static AdManager adManager = AdManager.instance;
  static InterstitialAdManager interstitialAdManager = InterstitialAdManager.instance;

  static void init() {
    audioPlayer = AudioPlayerService();
    contentStore = ContentStoreService();
    adManager = AdManager.instance;
    interstitialAdManager = InterstitialAdManager.instance;
  }
}

/// Convenience global accessor for Dependency Injection
final locator = ServiceLocator();
