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
    final adUnitId = AdManager.instance.interstitialAdUnitId;

    try {
      debugPrint('[InterstitialAdManager] Loading Interstitial Ad: $adUnitId');

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

  /// Triggers Interstitial Ad with Test Overlay fallback on 2nd Click
  Future<void> showInterstitialWithFallback({
    required VoidCallback onProceed,
    BuildContext? context,
  }) async {
    _currentOnProceedCallback = onProceed;
    final placementId = AdManager.instance.interstitialAdUnitId;

    // 1. LevelPlay Interstitial Display
    if (!AdManager.instance.isUnityAdsEngine) {
      if (_interstitialAd != null) {
        try {
          final ready = await _interstitialAd!.isAdReady();
          if (ready) {
            debugPrint('[InterstitialAdManager] Showing LevelPlay Interstitial Ad: $placementId');
            await _interstitialAd!.showAd();
            return;
          }
        } catch (e) {
          debugPrint('[InterstitialAdManager] LevelPlay show exception: $e');
        }
      }

      // Show Full-Screen Test Interstitial Modal if context provided, otherwise execute action
      if (context != null && context.mounted) {
        _showTestInterstitialDialog(context);
      } else {
        _executeOnProceed();
        loadAd();
      }
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
            if (context != null && context.mounted) {
              _showTestInterstitialDialog(context);
            } else {
              _executeOnProceed();
              loadAd();
            }
          },
        );
        return;
      } catch (e) {
        debugPrint('[InterstitialAdManager] Exception displaying Unity Video Ad: $e');
      }
    }

    // Fallback if ad is still loading
    if (context != null && context.mounted) {
      _showTestInterstitialDialog(context);
    } else {
      _executeOnProceed();
      loadAd();
    }
  }

  void _showTestInterstitialDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _TestInterstitialScreen(
          adUnitId: AdManager.instance.interstitialAdUnitId,
          onClose: () {
            Navigator.of(dialogContext).pop();
            _executeOnProceed();
            loadAd();
          },
        );
      },
    );
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
    debugPrint('[InterstitialAdManager] LevelPlay Interstitial Displayed');
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
    debugPrint('[InterstitialAdManager] LevelPlay Interstitial Closed by user.');
    _isAdLoaded = false;
    _executeOnProceed();
    loadAd();
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    debugPrint('[InterstitialAdManager] LevelPlay Interstitial Clicked');
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}
}

/// Full-screen Test Interstitial Ad UI for development preview
class _TestInterstitialScreen extends StatefulWidget {
  final String adUnitId;
  final VoidCallback onClose;
  const _TestInterstitialScreen({
    required this.adUnitId,
    required this.onClose,
  });

  @override
  State<_TestInterstitialScreen> createState() => _TestInterstitialScreenState();
}

class _TestInterstitialScreenState extends State<_TestInterstitialScreen> {
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
        setState(() => _countdown = 0);
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
              colors: [Color(0xFF1E1E2E), Color(0xFF0F0C20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              // Top Bar with Skip/Close button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B46F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'TEST INTERSTITIAL AD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _countdown == 0 ? Icons.close_rounded : Icons.timer,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: _countdown == 0 ? widget.onClose : null,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Center Ad Preview Graphic
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B46F6), Color(0xFF8E37F5)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B46F6).withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 54,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'LevelPlay Video Interstitial Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ad Unit: ${widget.adUnitId}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),

              const Spacer(),

              // Bottom Skip/Continue Action Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B46F6),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: widget.onClose,
                  child: Text(
                    _countdown > 0 ? 'Skip Ad in $_countdown s' : 'Close Ad & Proceed',
                    style: const TextStyle(
                      color: Colors.white,
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
