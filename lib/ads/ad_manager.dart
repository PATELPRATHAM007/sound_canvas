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

  // Live Unity / LevelPlay Mediation Credentials
  static const String liveAppKey = "90491fcc-e635-4920-b270-3a7cc1cf46ae";
  static const String liveBannerAdUnitId = "90491fcc-e635-4920-b270-3a7cc1cf46ae";
  static const String liveInterstitialAdUnitId = "90491fcc-e635-4920-b270-3a7cc1cf46ae";
  static const String liveRewardedAdUnitId = "90491fcc-e635-4920-b270-3a7cc1cf46ae";

  // Active Ad Credentials (Live Ads)
  static const String defaultAppKey = liveAppKey;
  static const String defaultBannerAdUnitId = liveBannerAdUnitId;
  static const String defaultInterstitialAdUnitId = liveInterstitialAdUnitId;
  static const String defaultRewardedAdUnitId = liveRewardedAdUnitId;

  // Unity Ads Dashboard Credentials (Sound Canvas Backup)
  static const String unityGameId = "800370998";
  static const String unityOrgCoreId = "13469955020066";
  static const String unityStatsApiKey = "60b23c5ea1ead4776e9ac9fc62f3f353ee77770f0f6ce4bb09226a81b49e1cbd";

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
    debugPrint('[AdManager] Starting Init with AppKey: $appKey (isNumericGameId: $isNumericGameId)');

    // 1. If numerical Game ID (e.g. 800274942), use Direct Unity Ads
    if (isNumericGameId) {
      isUnityAdsEngine = true;
      try {
        await UnityAds.init(
          gameId: appKey,
          testMode: isTestMode,
          onComplete: () {
            debugPrint('[AdManager] Direct Unity Ads Initialized Successfully!');
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
      isInitializing = false;
      return;
    }

    // 2. Alphanumeric Key (e.g. 27977c8bd), use Unity LevelPlay Mediation
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
      debugPrint('[AdManager] LevelPlay Init Exception: $e');
      _onInitFailedComplete();
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
    _onInitFailedComplete();
  }
}
