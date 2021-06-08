import Flutter
import JumioCore
import Netverify
import UIKit

public class SwiftJumioMobileSdkPlugin: NSObject, FlutterPlugin {
    private let netverifyModule:            NetverifyModuleFlutter  = NetverifyModuleFlutter()
    private let documentVerificaitonModule: JumioMobileSdkModule    = DocumentVerificationModuleFlutter()
    private let bamCheckoutModule:          JumioMobileSdkModule    = BAMCheckoutModuleFlutter()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.jumio.fluttersdk", binaryMessenger: registrar.messenger())
        let instance = SwiftJumioMobileSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initNetverify":
            netverifyModule.initialize(call: call, result: result)
        case "initSingleSessionNetverify":
            netverifyModule.initializeSingleSession(call: call, result: result)
        case "startNetverify":
            netverifyModule.start(result: result)
        case "initDocumentVerification":
            documentVerificaitonModule.initialize(call: call, result: result)
        case "startDocumentVerification":
            documentVerificaitonModule.start(result: result)
        case "initBAM":
            bamCheckoutModule.initialize(call: call, result: result)
        case "startBAM":
            bamCheckoutModule.start(result: result)
        default:
            break
        }
    }
}
