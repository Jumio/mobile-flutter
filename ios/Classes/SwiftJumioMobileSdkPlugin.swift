import Flutter
import UIKit

public class SwiftJumioMobileSdkPlugin: NSObject, FlutterPlugin {
    private let jumioModule = JumioModuleFlutter()
    private static var flutterMethodChannel: FlutterMethodChannel? = nil

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.jumio.fluttersdk", binaryMessenger: registrar.messenger())
        flutterMethodChannel = channel
        let instance = SwiftJumioMobileSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            jumioModule.initialize(call: call, result: result)
        case "start":
            jumioModule.start(call: call, result: result)
        case "setPreloaderFinishedBlock":
            jumioModule.setPreloaderFinishedBlock(call: call, result: result, channel: SwiftJumioMobileSdkPlugin.flutterMethodChannel)
        case "preloadIfNeeded":
            jumioModule.preloadIfNeeded(call: call, result: result)
        default:
            break
        }
    }
}
