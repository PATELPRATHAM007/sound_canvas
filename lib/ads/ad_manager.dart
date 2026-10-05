import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'interstitial_ad_manager.dart';
import 'rewarded_ad_manager.dart';

class AdManager implements LevelPlayInitListener {
  static final AdManager instance = AdManager._internal();
  factory AdManager() => instance;
  AdManager._internal();

  static const MethodChannel _nativeChannel = MethodChannel('com.novasoftstudio.soundcanvas/device_info');
  String? deviceAdId;

  // Unity Ads Dashboard Credentials (Sound Canvas Live)
  static const String unityGameId = "800388435";
  static const String unityOrgCoreId = "13469955020066";
  static const String unityStatsApiKey = "60b23c5ea1ead4776e9ac9fc62f3f353ee77770f0f6ce4bb09226a81b49e1cbd";
  static const String unityProjectId = "978cc626-daf4-4055-9c44-6473dfc4d2cb";

  // Unity Direct Placement IDs
  static const String unityBannerPlacementId = "BP_Banner_Android";
  static const String unityInterstitialPlacementId = "BP_Interstitial_Android";
  static const String unityRewardedPlacementId = "BP_Rewarded_Android";

  // Active Ad Credentials (Live Ads)
  static const String defaultAppKey = unityGameId;
  static const String defaultBannerAdUnitId = unityBannerPlacementId;
  static const String defaultInterstitialAdUnitId = unityInterstitialPlacementId;
  static const String defaultRewardedAdUnitId = unityRewardedPlacementId;

  String appKey = defaultAppKey;
  String bannerAdUnitId = defaultBannerAdUnitId;
  String interstitialAdUnitId = defaultInterstitialAdUnitId;
  String rewardedAdUnitId = defaultRewardedAdUnitId;

  bool isInitialized = false;
  bool isInitializing = false;
  bool isTestMode = false;
  bool isUnityAdsEngine = false;

  Completer<bool>? _initCompleter;
  final StreamController<bool> _initStatusController = StreamController<bool>.broadcast();
  Stream<bool> get onInitStatusChanged => _initStatusController.stream;

