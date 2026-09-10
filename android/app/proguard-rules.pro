# Flutter Keep Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }

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

# Google Play Services Advertising ID
-keep class com.google.android.gms.ads.identifier.** { *; }
-dontwarn com.google.android.gms.ads.identifier.**
