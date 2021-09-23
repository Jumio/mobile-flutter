import 'dart:async';

import 'package:flutter/services.dart';

class JumioMobileSDK {
  static const MethodChannel _channel =
      const MethodChannel('com.jumio.fluttersdk');

  static Future<void> initNetverify(String apiToken, String apiSecret,
      String dataCenter, Map<String, dynamic> options,
      [Map<String, dynamic>? customization]) async {
    await _channel.invokeMethod('initNetverify', {
      'apiToken': apiToken,
      'apiSecret': apiSecret,
      'dataCenter': dataCenter,
      'options': options,
      'customization': customization
    });
  }

  static Future<Map<dynamic, dynamic>> startNetverify() async {
    return await _channel.invokeMethod('startNetverify');
  }

  static Future<void> initDocumentVerification(String apiToken,
      String apiSecret, String dataCenter, Map<String, dynamic> options,
      [Map<String, dynamic>? customization]) async {
    await _channel.invokeMethod('initDocumentVerification', {
      'apiToken': apiToken,
      'apiSecret': apiSecret,
      'dataCenter': dataCenter,
      'options': options,
      'customization': customization
    });
  }

  static Future<Map<dynamic, dynamic>> startDocumentVerification() async {
    return await _channel.invokeMethod('startDocumentVerification');
  }

  static Future<void> initBAM(String apiToken, String apiSecret,
      String dataCenter, Map<String, dynamic> options,
      [Map<String, dynamic>? customization]) async {
    await _channel.invokeMethod('initBAM', {
      'apiToken': apiToken,
      'apiSecret': apiSecret,
      'dataCenter': dataCenter,
      'options': options,
      'customization': customization
    });
  }

  static Future<Map<dynamic, dynamic>> startBAM() async {
    return await _channel.invokeMethod('startBAM');
  }

  static Future<void> initSingleSessionNetverify(String authorizationToken,
      String dataCenter, Map<String, dynamic> options,
      [Map<String, dynamic>? customization]) async {
    await _channel.invokeMethod('initSingleSessionNetverify', {
      'authorizationToken': authorizationToken,
      'dataCenter': dataCenter,
      'options': options,
      'customization': customization
    });
  }
}