  /// Initializes Unity Ads or Unity LevelPlay SDK once at app startup for Live Ads
  Future<void> initialize({
    String? appKeyOverride,
    String? bannerAdUnitOverride,
    String? interstitialAdUnitOverride,
    String? rewardedAdUnitOverride,
    bool enableTestMode = false,
  }) async {
    if (isInitialized) {
      debugPrint('[AdManager] Ad SDK is already initialized.');
      return;
    }
    if (isInitializing && _initCompleter != null) {
      debugPrint('[AdManager] Ad SDK initialization in progress, awaiting result...');
      await _initCompleter!.future;
      return;
    }

    isInitializing = true;
    isTestMode = enableTestMode;
    _initCompleter = Completer<bool>();

    if (appKeyOverride != null) appKey = appKeyOverride;
    if (bannerAdUnitOverride != null) bannerAdUnitId = bannerAdUnitOverride;
    if (interstitialAdUnitOverride != null) interstitialAdUnitId = interstitialAdUnitOverride;
    if (rewardedAdUnitOverride != null) rewardedAdUnitId = rewardedAdUnitOverride;

    final isNumericGameId = RegExp(r'^\d+$').hasMatch(appKey);
    debugPrint('[AdManager] Starting Live Ad Init with AppKey/GameID: $appKey (isNumericGameId: $isNumericGameId)');

    // 1. If numerical Game ID (e.g. 800388435), use Direct Unity Ads Engine
    if (isNumericGameId) {
      await _initDirectUnityAds(appKey);
      isInitializing = false;
      return;
    }

    // 2. Alphanumeric Key, use Unity LevelPlay Mediation
    isUnityAdsEngine = false;
    try {
      if (isTestMode) {
        await LevelPlay.setMetaData({
          'is_test_suite': ['enable']
        });
        await LevelPlay.setAdaptersDebug(true);
      }

      final initRequest = LevelPlayInitRequest.builder(appKey).build();
      await LevelPlay.init(initRequest: initRequest, initListener: this);
    } catch (e) {
      debugPrint('[AdManager] LevelPlay Init Exception: $e. Falling back to Direct Unity Ads...');
      await _initDirectUnityAds(unityGameId);
    }

    try {
      await _initCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('[AdManager] Init timeout window reached.');
          return isInitialized;
        },
      );
    } catch (_) {}

    isInitializing = false;
  }

  Future<void> _initDirectUnityAds(String gameId) async {
    isUnityAdsEngine = true;
    try {
      await UnityAds.init(
        gameId: gameId,
        testMode: isTestMode,
        onComplete: () {
          debugPrint('[AdManager] Direct Unity Ads Initialized Successfully with Game ID: $gameId!');
          _onInitSuccessComplete();
        },
        onFailed: (error, errorMessage) {
          debugPrint('[AdManager] Direct Unity Ads Init Failed: $error - $errorMessage');
          _onInitFailedComplete();
        },
      );
    } catch (e) {
      debugPrint('[AdManager] Direct Unity Ads Exception: $e');
      _onInitFailedComplete();
    }
  }

  void _onInitSuccessComplete() {
    isInitialized = true;
    isInitializing = false;
    _initStatusController.add(true);
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      _initCompleter!.complete(true);
    }
    InterstitialAdManager.instance.loadAd();
    RewardedAdManager.instance.loadAd();
  }

  void _onInitFailedComplete() {
    isInitialized = false;
    isInitializing = false;
    _initStatusController.add(false);
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      _initCompleter!.complete(false);
    }
  }

  /// Launch Unity LevelPlay Integration Test Suite
  Future<void> launchTestSuite() async {
    if (!isInitialized) {
      debugPrint('[AdManager] Cannot launch test suite: SDK not initialized.');
      return;
    }
    try {
      debugPrint('[AdManager] Launching LevelPlay Test Suite & Integration Validation...');
      await validateIntegration();
      await LevelPlay.launchTestSuite();
    } catch (e) {
      debugPrint('[AdManager] Error launching LevelPlay Test Suite: $e');
    }
  }

  /// Directly retrieves the Device Advertising ID (ADID / GAID) from the OS
  Future<String?> fetchAndPrintAdId() async {
    try {
      final String? adid = await _nativeChannel.invokeMethod<String>('getAdId');
      deviceAdId = adid;
      debugPrint('[AdManager] =======================================================');
      debugPrint('[AdManager] >>>>> DEVICE ADVERTISING ID (ADID / GAID): $adid <<<<<');
      debugPrint('[AdManager] =======================================================');
      return adid;
    } catch (e) {
      debugPrint('[AdManager] Note: Could not fetch ADID via channel: $e');
      return null;
    }
  }

  /// Calls LevelPlay.validateIntegration() to verify adapter integration
  /// and print Device Advertising ID (AID/GAID / IDFA) in the console log.
  Future<void> validateIntegration() async {
    try {
      debugPrint('[AdManager] =======================================================');
      debugPrint('[AdManager] Running LevelPlay.validateIntegration()');
      debugPrint('[AdManager] =======================================================');
      await LevelPlay.validateIntegration();
      await fetchAndPrintAdId();
    } catch (e) {
      debugPrint('[AdManager] Error during LevelPlay.validateIntegration(): $e');
    }
  }

  // --- LevelPlayInitListener Callbacks ---

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    debugPrint('[AdManager] LevelPlay SDK Initialized Successfully! (AdQuality: ${configuration.isAdQualityEnabled})');
    
    // Automatically fetch ADID & run integration validation in test mode
    if (isTestMode) {
      validateIntegration();
    } else {
      fetchAndPrintAdId();
    }
    
    _onInitSuccessComplete();
  }

  @override
  void onInitFailed(LevelPlayInitError error) {
    debugPrint('[AdManager] LevelPlay SDK Init Failed: ${error.errorMessage} (code: ${error.errorCode})');
    if (!isUnityAdsEngine && unityGameId.isNotEmpty) {
      debugPrint('[AdManager] LevelPlay init rejected, falling back to Direct Unity Ads with Game ID: $unityGameId');
      _initDirectUnityAds(unityGameId);
      return;
    }
    _onInitFailedComplete();
  }
}
