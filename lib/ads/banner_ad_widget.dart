import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'ad_manager.dart';
import '../widgets/glass_container.dart';

class BannerAdWidget extends StatefulWidget {
  final LevelPlayAdSize? adSize;
  const BannerAdWidget({
    super.key,
    this.adSize,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with AutomaticKeepAliveClientMixin
    implements LevelPlayBannerAdViewListener {
  bool _bannerFailed = false;
  bool _bannerLoaded = false;
  final GlobalKey<LevelPlayBannerAdViewState> _bannerKey = GlobalKey<LevelPlayBannerAdViewState>();
  StreamSubscription<bool>? _initSubscription;
  Timer? _retryTimer;

  @override
  bool get wantKeepAlive => true;

  LevelPlayAdSize get effectiveAdSize => widget.adSize ?? LevelPlayAdSize.BANNER;

  @override
  void initState() {
    super.initState();
    if (!AdManager.instance.isInitialized) {
      _initSubscription = AdManager.instance.onInitStatusChanged.listen((success) {
        if (success && mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _initSubscription?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      alignment: Alignment.center,
      child: GlassContainer(
        height: 66,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        backgroundColor: Colors.white.withValues(alpha: 0.90),
        borderColor: Colors.white.withValues(alpha: 0.95),
        child: Center(child: _buildBannerContent()),
      ),
    );
  }

  Widget _buildBannerContent() {
    if (!AdManager.instance.isInitialized) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF5B46F6),
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Initializing LevelPlay Ads...',
            style: TextStyle(
              color: Color(0xFF73809C),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }

    // Direct Unity Ads Placement (if numerical Game ID)
    if (AdManager.instance.isUnityAdsEngine) {
      return UnityBannerAd(
        placementId: AdManager.instance.bannerAdUnitId,
        onLoad: (placementId) {
          debugPrint('[BannerAdWidget] Unity Banner Loaded: $placementId');
          if (mounted) setState(() => _bannerFailed = false);
        },
        onFailed: (placementId, error, message) {
          debugPrint('[BannerAdWidget] Unity Banner Failed: $error $message');
          if (mounted) setState(() => _bannerFailed = true);
        },
      );
    }

    // Interactive Test Banner Fallback when account is pending approval or no-fill
    if (_bannerFailed) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B46F6), Color(0xFF8E37F5)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'TEST AD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'LevelPlay Banner Active',
                  style: TextStyle(
                    color: Color(0xFF0A1020),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'AppKey: 27977c8bd • Retrying live fill...',
                  style: TextStyle(
                    color: Color(0xFF73809C),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.refresh_rounded, color: Color(0xFF5B46F6), size: 18),
        ],
      );
    }

    // LevelPlay Banner Ad View (320x50 standard banner)
    return SizedBox(
      width: 320,
      height: 50,
      child: LevelPlayBannerAdView(
        key: _bannerKey,
        adUnitId: AdManager.instance.bannerAdUnitId,
        adSize: effectiveAdSize,
        listener: this,
        onPlatformViewCreated: () {
          debugPrint('[BannerAdWidget] LevelPlay Banner View Created. Requesting load...');
          _bannerKey.currentState?.loadAd();
        },
      ),
    );
  }

  // --- LevelPlayBannerAdViewListener Callbacks ---

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    debugPrint('[BannerAdWidget] LevelPlay Banner Loaded Successfully: ${adInfo.adUnitId}');
    _bannerLoaded = true;
    _bannerFailed = false;
    _retryTimer?.cancel();
    if (mounted) setState(() {});
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    debugPrint('[BannerAdWidget] LevelPlay Banner Load Failed (Code: ${error.errorCode}): ${error.errorMessage}');
    _bannerLoaded = false;
    _bannerFailed = true;
    if (mounted) setState(() {});

    // Automatically retry banner load after 20 seconds
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 20), () {
      if (mounted && !_bannerLoaded) {
        setState(() => _bannerFailed = false);
        _bannerKey.currentState?.loadAd();
      }
    });
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    debugPrint('[BannerAdWidget] Banner Clicked: ${adInfo.adUnitId}');
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    debugPrint('[BannerAdWidget] Banner Displayed: ${adInfo.adUnitId}');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {
    debugPrint('[BannerAdWidget] Banner Display Failed: ${error.errorMessage}');
  }

  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {}
  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {}
  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {}
}
