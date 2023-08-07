package dev.movna.app

import android.content.IntentSender
import android.content.Intent
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationSettingsRequest
import com.google.android.gms.location.Priority
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {

    companion object {
        private const val LOCATION_CHANNEL = "dev.movna.app/location"
        private const val ENABLE_LOCATION_METHOD = "enable_service"
        private const val REQUEST_CHECK_SETTINGS = 1
    }

    private var channelResult: MethodChannel.Result? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LOCATION_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == ENABLE_LOCATION_METHOD && channelResult == null) {
                channelResult = result
                enableLocation()
            } else if (call.method == ENABLE_LOCATION_METHOD) {
                result.error("1", "Method has been called and didn't complete yet", null)
            } else result.notImplemented()
        }
    }

    /**
     * This method calls to gms to enable device location service.
     */
    private fun enableLocation() {
        val builder = LocationSettingsRequest.Builder().addLocationRequest(
            LocationRequest.Builder(
                Priority.PRIORITY_HIGH_ACCURACY, 500
            ).build()
        )
        val requestResult =
            LocationServices.getSettingsClient(this).checkLocationSettings(builder.build())
        requestResult.addOnSuccessListener { channelResult?.success(null) }
        requestResult.addOnFailureListener { exception ->
            if (exception is ResolvableApiException) {
                // Location settings are not satisfied, but this can be fixed
                // by showing the user a dialog.
                try {
                    // Show the dialog by calling startResolutionForResult(),
                    // and check the result in onActivityResult().
                    exception.startResolutionForResult(
                        this@MainActivity,
                        REQUEST_CHECK_SETTINGS
                    )
                } catch (sendEx: IntentSender.SendIntentException) {
                    // Ignore the error.
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        when (requestCode) {
            // If request i
            REQUEST_CHECK_SETTINGS -> when (resultCode) {
                RESULT_OK -> {
                    channelResult?.success(null)
                    channelResult = null
                }

                RESULT_CANCELED -> {
                    channelResult?.error("user_canceled", null, null)
                    channelResult = null
                }

                else -> {
                    channelResult?.error("unknown", null, null)
                    channelResult = null
                }
            }
        }
    }

}
