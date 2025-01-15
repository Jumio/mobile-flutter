import Foundation

protocol JumioMobileSdkModule {
    var result: FlutterResult? { get set }
    func initialize(call: FlutterMethodCall, result: @escaping FlutterResult)
    func start(call: FlutterMethodCall, result: @escaping FlutterResult)
    func setPreloaderFinishedBlock(call: FlutterMethodCall, result: @escaping FlutterResult, channel: FlutterMethodChannel?)
    func preloadIfNeeded(call: FlutterMethodCall, result: @escaping FlutterResult)
}
