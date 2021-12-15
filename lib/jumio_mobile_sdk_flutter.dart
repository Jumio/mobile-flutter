import 'dart:async';

import 'package:flutter/services.dart';

class Jumio {
  static const MethodChannel _channel =
      const MethodChannel('com.jumio.fluttersdk');

  static Future<void> init(String authorizationToken, String dataCenter) async {
    await _channel.invokeMethod('init',
        {'authorizationToken': authorizationToken, 'dataCenter': dataCenter});
  }

  static Future<Map<dynamic, dynamic>> start() async {
    return await _channel.invokeMethod('start');
  }
}
