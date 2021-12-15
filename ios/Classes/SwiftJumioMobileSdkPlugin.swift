import Flutter
import UIKit

public class SwiftJumioMobileSdkPlugin: NSObject, FlutterPlugin {
    private let jumioModule = JumioModuleFlutter()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.jumio.fluttersdk", binaryMessenger: registrar.messenger())
        let instance = SwiftJumioMobileSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            jumioModule.initialize(call: call, result: result)
        case "start":
            jumioModule.start(result: result)
        default:
            break
        }
    }
}
