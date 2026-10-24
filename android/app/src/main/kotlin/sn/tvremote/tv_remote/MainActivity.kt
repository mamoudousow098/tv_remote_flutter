package sn.tvremote.tv_remote

import android.content.Context
import android.content.pm.PackageManager
import android.hardware.ConsumerIrManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Activité unique de l'application.
 *
 * Étape 1 : canal "tv_remote/capabilities" qui décrit le matériel.
 * Étape 2 : ajout du canal "tv_remote/ir" (émission via ConsumerIrManager).
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val CAPABILITIES_CHANNEL = "tv_remote/capabilities"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAPABILITIES_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getCapabilities" -> result.success(readCapabilities())
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Lit les capacités matérielles sans jamais lever d'exception :
     * certains fabricants renvoient null ou plantent dans ConsumerIrManager.
     */
    private fun readCapabilities(): Map<String, Any?> {
        val irManager: ConsumerIrManager? = try {
            getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
        } catch (e: Exception) {
            null
        }

        val hasIr = try {
            irManager?.hasIrEmitter() == true
        } catch (e: Exception) {
            false
        }

        // Liste de [min, max] en Hz ; souvent vide ou null selon le fabricant
        val frequencies: List<List<Int>> = if (hasIr) {
            try {
                irManager?.carrierFrequencies
                    ?.map { listOf(it.minFrequency, it.maxFrequency) }
                    ?: emptyList()
            } catch (e: Exception) {
                emptyList()
            }
        } else {
            emptyList()
        }

        return mapOf(
            "hasIrEmitter" to hasIr,
            "carrierFrequencies" to frequencies,
            "hasWifi" to packageManager.hasSystemFeature(PackageManager.FEATURE_WIFI),
            "sdkInt" to Build.VERSION.SDK_INT,
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
        )
    }
}
