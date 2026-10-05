import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'ad_manager.dart';

class InterstitialAdManager implements LevelPlayInterstitialAdListener {
  static final InterstitialAdManager instance = InterstitialAdManager._internal();
  factory InterstitialAdManager() => instance;
  InterstitialAdManager._internal();

  LevelPlayInterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  VoidCallback? _currentOnProceedCallback;

  /// Pre-creates and loads the Interstitial Ad unit
  Future<void> loadAd() async {
    if (!AdManager.instance.isInitialized) {
      debugPrint('[InterstitialAdManager] Cannot load: SDK not initialized.');
      return;
    }
    if (_isAdLoaded || _isLoading) {
      debugPrint('[InterstitialAdManager] Ad already loaded or loading.');
      return;
    }

    _isLoading = true;
    final adUnitId = AdManager.instance.isUnityAdsEngine
        ? (AdManager.instance.interstitialAdUnitId.contains('-')
            ? AdManager.unityInterstitialPlacementId
            : AdManager.instance.interstitialAdUnitId)
        : AdManager.instance.interstitialAdUnitId;

    try {
      debugPrint('[InterstitialAdManager] Loading Live Interstitial Ad: $adUnitId');

      if (!AdManager.instance.isUnityAdsEngine) {
        _interstitialAd ??= LevelPlayInterstitialAd(adUnitId: adUnitId);
        _interstitialAd!.setListener(this);
        await _interstitialAd!.loadAd();
      } else {
        await UnityAds.load(
          placementId: adUnitId,
          onComplete: (placementId) {
            debugPrint('[InterstitialAdManager] Unity Direct Interstitial Loaded: $placementId');
            _isAdLoaded = true;
            _isLoading = false;
          },
          onFailed: (placementId, error, errorMessage) {
            debugPrint('[InterstitialAdManager] Unity Direct Interstitial Load Failed: $error - $errorMessage');
            _isLoading = false;
          },
        );
      }
    } catch (e) {
      _isLoading = false;
      debugPrint('[InterstitialAdManager] Error loading Interstitial Ad: $e');
    }
  }

  /// Checks if an interstitial ad is currently ready to be displayed
  Future<bool> isAdReady() async {
    if (!AdManager.instance.isInitialized) return false;
    try {
      if (_interstitialAd != null) {
        final ready = await _interstitialAd!.isAdReady();
        if (ready) return true;
      }
      return _isAdLoaded;
    } catch (e) {
      debugPrint('[InterstitialAdManager] Error checking isAdReady: $e');
      return false;
    }
  }

  /// Displays the Live Interstitial Ad. If not ready, proceeds smoothly and preloads for next time.
  Future<void> showInterstitialWithFallback({
    required VoidCallback onProceed,
    BuildContext? context,
  }) async {
    _currentOnProceedCallback = onProceed;
    final placementId = AdManager.instance.isUnityAdsEngine
        ? (AdManager.instance.interstitialAdUnitId.contains('-')
            ? AdManager.unityInterstitialPlacementId
            : AdManager.instance.interstitialAdUnitId)
        : AdManager.instance.interstitialAdUnitId;

    // 1. LevelPlay Interstitial Display
    if (!AdManager.instance.isUnityAdsEngine) {
      if (_interstitialAd != null) {
        try {
          final ready = await _interstitialAd!.isAdReady();
          if (ready) {
            debugPrint('[InterstitialAdManager] Showing Live LevelPlay Interstitial Ad: $placementId');
            await _interstitialAd!.showAd();
            return;
          }
        } catch (e) {
          debugPrint('[InterstitialAdManager] LevelPlay show exception: $e');
        }
      }

      // Ad not ready or still caching: smoothly proceed with user action and preload
      debugPrint('[InterstitialAdManager] Live Interstitial not ready yet. Proceeding with action...');
      _executeOnProceed();
      loadAd();
      return;
    }

    // 2. Direct Unity Ads Interstitial Display
    if (_isAdLoaded) {
      try {
        debugPrint('[InterstitialAdManager] Showing Unity Direct Interstitial Ad: $placementId');
        await UnityAds.showVideoAd(
          placementId: placementId,
          onStart: (pId) => debugPrint('[InterstitialAdManager] Unity Video Ad Started: $pId'),
          onClick: (pId) => debugPrint('[InterstitialAdManager] Unity Video Ad Clicked: $pId'),
          onSkipped: (pId) {
            debugPrint('[InterstitialAdManager] Unity Video Ad Skipped: $pId');
            _isAdLoaded = false;
            _executeOnProceed();
            loadAd();
          },
          onComplete: (pId) {
            debugPrint('[InterstitialAdManager] Unity Video Ad Completed: $pId');
            _isAdLoaded = false;
            _executeOnProceed();
            loadAd();
          },
          onFailed: (pId, error, message) {
            debugPrint('[InterstitialAdManager] Unity Video Ad Display Failed: $error - $message');
            _isAdLoaded = false;
            _executeOnProceed();
            loadAd();
          },
        );
        return;
      } catch (e) {
        debugPrint('[InterstitialAdManager] Exception displaying Unity Video Ad: $e');
      }
    }

    // Proceed if ad is still loading
    _executeOnProceed();
    loadAd();
  }

  void _executeOnProceed() {
    if (_currentOnProceedCallback != null) {
      final callback = _currentOnProceedCallback!;
      _currentOnProceedCallback = null;
      callback();
    }
  }

  // --- LevelPlayInterstitialAdListener Callbacks ---

  int _retryAttempt = 0;
  Timer? _retryTimer;

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    _isAdLoaded = true;
    _isLoading = false;
    _retryAttempt = 0;
    _retryTimer?.cancel();
    debugPrint('[InterstitialAdManager] LevelPlay Interstitial Loaded Successfully: ${adInfo.adUnitId}');
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    _isLoading = false;
    _isAdLoaded = false;
    debugPrint('[InterstitialAdManager] LevelPlay Interstitial Load Failed (Code: ${error.errorCode}): ${error.errorMessage}');
    
    // Automatically retry loading with exponential backoff (up to 60s)
    _retryTimer?.cancel();
    _retryAttempt++;
    final delaySeconds = (_retryAttempt * 10).clamp(10, 60);
    debugPrint('[InterstitialAdManager] Scheduling retry in ${delaySeconds}s (attempt #$_retryAttempt)...');
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isAdLoaded && !_isLoading) {
        loadAd();
      }
    });
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    debugPrint('[InterstitialAdManager] LevelPlay Interstitial Displayed: ${adInfo.adUnitId}');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    debugPrint('[InterstitialAdManager] LevelPlay Interstitial Display Failed: ${error.errorMessage}');
    _isAdLoaded = false;
    _executeOnProceed();
    loadAd();
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    debugPrint('[InterstitialAdManager] LevelPlay Interstitial Closed by user: ${adInfo.adUnitId}');
    _isAdLoaded = false;
    _executeOnProceed();
    loadAd();
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    debugPrint('[InterstitialAdManager] LevelPlay Interstitial Clicked: ${adInfo.adUnitId}');
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}
}
