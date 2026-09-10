# Complete Unity LevelPlay & Unity Ads Integration Guide

This document contains the complete end-to-end setup for **Unity LevelPlay Mediation**, **Unity Ads**, and **Flutter** mobile integration.

---

## 1. Credentials Reference

| Parameter                                    | Value                    | Location in Dashboard                           |
| :------------------------------------------- | :----------------------- | :---------------------------------------------- |
| **LevelPlay AppKey**                   | `27977c8bd`            | LevelPlay Dashboard -> Apps                     |
| **Banner Ad Unit ID**                  | `yleah8iqe2n6cazu`     | LevelPlay Dashboard -> Ad Units -> Banner       |
| **Interstitial Ad Unit ID**            | `q232dj5takb2tgch`     | LevelPlay Dashboard -> Ad Units -> Interstitial |
| **Unity Ads Game ID**                  | `800274942`            | Unity Ads Dashboard -> Monetization             |
| **Unity Ads Placement (Banner)**       | `Banner_Android`       | Unity Ads Dashboard -> Placements               |
| **Unity Ads Placement (Interstitial)** | `Interstitial_Android` | Unity Ads Dashboard -> Placements               |

---

## 2. Step-by-Step Dashboard Setup

### Step 2.1: Unity Cloud Dashboard Setup

