import Foundation

protocol JumioMobileSdkModule {
    var result: FlutterResult? { get set }
    func initialize(call: FlutterMethodCall, result: @escaping FlutterResult)
    func start(result: @escaping FlutterResult)
}
