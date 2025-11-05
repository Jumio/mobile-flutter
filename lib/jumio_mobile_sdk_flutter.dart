import 'dart:async';

import 'package:flutter/services.dart';

class Jumio {
  static const MethodChannel _channel =
      const MethodChannel('com.jumio.fluttersdk');

  static Future<void> init(String authorizationToken, String dataCenter) async {
    await _channel.invokeMethod('init',
        {'authorizationToken': authorizationToken, 'dataCenter': dataCenter});
  }

  static Future<Map<dynamic, dynamic>> start(
      [Map<String, dynamic>? customizations]) async {
    return await _channel
        .invokeMethod('start', {'customizations': customizations});
  }

  static Future<void> setPreloaderFinishedBlock(Function completion) async {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'preloadFinished') {
        completion();
      }
    });
    return await _channel.invokeMethod('setPreloaderFinishedBlock');
  }

  static Future<void> preloadIfNeeded() async {
    return await _channel.invokeMethod('preloadIfNeeded');
  }
  static Future<dynamic> getCachedResult() async {
    return await _channel.invokeMethod('getCachedResult');
  }
}