1. Log in to the [Unity Cloud Dashboard](https://dashboard.unity3d.com/).
2. Select your Organization -> Go to **Organization Settings**.
3. Copy your **Organization ID**.
4. Navigate to **Monetization** -> **Setup** -> **API Management**.
5. Copy your **Secret Key / Service Account API Key**.
6. Under **Monetization** -> **Placements**, copy:
   - **Game ID**: `800274942`
   - **Banner Placement ID**: `Banner_Android`
   - **Interstitial Placement ID**: `Interstitial_Android`

---

### Step 2.2: ironSource / LevelPlay Dashboard Setup

1. Log in to the [ironSource LevelPlay Dashboard](https://platform.ironsrc.com/).
2. Navigate to **Apps** -> Click **Add App**.
3. Name your app `testapp` (Platform: **Android**).
4. Save to generate your **AppKey**: `27977c8bd`.

#### Create LevelPlay Ad Units:

1. Go to **LevelPlay** -> **Ad Units**.
2. Click **Create Ad Unit**:
   - **Format**: `Banner`
   - **Name**: `home screen banner ad`
   - **Generated ID**: `yleah8iqe2n6cazu`
3. Click **Create Ad Unit** again:
   - **Format**: `Interstitial`
   - **Name**: `interstitial ads`
   - **Generated ID**: `q232dj5takb2tgch`

---

### Step 2.3: Link Unity Ads inside LevelPlay Mediation

1. In LevelPlay Dashboard, go to **LevelPlay** -> **SDK Networks**.
2. Click **Manage Networks** -> Select **Unity Ads**.
3. Enter Connection Credentials:
   - **API Key / Secret Key**: *(Pasted from Step 2.1)*
   - **Organization ID**: *(Pasted from Step 2.1)*
4. Save and configure **Ad Unit & Placement Mapping**:
   - Map `yleah8iqe2n6cazu` -> `Banner_Android` (Game ID `800274942`)
   - Map `q232dj5takb2tgch` -> `Interstitial_Android` (Game ID `800274942`)
5. Click **Save & Activate**.

---

## 3. Flutter App Integration

### Step 3.1: pubspec.yaml Setup

```yaml
name: testapp
description: Flutter Discover Mobile App with Unity LevelPlay Mediation

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0
  unity_levelplay_mediation: '>=9.1.0 <9.2.0'
  unity_ads_plugin: ^0.4.0
```

Run in terminal:

```bash
flutter pub get
```

---

### Step 3.2: Android Gradle Repository & Manifest Setup

#### 1. Add Repositories (`android/settings.gradle.kts`)

LevelPlay adapters are hosted on ironSource's official Maven repository (`https://android-sdk.is.com/`). Add it alongside Flutter's repository:

```kotlin
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven {
            url = java.net.URI.create("https://storage.googleapis.com/download.flutter.io")
        }
        maven {
            url = java.net.URI.create("https://android-sdk.is.com/")
        }
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven {
            url = java.net.URI.create("https://storage.googleapis.com/download.flutter.io")
        }
        maven {
            url = java.net.URI.create("https://android-sdk.is.com/")
        }
    }
}
```

#### 3. Manifest Permissions (`android/app/src/main/AndroidManifest.xml`)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Network Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
  
    <!-- Google Advertising ID Permission (Required for LevelPlay Attribution) -->
    <uses-permission android:name="com.google.android.gms.permission.AD_ID"/>

    <application
        android:label="testapp"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
      
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/ValueTheme"/>
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
      
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

---

### Step 3.3: AdManager Singleton (`lib/ads/ad_manager.dart`)

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'interstitial_ad_manager.dart';

class AdManager implements LevelPlayInitListener {
  static final AdManager instance = AdManager._internal();
  factory AdManager() => instance;
  AdManager._internal();

  static const String defaultAppKey = "27977c8bd";
  static const String defaultBannerAdUnitId = "yleah8iqe2n6cazu";
  static const String defaultInterstitialAdUnitId = "q232dj5takb2tgch";

  String appKey = defaultAppKey;
  String bannerAdUnitId = defaultBannerAdUnitId;
  String interstitialAdUnitId = defaultInterstitialAdUnitId;

  bool isInitialized = false;
  bool isInitializing = false;
  bool isTestMode = true;
  bool isUnityAdsEngine = false;

  Completer<bool>? _initCompleter;
  final StreamController<bool> _initStatusController = StreamController<bool>.broadcast();
  Stream<bool> get onInitStatusChanged => _initStatusController.stream;

  Future<void> initialize({
    String? appKeyOverride,
    String? bannerAdUnitOverride,
    String? interstitialAdUnitOverride,
    bool enableTestMode = true,
  }) async {
    if (isInitialized) return;
    if (isInitializing && _initCompleter != null) {
      await _initCompleter!.future;
      return;
    }

    isInitializing = true;
    isTestMode = enableTestMode;
    _initCompleter = Completer<bool>();

    if (appKeyOverride != null) appKey = appKeyOverride;
    if (bannerAdUnitOverride != null) bannerAdUnitId = bannerAdUnitOverride;
    if (interstitialAdUnitOverride != null) interstitialAdUnitId = interstitialAdUnitOverride;

    final isNumericGameId = RegExp(r'^\d+$').hasMatch(appKey);
    debugPrint('[AdManager] Starting Init with AppKey: $appKey (isNumericGameId: $isNumericGameId)');

    if (isNumericGameId) {
      isUnityAdsEngine = true;
      try {
        await UnityAds.init(
          gameId: appKey,
          testMode: isTestMode,
          onComplete: () => _onInitSuccessComplete(),
          onFailed: (error, message) => _onInitFailedComplete(),
        );
      } catch (e) {
        _onInitFailedComplete();
      }
      isInitializing = false;
      return;
    }

    isUnityAdsEngine = false;
    try {
      if (isTestMode) {
        await LevelPlay.setMetaData({'is_test_suite': ['enable']});
        await LevelPlay.setAdaptersDebug(true);
      }

      final initRequest = LevelPlayInitRequest.builder(appKey).build();
      await LevelPlay.init(initRequest: initRequest, initListener: this);
    } catch (e) {
      _onInitFailedComplete();
    }

    try {
      await _initCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => isInitialized,
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
  }

  void _onInitFailedComplete() {
    isInitialized = false;
    isInitializing = false;
    _initStatusController.add(false);
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      _initCompleter!.complete(false);
    }
  }

  Future<void> launchTestSuite() async {
    if (!isInitialized) return;
    await LevelPlay.launchTestSuite();
  }

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    debugPrint('[AdManager] LevelPlay SDK Initialized Successfully!');
    _onInitSuccessComplete();
  }

  @override
  void onInitFailed(LevelPlayInitError error) {
    debugPrint('[AdManager] LevelPlay SDK Init Failed: ${error.errorMessage}');
    _onInitFailedComplete();
  }
}
```

---

### Step 3.4: Banner Ad Component (`lib/ads/banner_ad_widget.dart`)

Placed **directly below `SearchSection`**:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'ad_manager.dart';

class BannerAdWidget extends StatefulWidget {
  final LevelPlayAdSize? adSize;
  const BannerAdWidget({super.key, this.adSize});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> implements LevelPlayBannerAdViewListener {
  final GlobalKey<LevelPlayBannerAdViewState> _bannerKey = GlobalKey<LevelPlayBannerAdViewState>();
  bool _isBannerFailed = false;
  StreamSubscription<bool>? _initSubscription;

  @override
  void initState() {
    super.initState();
    if (!AdManager.instance.isInitialized) {
      _initSubscription = AdManager.instance.onInitStatusChanged.listen((success) {
        if (success && mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _initSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      alignment: Alignment.center,
      child: _buildBannerContent(),
    );
  }

  Widget _buildBannerContent() {
    if (!AdManager.instance.isInitialized) {
      return const SizedBox(height: 50);
    }

    if (_isBannerFailed) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        child: const Text('Sponsor Spotlight', style: TextStyle(color: Color(0xFF73809C))),
      );
    }

    if (AdManager.instance.isUnityAdsEngine) {
      return UnityBannerAd(
        placementId: AdManager.instance.bannerAdUnitId,
        onLoad: (pId) => setState(() => _isBannerFailed = false),
        onFailed: (pId, error, msg) => setState(() => _isBannerFailed = true),
      );
    }

    return LevelPlayBannerAdView(
      key: _bannerKey,
      adUnitId: AdManager.instance.bannerAdUnitId,
      adSize: widget.adSize ?? LevelPlayAdSize.BANNER,
      listener: this,
      onPlatformViewCreated: () {
        _bannerKey.currentState?.loadAd();
      },
    );
  }

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    if (mounted) setState(() => _isBannerFailed = false);
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    if (mounted) setState(() => _isBannerFailed = true);
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}
  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}
  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {}
  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {}
  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {}
  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {}
}
```

---

### Step 3.5: Interstitial Ad Manager (`lib/ads/interstitial_ad_manager.dart`)

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
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

  Future<void> loadAd() async {
    if (!AdManager.instance.isInitialized || _isAdLoaded || _isLoading) return;
    _isLoading = true;

    try {
      if (!AdManager.instance.isUnityAdsEngine) {
        _interstitialAd ??= LevelPlayInterstitialAd(adUnitId: AdManager.instance.interstitialAdUnitId);
        _interstitialAd!.setListener(this);
        await _interstitialAd!.loadAd();
      } else {
        await UnityAds.load(
          placementId: AdManager.instance.interstitialAdUnitId,
          onComplete: (pId) {
            _isAdLoaded = true;
            _isLoading = false;
          },
          onFailed: (pId, error, msg) => _isLoading = false,
        );
      }
    } catch (e) {
      _isLoading = false;
    }
  }

  /// Triggers Interstitial Ad on 2nd Click
  Future<void> showInterstitialWithFallback({required VoidCallback onProceed}) async {
    if (!AdManager.instance.isInitialized) {
      onProceed();
      return;
    }

    _currentOnProceedCallback = onProceed;

    if (!AdManager.instance.isUnityAdsEngine) {
      if (_interstitialAd != null) {
        try {
          final ready = await _interstitialAd!.isAdReady();
          if (ready) {
            await _interstitialAd!.showAd();
            return;
          }
        } catch (e) {
          debugPrint('[InterstitialAdManager] LevelPlay Exception: $e');
        }
      }
      _executeOnProceed();
      loadAd();
      return;
    }

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

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    _isAdLoaded = true;
    _isLoading = false;
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    _isLoading = false;
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    _isAdLoaded = false;
    _executeOnProceed();
    loadAd();
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}
  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    _isAdLoaded = false;
    _executeOnProceed();
    loadAd();
  }
  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}
  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}
}
```

---

### Step 3.6: 2-Click Interstitial Action Handler (`lib/screens/discover_screen.dart`)

```dart
int _clickCounter = 0;

void _handleActionWithInterstitial(VoidCallback action, String actionName) {
  _clickCounter++;
  debugPrint('[DiscoverScreen] Clicked $actionName. Count: $_clickCounter/2');

  if (_clickCounter >= 2) {
    _clickCounter = 0; // Reset counter
    InterstitialAdManager.instance.showInterstitialWithFallback(
      onProceed: () => action(),
    );
  } else {
    // 1st Click -> Proceed immediately
    action();
  }
}
```

---

## 4. Testing & Verification

1. **Testing Account Pending Approval**:

   - LevelPlay returns `Mediation No fill` until your ironSource account is approved by Unity/ironSource.
   - Non-blocking fallbacks in code ensure user actions execute immediately.
2. **Integration Test Suite**:

   - Tap the top-left menu icon to open `AdManager.instance.launchTestSuite()`.
   - Load and test Banner and Interstitial ad formats directly on your emulator.
3. **Register Test Device**:

   - LevelPlay Dashboard -> **Testing** -> **Test Devices** -> Add your device Advertising ID (`3b666e81-ac4e-4760-a88d-13c20d0d9338`).
