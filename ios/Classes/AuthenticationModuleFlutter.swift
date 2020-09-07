import Foundation
import JumioCore
import NetverifyFace

class AuthenticationModuleFlutter: NSObject, JumioMobileSdkModule {
    var result: FlutterResult?
    private var authenticationController: AuthenticationController?
    private var authenticationScanViewController: AuthenticationScanViewController?
    
    func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result
        resetAuthenticationController()
        
        let args = call.arguments as? [String: Any?] ?? [:]
        
        let configuration = AuthenticationConfiguration()
        configuration.delegate = self
        configuration.apiToken = args["apiToken"] as? String ?? ""
        configuration.apiSecret = args["apiSecret"] as? String ?? ""
        configuration.dataCenter = (args["dataCenter"] as? String ?? "").toDataCenter()
        
        setupOptions(args: args, configuration: configuration)
        setupCustomization(args: args)
        
        do {
            try ObjcExceptionHelper.catchException {
                self.authenticationController = AuthenticationController(configuration: configuration)
            }
        } catch {
            let nsError = error as NSError
            result(FlutterError(code: "\(nsError.code)", message: nsError.localizedDescription, details: nil))
        }
    }
    
    private func setupOptions(args: [String: Any?], configuration: AuthenticationConfiguration) {
        let options = args["options"] as? [String: Any?] ?? [:]
        
        if let callbackUrl = options["callbackUrl"] as? String {
            configuration.callbackUrl = callbackUrl
        }
        
        if let userReference = options["userReference"] as? String {
            configuration.userReference = userReference
        }
        
        if let authenticationTransactionReference = options["authenticationTransactionReference"] as? String {
            configuration.authenticationTransactionReference = authenticationTransactionReference
        }
        
        if let enrollmentTransactionReference = options["enrollmentTransactionReference"] as? String {
            configuration.enrollmentTransactionReference = enrollmentTransactionReference
        }
    }
    
    private func setupCustomization(args: [String: Any?]) {
        let customizations = args["customization"] as? [String: Any?] ?? [:]
        
        if let disableBlur = customizations["disableBlur"] as? Bool {
            JumioBaseView.jumioAppearance().disableBlur = disableBlur as NSNumber
        }
        
        if let enableDarkMode = customizations["enableDarkMode"] as? Bool {
            JumioBaseView.jumioAppearance().enableDarkMode = enableDarkMode as NSNumber
        }
        
        if let backgroundColor = customizations["backgroundColor"] as? String {
            JumioBaseView.jumioAppearance().backgroundColor = UIColor(hexString: backgroundColor)
        }
        
        if let tintColor = customizations["tintColor"] as? String {
            UINavigationBar.jumioAppearance().tintColor = UIColor(hexString: tintColor)
        }
        
        if let barTintColor = customizations["barTintColor"] as? String {
            UINavigationBar.jumioAppearance().barTintColor = UIColor(hexString: barTintColor)
        }
        
        if let textTitleColor = customizations["textTitleColor"] as? String {
            UINavigationBar.jumioAppearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: textTitleColor)]
        }
        
        if let foregroundColor = customizations["foregroundColor"] as? String {
            JumioBaseView.jumioAppearance().foregroundColor = UIColor(hexString: foregroundColor)
        }
        
        if let positiveButtonBackgroundColor = customizations["positiveButtonBackgroundColor"] as? String {
            JumioPositiveButton.jumioAppearance().backgroundColor = UIColor(hexString: positiveButtonBackgroundColor)
        }
        
        if let positiveButtonBorderColor = customizations["positiveButtonBorderColor"] as? String {
            JumioPositiveButton.jumioAppearance().borderColor = UIColor(hexString: positiveButtonBorderColor)
        }
        
        if let positiveButtonTitleColor = customizations["positiveButtonTitleColor"] as? String {
            JumioPositiveButton.jumioAppearance().setTitleColor(UIColor(hexString: positiveButtonTitleColor), for: .normal)
        }
        
        if let faceOvalColor = customizations["faceOvalColor"] as? String {
            JumioScanOverlayView.jumioAppearance().faceOvalColor = UIColor(hexString: faceOvalColor)
        }
        
        if let faceProgressColor = customizations["faceProgressColor"] as? String {
            JumioScanOverlayView.jumioAppearance().faceProgressColor = UIColor(hexString: faceProgressColor)
        }
        
        if let faceFeedbackBackgroundColor = customizations["faceFeedbackBackgroundColor"] as? String {
            JumioScanOverlayView.jumioAppearance().faceFeedbackBackgroundColor = UIColor(hexString: faceFeedbackBackgroundColor)
        }
        
        if let faceFeedbackTextColor = customizations["faceFeedbackTextColor"] as? String {
            JumioScanOverlayView.jumioAppearance().faceFeedbackTextColor = UIColor(hexString: faceFeedbackTextColor)
        }
    }
    
    func start(result: @escaping FlutterResult) {
        self.result = result
        
        if let rootViewController = getRootViewController(), let scanViewController = authenticationScanViewController {
            rootViewController.present(scanViewController, animated: true, completion: nil)
        }
    }
    
    private func resetAuthenticationController() {
        authenticationController?.destroy()
        authenticationController = nil
        authenticationScanViewController = nil
    }
    
    private func dismissViewController() {
        if let rootViewController = getRootViewController() {
            rootViewController.dismiss(animated: true, completion: nil)
        }
    }
}

extension AuthenticationModuleFlutter: AuthenticationControllerDelegate {
    func authenticationController(_ authenticationController: AuthenticationController, didFinishInitializingScanViewController scanViewController: AuthenticationScanViewController) {
        authenticationScanViewController = scanViewController
        result?(nil)
        dismissViewController()
    }
    
    func authenticationController(_ authenticationController: AuthenticationController, didFinishWith authenticationResult: AuthenticationResult, transactionReference: String) {
        
        let authenticationResult: [String: Any?] = [
            "transactionReference": transactionReference,
            "authenticationResult": authenticationResult == AuthenticationResult.success ? "SUCCESS" : "FAILED"
        ]
        
        result?(authenticationResult)
        
        dismissViewController()
    }
    
    func authenticationController(_ authenticationController: AuthenticationController, didFinishWithError error: AuthenticationError, transactionReference: String?) {
        
        let errorResult: [String: String] = [
            "transactionReference": transactionReference ?? "unknown",
            "errorCode": error.code,
            "errorMessage": error.message,
        ]

        self.result?(FlutterError(code: error.code, message: error.message, details: errorResult))
        dismissViewController()
    }
}
