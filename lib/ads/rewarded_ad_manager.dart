import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'ad_manager.dart';

class RewardedAdManager implements LevelPlayRewardedAdListener {
  static final RewardedAdManager instance = RewardedAdManager._internal();
  factory RewardedAdManager() => instance;
  RewardedAdManager._internal();

  LevelPlayRewardedAd? _levelPlayRewardedAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  VoidCallback? _onRewardEarnedCallback;
  VoidCallback? _onSkippedCallback;
  Function(String)? _onFailedCallback;

  bool get isLoaded => _isAdLoaded;

  /// Pre-loads the Rewarded Ad placement
  Future<void> loadAd() async {
    if (!AdManager.instance.isInitialized) {
      debugPrint('[RewardedAdManager] Cannot load: SDK not initialized.');
      return;
    }
    if (_isAdLoaded || _isLoading) {
      debugPrint('[RewardedAdManager] Rewarded Ad already loaded or loading.');
      return;
    }

    _isLoading = true;
    final adUnitId = AdManager.instance.rewardedAdUnitId;

    try {
      debugPrint('[RewardedAdManager] Loading Rewarded Ad: $adUnitId');

      if (!AdManager.instance.isUnityAdsEngine) {
        _levelPlayRewardedAd ??= LevelPlayRewardedAd(adUnitId: adUnitId);
        _levelPlayRewardedAd!.setListener(this);
        await _levelPlayRewardedAd!.loadAd();
      } else {
        await UnityAds.load(
          placementId: adUnitId,
          onComplete: (placementId) {
            debugPrint('[RewardedAdManager] Unity Direct Rewarded Ad Loaded: $placementId');
            _isAdLoaded = true;
            _isLoading = false;
          },
          onFailed: (placementId, error, errorMessage) {
            debugPrint('[RewardedAdManager] Unity Direct Rewarded Ad Load Failed: $error - $errorMessage');
            _isLoading = false;
          },
        );
      }
    } catch (e) {
      _isLoading = false;
      debugPrint('[RewardedAdManager] Error loading Rewarded Ad: $e');
    }
  }

  /// Checks if the Rewarded Ad is ready to be shown
  Future<bool> isAdReady() async {
    if (!AdManager.instance.isInitialized) return false;
    try {
      if (!AdManager.instance.isUnityAdsEngine) {
        if (_levelPlayRewardedAd != null) {
          final ready = await _levelPlayRewardedAd!.isAdReady();
          if (ready) return true;
        }
      }
      return _isAdLoaded;
    } catch (e) {
      debugPrint('[RewardedAdManager] Error checking isAdReady: $e');
      return false;
    }
  }

  /// Shows the Live Rewarded Ad and grants reward upon full completion
  Future<void> showRewardedAd({
    required VoidCallback onRewardEarned,
    VoidCallback? onSkipped,
    Function(String error)? onFailed,
    BuildContext? context,
  }) async {
    _onRewardEarnedCallback = onRewardEarned;
    _onSkippedCallback = onSkipped;
    _onFailedCallback = onFailed;

    final placementId = AdManager.instance.rewardedAdUnitId;

    // 1. LevelPlay Rewarded Display
    if (!AdManager.instance.isUnityAdsEngine) {
      if (_levelPlayRewardedAd != null) {
        try {
          final ready = await _levelPlayRewardedAd!.isAdReady();
          if (ready) {
            debugPrint('[RewardedAdManager] Showing Live LevelPlay Rewarded Ad: $placementId');
            await _levelPlayRewardedAd!.showAd();
            return;
          }
        } catch (e) {
          debugPrint('[RewardedAdManager] LevelPlay Rewarded show exception: $e');
        }
      }

      // Ad not ready: inform user and preload
      debugPrint('[RewardedAdManager] Live Rewarded Ad not ready yet. Preloading...');
      _onFailedCallback?.call('Live rewarded video is preparing. Please try again in a few moments.');
      loadAd();
      return;
    }

    // 2. Direct Unity Ads Rewarded Display
    if (_isAdLoaded) {
      try {
        debugPrint('[RewardedAdManager] Showing Unity Direct Rewarded Ad: $placementId');
        await UnityAds.showVideoAd(
          placementId: placementId,
          onStart: (pId) => debugPrint('[RewardedAdManager] Unity Rewarded Ad Started: $pId'),
          onClick: (pId) => debugPrint('[RewardedAdManager] Unity Rewarded Ad Clicked: $pId'),
          onSkipped: (pId) {
            debugPrint('[RewardedAdManager] Unity Rewarded Ad Skipped (No reward): $pId');
            _isAdLoaded = false;
            _onSkippedCallback?.call();
            loadAd();
          },
          onComplete: (pId) {
            debugPrint('[RewardedAdManager] Unity Rewarded Ad Completed -> REWARD EARNED!: $pId');
            _isAdLoaded = false;
            _grantReward();
            loadAd();
          },
          onFailed: (pId, error, message) {
            debugPrint('[RewardedAdManager] Unity Rewarded Ad Display Failed: $error - $message');
            _isAdLoaded = false;
            _onFailedCallback?.call(message);
            loadAd();
          },
        );
        return;
      } catch (e) {
        debugPrint('[RewardedAdManager] Exception displaying Unity Rewarded Ad: $e');
      }
    }

    _onFailedCallback?.call('Rewarded video is currently loading.');
    loadAd();
  }

  void _grantReward() {
    if (_onRewardEarnedCallback != null) {
      final callback = _onRewardEarnedCallback!;
      _onRewardEarnedCallback = null;
      callback();
    }
  }

  // --- LevelPlayRewardedAdListener Callbacks ---

  int _retryAttempt = 0;
  Timer? _retryTimer;

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    _isAdLoaded = true;
    _isLoading = false;
    _retryAttempt = 0;
    _retryTimer?.cancel();
    debugPrint('[RewardedAdManager] LevelPlay Rewarded Ad Loaded: ${adInfo.adUnitId}');
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    _isLoading = false;
    _isAdLoaded = false;
    debugPrint('[RewardedAdManager] LevelPlay Rewarded Ad Load Failed (Code ${error.errorCode}): ${error.errorMessage}');

    _retryTimer?.cancel();
    _retryAttempt++;
    final delaySeconds = (_retryAttempt * 10).clamp(10, 60);
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isAdLoaded && !_isLoading) {
        loadAd();
      }
    });
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    debugPrint('[RewardedAdManager] LevelPlay Rewarded Ad Displayed: ${adInfo.adUnitId}');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    debugPrint('[RewardedAdManager] LevelPlay Rewarded Ad Display Failed: ${error.errorMessage}');
    _isAdLoaded = false;
    _onFailedCallback?.call(error.errorMessage);
    loadAd();
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    debugPrint('[RewardedAdManager] LevelPlay Rewarded Ad Closed: ${adInfo.adUnitId}');
    _isAdLoaded = false;
    loadAd();
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    debugPrint('[RewardedAdManager] LevelPlay Rewarded Ad Clicked: ${adInfo.adUnitId}');
  }

  @override
  void onAdRewarded(LevelPlayReward reward, LevelPlayAdInfo adInfo) {
    debugPrint('[RewardedAdManager] LevelPlay Reward Granted: ${reward.amount} ${reward.name}');
    _grantReward();
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}
}
