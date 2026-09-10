package com.novasoftstudio.soundcanvas

import android.os.Bundle
import android.util.Log
import com.google.android.gms.ads.identifier.AdvertisingIdClient
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.novasoftstudio.soundcanvas/device_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAdId") {
                CoroutineScope(Dispatchers.IO).launch {
                    try {
                        val adInfo = AdvertisingIdClient.getAdvertisingIdInfo(applicationContext)
                        val adId = adInfo.id ?: "00000000-0000-0000-0000-000000000000"
                        val isLAT = adInfo.isLimitAdTrackingEnabled
                        Log.i("AdManager_Native", "=======================================================")
                        Log.i("AdManager_Native", "DEVICE ADVERTISING ID (ADID / GAID): $adId")
                        Log.i("AdManager_Native", "Limit Ad Tracking Enabled: $isLAT")
                        Log.i("AdManager_Native", "=======================================================")
                        withContext(Dispatchers.Main) {
                            result.success(adId)
                        }
                    } catch (e: Exception) {
                        Log.e("AdManager_Native", "Failed to fetch ADID: ${e.message}")
                        withContext(Dispatchers.Main) {
                            result.error("ADID_ERROR", e.message, null)
                        }
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Automatically fetch and log ADID on startup
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val adInfo = AdvertisingIdClient.getAdvertisingIdInfo(applicationContext)
                val adId = adInfo.id ?: "00000000-0000-0000-0000-000000000000"
                Log.i("AdManager_Native", "=======================================================")
                Log.i("AdManager_Native", "DEVICE ADVERTISING ID (ADID / GAID): $adId")
                Log.i("AdManager_Native", "=======================================================")
            } catch (e: Exception) {
                Log.e("AdManager_Native", "Error retrieving Advertising ID: ${e.message}")
            }
        }
    }
}
