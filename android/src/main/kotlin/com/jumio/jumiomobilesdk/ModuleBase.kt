package com.jumio.jumiomobilesdk

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.ActivityCompat
import com.jumio.sdk.JumioSDK
import io.flutter.plugin.common.MethodChannel

abstract class ModuleBase : JumioMobileSdkModule {
    protected lateinit var hostActivity: Activity private set
    private var currentAsyncProcessCallback: MethodChannel.Result? = null

    var onHostActivitySet: (() -> Unit)? = null

    companion object {
        private const val PERMISSION_REQUEST_CODE_NETVERIFY = 303
        private var onPermissionGranted: (() -> Unit)? = null
        private var onPermissionDenied: (() -> Unit)? = null
    }

    protected fun sendResult(value: Any?): Boolean {
        currentAsyncProcessCallback?.let {
            it.success(value)
            currentAsyncProcessCallback = null
            return true
        }
        return false
    }

    protected fun showErrorMessage(msg: String, code: String? = null): Boolean {
        Log.e("Error", msg)
        currentAsyncProcessCallback?.let {
            it.error(code ?: "sdkError", msg, null)
            currentAsyncProcessCallback = null
            return true
        }
        return false
    }

    protected fun ensurePermissionsAndRun(onGranted: () -> Unit, onDenied: () -> Unit) {
        if (!JumioSDK.hasAllRequiredPermissions(hostActivity)) {
            onPermissionGranted = onGranted
            onPermissionDenied = onDenied

            val missingPermissions = JumioSDK.getMissingPermissions(hostActivity)
            ActivityCompat.requestPermissions(hostActivity, missingPermissions, PERMISSION_REQUEST_CODE_NETVERIFY)
        } else {
            onGranted()
        }
    }

    final override fun setResultHandler(result: MethodChannel.Result) {
        currentAsyncProcessCallback = result
    }

    final override fun bindToActivity(activity: Activity) {
        hostActivity = activity
        onHostActivitySet?.invoke()
    }

    final override fun handlePermissionResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?): Boolean {
        if (requestCode != PERMISSION_REQUEST_CODE_NETVERIFY) {
            return false
        }

        val allGranted = grantResults != null && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        if (allGranted) onPermissionGranted?.invoke() else onPermissionDenied?.invoke()

        onPermissionGranted = null
        onPermissionDenied = null
        return true
    }

    override fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?) = false
}