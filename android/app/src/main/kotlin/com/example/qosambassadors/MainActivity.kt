package com.example.qosambassadors

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.telephony.TelephonyManager
import android.util.Log
import android.content.Context.TELEPHONY_SERVICE


class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    if (call.method == "getTypeDeReseau") {
                        val typeDeReseau = typeDeReseau
                        result.success(typeDeReseau)
                    }
                    else {
                        result.notImplemented()
                    }
                }
    }

    private val typeDeReseau: String
        get() {
            val telephonyManager: TelephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
            val networkType: Int = telephonyManager.networkType

            Log.d("NetworkType", "networkType: $networkType") // Ajout pour le débogage

            return when (networkType) {
                TelephonyManager.NETWORK_TYPE_IWLAN -> "Wifi"
                TelephonyManager.NETWORK_TYPE_LTE -> "4G"
                TelephonyManager.NETWORK_TYPE_HSPAP, TelephonyManager.NETWORK_TYPE_UMTS -> "3G"
                TelephonyManager.NETWORK_TYPE_NR -> "5G"
                else -> "inconnu"
            }.also { Log.d("NetworkType", "Type de réseau détecté: $it") } // Log le résultat
        }


    companion object {
        private const val CHANNEL = "com.example/connectivity"
    }
}
