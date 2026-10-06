# Flutter Keep Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugins.** { *; }

# App Package & MainActivity
-keep class com.novasoftstudio.soundcanvas.** { *; }
-keepclassmembers class com.novasoftstudio.soundcanvas.** { *; }

# Dart JNI Bridges (Required for LevelPlay Mediation)
-keep class com.github.dart_lang.jni.** { *; }
-keep class com.github.dart_lang.jni_flutter.** { *; }
-dontwarn com.github.dart_lang.jni.**
-dontwarn com.github.dart_lang.jni_flutter.**

# Unity Ads & LevelPlay Flutter Plugins
-keep class com.rebeloid.unity_ads.** { *; }
-keep class com.unity3d.flutter.** { *; }
-dontwarn com.rebeloid.unity_ads.**
-dontwarn com.unity3d.flutter.**

# IronSource & Unity LevelPlay Mediation SDK
-keepclassmembers class * implements com.ironsource.mediationsdk.sdk.RewardBasedVideoAdapterApi { *; }
-keepclassmembers class * implements com.ironsource.mediationsdk.sdk.InterstitialAdapterApi { *; }
-keepclassmembers class * implements com.ironsource.mediationsdk.sdk.BannerAdapterApi { *; }
-keep class com.ironsource.mediationsdk.** { *; }
-keep class com.ironsource.lifecycle.** { *; }
-keep class com.ironsource.environment.** { *; }
-keep class com.ironsource.sdk.** { *; }
-keep class com.unity3d.mediation.** { *; }
-dontwarn com.ironsource.**
-dontwarn com.unity3d.mediation.**

# Unity Ads SDK
-keep class com.unity3d.services.** { *; }
-keep class com.unity3d.ads.** { *; }
-dontwarn com.unity3d.services.**
-dontwarn com.unity3d.ads.**

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Kotlin Coroutines
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# Google Play Core Deferred Components
-dontwarn com.google.android.play.core.**
