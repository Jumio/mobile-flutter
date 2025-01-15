package com.jumio.jumiomobilesdk_example

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    @Override
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        var flutterEngine = flutterEngine
        if (flutterEngine == null) {
           flutterEngine = FlutterEngine(this)
        }
        return flutterEngine
    }
}