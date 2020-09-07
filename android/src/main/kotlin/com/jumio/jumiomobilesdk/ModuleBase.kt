package com.jumio.jumiomobilesdk

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.ActivityCompat
import com.jumio.MobileSDK
import io.flutter.plugin.common.MethodChannel

abstract class ModuleBase : JumioMobileSdkModule {
    protected lateinit var hostActivity: Activity private set
    private var currentAsyncProcessCallback: MethodChannel.Result? = null
    private var postPermissionsBlock: (() -> Unit)? = null

    protected fun sendResult(value: Any?) {
        currentAsyncProcessCallback?.success(value)
        currentAsyncProcessCallback = null
    }

    protected fun showErrorMessage(msg: String, code: String? = null) {
        Log.e("Error", msg)
        currentAsyncProcessCallback?.error(code ?: "sdkError", msg, null)
        currentAsyncProcessCallback = null
    }

    protected fun ensurePermissionsAndRun(permissionRequestCode : PermissionRequestCode, block: () -> Unit) {
        if (MobileSDK.hasAllRequiredPermissions(hostActivity)) {
            block()
        } else {
            postPermissionsBlock = block

            val missingPermissions = MobileSDK.getMissingPermissions(hostActivity)
            ActivityCompat.requestPermissions(hostActivity, missingPermissions, permissionRequestCode.ordinal)
        }
    }

    final override fun setResultHandler(result: MethodChannel.Result) {
        currentAsyncProcessCallback = result
    }

    final override fun bindToActivity(activity: Activity) {
        hostActivity = activity
    }

    final override fun handlePermissionResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?): Boolean {
        val permissionsGranted = permissions?.size == grantResults?.size && grantResults?.all { it == PackageManager.PERMISSION_GRANTED } == true
        val requestCodeAsEnum = PermissionRequestCode.values().getOrNull(requestCode)
        if (permissionsGranted) {
            postPermissionsBlock?.invoke()
            postPermissionsBlock = null
        }
        return permissionsGranted && requestCodeAsEnum != null
    }

    override fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?) = false
}