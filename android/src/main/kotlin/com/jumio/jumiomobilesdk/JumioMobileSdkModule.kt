package com.jumio.jumiomobilesdk

import android.app.Activity
import android.content.Intent
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

interface JumioMobileSdkModule {
    val methods: Map<String, (MethodCall) -> Unit>

    fun setResultHandler(result: MethodChannel.Result)
    fun bindToActivity(activity: Activity)
    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean
    fun handlePermissionResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?): Boolean
    
    fun handlesMethod(method: String): Boolean = methods.containsKey(method)
    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        setResultHandler(result)
        methods[call.method]?.invoke(call)
    }
}
