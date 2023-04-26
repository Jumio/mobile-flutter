package com.jumio.jumiomobilesdk

import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class JumioMobileSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener, PluginRegistry.RequestPermissionsResultListener {
    companion object{
        private const val CHANNEL_NAME = "com.jumio.fluttersdk"
    }

    private lateinit var channel: MethodChannel

    private val modules: List<JumioMobileSdkModule> = listOf(
        JumioModule()
    )

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        setupActivityBindings(binding)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        setupActivityBindings(binding)
    }

    private fun setupActivityBindings(binding: ActivityPluginBinding) {
        binding.addActivityResultListener(this)
        binding.addRequestPermissionsResultListener(this)
        modules.forEach { it.bindToActivity(binding.activity) }
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onDetachedFromActivity() {}

    override fun onMethodCall(call: MethodCall, result: Result) {
        modules.filter { it.handlesMethod(call.method) }.forEach { it.handleMethodCall(call, result) }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        val results = modules.map { it.handleActivityResult(requestCode, resultCode, data) }
        return results.any { it }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        val results = modules.map { it.handlePermissionResult(requestCode, permissions, grantResults) }
        return results.any { it }
    }
}