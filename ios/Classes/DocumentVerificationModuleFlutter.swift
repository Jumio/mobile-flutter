import DocumentVerification
import Foundation

class DocumentVerificationModuleFlutter: NSObject, JumioMobileSdkModule {
    var result: FlutterResult?
    private var documentVerificationViewController: DocumentVerificationViewController?
    
    func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any?] ?? [:]
        
        let configuration = DocumentVerificationConfiguration()
        configuration.delegate = self
        configuration.apiToken = args["apiToken"] as? String ?? ""
        configuration.apiSecret = args["apiSecret"] as? String ?? ""
        configuration.dataCenter = (args["dataCenter"] as? String ?? "").toDataCenter()
        
        setupOptions(args: args, configuration: configuration)
        setupCustomization(args: args)
        
        do {
            try ObjcExceptionHelper.catchException {
                self.documentVerificationViewController = DocumentVerificationViewController(configuration: configuration)
            }
        } catch {
            let nsError = error as NSError
            result(FlutterError(code: "\(nsError.code)", message: nsError.localizedDescription, details: nil))
            return
        }
        
        result(nil)
    }
    
    private func setupOptions(args: [String: Any?], configuration: DocumentVerificationConfiguration) {
        let options = args["options"] as? [String: Any?] ?? [:]
        
        if let type = options["type"] as? String {
            configuration.type = type
        }
        
        if let customDocumentCode = options["customDocumentCode"] as? String {
            configuration.customDocumentCode = customDocumentCode
        }
        
        if let country = options["country"] as? String {
            configuration.country = country
        }
        
        if let reportingCriteria = options["reportingCriteria"] as? String {
            configuration.reportingCriteria = reportingCriteria
        }
        
        if let callbackUrl = options["callbackUrl"] as? String {
            configuration.callbackUrl = callbackUrl
        }
        
        if let userReference = options["userReference"] as? String {
            configuration.userReference = userReference
        }
        
        if let customerInternalReference = options["customerInternalReference"] as? String {
            configuration.customerInternalReference = customerInternalReference
        }
        
        if let documentName = options["documentName"] as? String {
            configuration.documentName = documentName
        }
        
        if let enableExtraction = options["enableExtraction"] as? Bool {
            configuration.enableExtraction = enableExtraction
        }
        
        if let cameraPosition = options["cameraPosition"] as? String {
            configuration.cameraPosition = cameraPosition.toCameraPosition()
        }
    }
    
    func start(result: @escaping FlutterResult) {
        self.result = result
        if let rootViewController = getRootViewController(), let documentVerificationViewController = documentVerificationViewController {
            rootViewController.present(documentVerificationViewController, animated: true, completion: nil)
        }
    }
    
    private func dismissViewController() {
        documentVerificationViewController?.dismiss(animated: true) {
            self.documentVerificationViewController = nil
        }
    }
    
    private func setupCustomization(args: [String: Any?]) {
        let customizations = args["customization"] as? [String: Any?] ?? [:]
        
        if let disableBlur = customizations["disableBlur"] as? Bool {
            DocumentVerificationBaseView.jumioAppearance().disableBlur = disableBlur as NSNumber
        }
        
        if let enableDarkMode = customizations["enableDarkMode"] as? Bool {
            DocumentVerificationBaseView.jumioAppearance().disableBlur = enableDarkMode as NSNumber
        }
        
        if let backgroundColor = customizations["backgroundColor"] as? String {
            DocumentVerificationBaseView.jumioAppearance().backgroundColor = UIColor(hexString: backgroundColor)
        }
        
        if let tintColor = customizations["tintColor"] as? String {
            DocumentVerificationBaseView.jumioAppearance().tintColor = UIColor(hexString: tintColor)
        }
        
        if let barTintColor = customizations["barTintColor"] as? String {
            UINavigationBar.jumioAppearance().barTintColor = UIColor(hexString: barTintColor)
        }
        
        if let textTitleColor = customizations["textTitleColor"] as? String {
            UINavigationBar.jumioAppearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: textTitleColor)]
        }
        
        if let foregroundColor = customizations["foregroundColor"] as? String {
            DocumentVerificationBaseView.jumioAppearance().foregroundColor = UIColor(hexString: foregroundColor)
        }
        
        if let positiveButtonBackgroundColor = customizations["positiveButtonBackgroundColor"] as? String {
            DocumentVerificationPositiveButton.jumioAppearance().backgroundColor = UIColor(hexString: positiveButtonBackgroundColor)
        }
        
        if let positiveButtonBorderColor = customizations["positiveButtonBorderColor"] as? String {
            DocumentVerificationPositiveButton.jumioAppearance().borderColor = UIColor(hexString: positiveButtonBorderColor)
        }
        
        if let positiveButtonTitleColor = customizations["positiveButtonTitleColor"] as? String {
            DocumentVerificationPositiveButton.jumioAppearance().tintColor = UIColor(hexString: positiveButtonTitleColor)
        }
        
        if let negativeButtonBackgroundColor = customizations["negativeButtonBackgroundColor"] as? String {
            DocumentVerificationNegativeButton.jumioAppearance().backgroundColor = UIColor(hexString: negativeButtonBackgroundColor)
        }
        
        if let negativeButtonBorderColor = customizations["negativeButtonBorderColor"] as? String {
            DocumentVerificationNegativeButton.jumioAppearance().borderColor = UIColor(hexString: negativeButtonBorderColor)
        }
        
        if let negativeButtonTitleColor = customizations["negativeButtonTitleColor"] as? String {
            DocumentVerificationNegativeButton.jumioAppearance().tintColor = UIColor(hexString: negativeButtonTitleColor)
        }
    }
}

extension DocumentVerificationModuleFlutter: DocumentVerificationViewControllerDelegate {
    func documentVerificationViewController(_ documentVerificationViewController: DocumentVerificationViewController, didFinishWithScanReference scanReference: String?) {
        if let scanResult = scanReference {
            result?(["scanReference": scanResult])
        } else {
            result?([String: String]())
        }
        
        dismissViewController()
    }
    
    func documentVerificationViewController(_ documentVerificationViewController: DocumentVerificationViewController, didFinishWithError error: DocumentVerificationError) {

        result?(FlutterError(code: error.code, message: error.message, details: nil))
        dismissViewController()
    }
}
