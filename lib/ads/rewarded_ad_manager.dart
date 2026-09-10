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

  /// Shows the Rewarded Ad and grants reward upon full completion
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
            debugPrint('[RewardedAdManager] Showing LevelPlay Rewarded Ad: $placementId');
            await _levelPlayRewardedAd!.showAd();
            return;
          }
        } catch (e) {
          debugPrint('[RewardedAdManager] LevelPlay Rewarded show exception: $e');
        }
      }

      // Show Full-Screen Test Rewarded Modal if context provided, otherwise execute reward
      if (context != null && context.mounted) {
        _showTestRewardedDialog(context);
      } else {
        _grantReward();
        loadAd();
      }
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
            if (context != null && context.mounted) {
              _showTestRewardedDialog(context);
            } else {
              _grantReward();
              loadAd();
            }
          },
        );
        return;
      } catch (e) {
        debugPrint('[RewardedAdManager] Exception displaying Unity Rewarded Ad: $e');
      }
    }

    // Fallback if ad is still loading
    if (context != null && context.mounted) {
      _showTestRewardedDialog(context);
    } else {
      _grantReward();
      loadAd();
    }
  }

  void _grantReward() {
    if (_onRewardEarnedCallback != null) {
      final callback = _onRewardEarnedCallback!;
      _onRewardEarnedCallback = null;
      callback();
    }
  }

  void _showTestRewardedDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _TestRewardedScreen(
          adUnitId: AdManager.instance.rewardedAdUnitId,
          onRewardClaimed: () {
            Navigator.of(dialogContext).pop();
            _grantReward();
            loadAd();
          },
          onSkipped: () {
            Navigator.of(dialogContext).pop();
            _onSkippedCallback?.call();
            loadAd();
          },
        );
      },
    );
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
    debugPrint('[RewardedAdManager] LevelPlay Rewarded Ad Displayed');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {
    debugPrint('[RewardedAdManager] LevelPlay Rewarded Ad Display Failed: ${error.errorMessage}');
    _isAdLoaded = false;
    _grantReward();
    loadAd();
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    debugPrint('[RewardedAdManager] LevelPlay Rewarded Ad Closed');
    _isAdLoaded = false;
    loadAd();
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    debugPrint('[RewardedAdManager] LevelPlay Rewarded Ad Clicked');
  }

  @override
  void onAdRewarded(LevelPlayReward reward, LevelPlayAdInfo adInfo) {
    debugPrint('[RewardedAdManager] LevelPlay Reward Granted: ${reward.amount} ${reward.label}');
    _grantReward();
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}
}

/// Full-screen Test Rewarded Ad UI for development preview
class _TestRewardedScreen extends StatefulWidget {
  final String adUnitId;
  final VoidCallback onRewardClaimed;
  final VoidCallback onSkipped;

  const _TestRewardedScreen({
    required this.adUnitId,
    required this.onRewardClaimed,
    required this.onSkipped,
  });

  @override
  State<_TestRewardedScreen> createState() => _TestRewardedScreenState();
}

class _TestRewardedScreenState extends State<_TestRewardedScreen> {
  int _countdown = 5;
  Timer? _timer;
  bool _canClaim = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
        setState(() {
          _countdown = 0;
          _canClaim = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF131127), Color(0xFF070612)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFF5A623).withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF5A623), Color(0xFFFF5722)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.stars_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'REWARDED TEST AD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _canClaim ? Icons.close_rounded : Icons.timer,
                        color: Colors.white70,
                        size: 24,
                      ),
                      onPressed: _canClaim ? widget.onSkipped : null,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Reward Trophy Icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF5A623), Color(0xFFFF5722)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF5A623).withValues(alpha: 0.5),
                      blurRadius: 28,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 58,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Watch Ad to Earn 50 Canvas Credits',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Placement: ${widget.adUnitId}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),

              const Spacer(),

              // Claim Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canClaim ? const Color(0xFFF5A623) : Colors.white24,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _canClaim ? widget.onRewardClaimed : null,
                  child: Text(
                    _canClaim ? 'Claim Reward & Continue ✨' : 'Reward unlocks in $_countdown s',
                    style: TextStyle(
                      color: _canClaim ? Colors.black : Colors.white60,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
