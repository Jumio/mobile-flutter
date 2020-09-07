import Foundation
import JumioCore
import Netverify

class NetverifyModuleFlutter: NSObject, JumioMobileSdkModule {
    var result: FlutterResult?
    private var netverifyViewController: NetverifyViewController?
    
    func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        netverifyViewController?.destroy()
        
        let args = call.arguments as? [String: Any?] ?? [:]
        
        let configuration = NetverifyConfiguration()
        configuration.delegate = self
        configuration.apiToken = args["apiToken"] as? String ?? ""
        configuration.apiSecret = args["apiSecret"] as? String ?? ""
        configuration.dataCenter = (args["dataCenter"] as? String ?? "").toDataCenter()
        
        setupOptions(args: args, configuration: configuration)
        setupCustomization(args: args)
        
        do {
            try ObjcExceptionHelper.catchException {
                self.netverifyViewController = NetverifyViewController(configuration: configuration)
            }
        } catch {
            let nsError = error as NSError
            result(nsError)
        }
        
        result(nil)
    }
    
    private func setupOptions(args: [String: Any?], configuration: NetverifyConfiguration) {
        let options = args["options"] as? [String: Any?] ?? [:]
        
        if let enableVerification = options["enableVerification"] as? Bool {
            configuration.enableVerification = enableVerification
        }
        
        if let callbackUrl = options["callbackUrl"] as? String {
            configuration.callbackUrl = callbackUrl
        }
        
        if let enableIdentityVerification = options["enableIdentityVerification"] as? Bool {
            configuration.enableIdentityVerification = enableIdentityVerification
        }
        
        if let preselectedCountry = options["preselectedCountry"] as? String {
            configuration.preselectedCountry = preselectedCountry
        }
        
        if let userReference = options["userReference"] as? String {
            configuration.userReference = userReference
        }
        
        if let reportingCriteria = options["reportingCriteria"] as? String {
            configuration.reportingCriteria = reportingCriteria
        }
        
        if let customerInternalReference = options["customerInternalReference"] as? String {
            configuration.customerInternalReference = customerInternalReference
        }
        
        if let enableWatchlistScreening = options["enableWatchlistScreening"] as? String {
            configuration.watchlistScreening = enableWatchlistScreening.toWatchlistScreen()
        }
        
        if let watchlistSearchProfile = options["watchlistSearchProfile"] as? String {
            configuration.watchlistSearchProfile = watchlistSearchProfile
        }
        
        if let sendDebugInfoToJumio = options["sendDebugInfoToJumio"] as? Bool {
            configuration.sendDebugInfoToJumio = sendDebugInfoToJumio
        }
        
        if let dataExtractionOnMobileOnly = options["dataExtractionOnMobileOnly"] as? Bool {
            configuration.dataExtractionOnMobileOnly = dataExtractionOnMobileOnly
        }
        
        if let cameraPosition = options["cameraPosition"] as? String {
            configuration.cameraPosition = cameraPosition.toCameraPosition()
        }
        
        if let preselectedDocumentVariant = options["preselectedDocumentVariant"] as? String {
            configuration.preselectedDocumentVariant = preselectedDocumentVariant == "paper" ? NetverifyDocumentVariant.paper : NetverifyDocumentVariant.plastic
        }
        
        if let documentTypes = options["documentTypes"] as? [String] {
            let res = getDocumentType(cardTypes: documentTypes)
            configuration.preselectedDocumentTypes = NetverifyDocumentType(rawValue: res.reduce(0) { $0 | $1.rawValue })
        }
    }
    
    private func setupCustomization(args: [String: Any?]) {
        let customizations = args["customization"] as? [String: Any?] ?? [:]
        
        if let disableBlur = customizations["disableBlur"] as? Bool {
            NetverifyBaseView.jumioAppearance().disableBlur = disableBlur as NSNumber
        }
        
        if let enableDarkMode = customizations["enableDarkMode"] as? Bool {
            NetverifyBaseView.jumioAppearance().enableDarkMode = enableDarkMode as NSNumber
        }
        
        if let backgroundColor = customizations["backgroundColor"] as? String {
            NetverifyBaseView.jumioAppearance().backgroundColor = UIColor(hexString: backgroundColor)
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
            NetverifyBaseView.jumioAppearance().foregroundColor = UIColor(hexString: foregroundColor)
        }
        
        if let documentSelectionHeaderBackgroundColor = customizations["documentSelectionHeaderBackgroundColor"] as? String {
            NetverifyDocumentSelectionHeaderView.jumioAppearance().backgroundColor = UIColor(hexString: documentSelectionHeaderBackgroundColor)
        }
        
        if let documentSelectionHeaderBackgroundColor = customizations["documentSelectionHeaderBackgroundColor"] as? String {
            NetverifyDocumentSelectionHeaderView.jumioAppearance().backgroundColor = UIColor(hexString: documentSelectionHeaderBackgroundColor)
        }
        
        if let documentSelectionHeaderTitleColor = customizations["documentSelectionHeaderTitleColor"] as? String {
            NetverifyDocumentSelectionHeaderView.jumioAppearance().titleColor = UIColor(hexString: documentSelectionHeaderTitleColor)
        }
        
        if let documentSelectionHeaderIconColor = customizations["documentSelectionHeaderIconColor"] as? String {
            NetverifyDocumentSelectionHeaderView.jumioAppearance().iconColor = UIColor(hexString: documentSelectionHeaderIconColor)
        }
        
        if let documentSelectionButtonBackgroundColor = customizations["documentSelectionButtonBackgroundColor"] as? String {
            NetverifyDocumentSelectionButton.jumioAppearance().backgroundColor = UIColor(hexString: documentSelectionButtonBackgroundColor)
        }
        
        if let documentSelectionButtonTitleColor = customizations["documentSelectionButtonTitleColor"] as? String {
            NetverifyDocumentSelectionButton.jumioAppearance().setTitleColor(UIColor(hexString: documentSelectionButtonTitleColor), for: .normal)
        }
        
        if let documentSelectionButtonIconColor = customizations["documentSelectionButtonIconColor"] as? String {
            NetverifyDocumentSelectionButton.jumioAppearance().setIconColor(UIColor(hexString: documentSelectionButtonIconColor), for: .normal)
        }
        
        if let fallbackButtonBackgroundColor = customizations["fallbackButtonBackgroundColor"] as? String {
            NetverifyFallbackButton.jumioAppearance().backgroundColor = UIColor(hexString: fallbackButtonBackgroundColor)
        }
        
        if let fallbackButtonBorderColor = customizations["fallbackButtonBorderColor"] as? String {
            NetverifyFallbackButton.jumioAppearance().borderColor = UIColor(hexString: fallbackButtonBorderColor)
        }
        
        if let fallbackButtonTitleColor = customizations["fallbackButtonTitleColor"] as? String {
            NetverifyFallbackButton.jumioAppearance().setTitleColor(UIColor(hexString: fallbackButtonTitleColor), for: .normal)
        }
        
        if let positiveButtonBackgroundColor = customizations["positiveButtonBackgroundColor"] as? String {
            NetverifyPositiveButton.jumioAppearance().backgroundColor = UIColor(hexString: positiveButtonBackgroundColor)
        }
        
        if let positiveButtonBorderColor = customizations["positiveButtonBorderColor"] as? String {
            NetverifyPositiveButton.jumioAppearance().borderColor = UIColor(hexString: positiveButtonBorderColor)
        }
        
        if let positiveButtonTitleColor = customizations["positiveButtonTitleColor"] as? String {
            NetverifyPositiveButton.jumioAppearance().tintColor = UIColor(hexString: positiveButtonTitleColor)
        }
        
        if let negativeButtonBackgroundColor = customizations["negativeButtonBackgroundColor"] as? String {
            NetverifyNegativeButton.jumioAppearance().backgroundColor = UIColor(hexString: negativeButtonBackgroundColor)
        }
        
        if let negativeButtonBorderColor = customizations["negativeButtonBorderColor"] as? String {
            NetverifyNegativeButton.jumioAppearance().borderColor = UIColor(hexString: negativeButtonBorderColor)
        }
        
        if let negativeButtonTitleColor = customizations["negativeButtonTitleColor"] as? String {
            NetverifyNegativeButton.jumioAppearance().tintColor = UIColor(hexString: negativeButtonTitleColor)
        }
        
        if let faceOvalColor = customizations["faceOvalColor"] as? String {
            NetverifyScanOverlayView.jumioAppearance().faceOvalColor = UIColor(hexString: faceOvalColor)
        }
        
        if let faceProgressColor = customizations["faceProgressColor"] as? String {
            NetverifyScanOverlayView.jumioAppearance().faceProgressColor = UIColor(hexString: faceProgressColor)
        }
        
        if let faceFeedbackBackgroundColor = customizations["faceFeedbackBackgroundColor"] as? String {
            NetverifyScanOverlayView.jumioAppearance().faceFeedbackBackgroundColor = UIColor(hexString: faceFeedbackBackgroundColor)
        }
        
        if let faceFeedbackTextColor = customizations["faceFeedbackTextColor"] as? String {
            NetverifyScanOverlayView.jumioAppearance().faceFeedbackTextColor = UIColor(hexString: faceFeedbackTextColor)
        }
    }
    
    func start(result: @escaping FlutterResult) {
        self.result = result
        
        if let rootViewController = getRootViewController(), let netverifyViewController = netverifyViewController {
            rootViewController.present(netverifyViewController, animated: true, completion: nil)
        }
    }
    
    private func getScanResult(scanReference: String, documentData: NetverifyDocumentData) -> [String: Any] {
        let scanResult: [String: Any?] = [
            "scanReference": scanReference,
            "addressLine": documentData.addressLine,
            "city": documentData.city,
            "firstName": documentData.firstName,
            "idNumber": documentData.idNumber,
            "issuingCountry": documentData.issuingCountry,
            "lastName": documentData.lastName,
            "optionalData1": documentData.optionalData1,
            "optionalData2": documentData.optionalData2,
            "originatingCountry": documentData.originatingCountry,
            "personalNumber": documentData.personalNumber,
            "postCode": documentData.postCode,
            "selectedCountry": documentData.selectedCountry,
            "gender": getGenderString(from: documentData.gender),
            "selectedDocumentType": getDocumentType(from: documentData.selectedDocumentType),
            "mrzLine1": documentData.mrzData?.line1,
            "mrzLine2": documentData.mrzData?.line2,
            "mrzLine3": documentData.mrzData?.line3,
            "subdivision": documentData.subdivision,
            "mrzData": getMrzData(from: documentData.mrzData),
            "extractionMethod": getExtractionMethod(fromMethod: documentData.extractionMethod),
            "issuingDate": documentData.issuingDate?.asISO8601String(),
            "expiryDate": documentData.expiryDate?.asISO8601String(),
            "dob": documentData.dob?.asISO8601String()
        ]
        
        return scanResult.compactMapValues { $0 }
    }
    
    private func getExtractionMethod(fromMethod method: NetverifyExtractionMethod) -> String {
        switch method {
        case .MRZ:
            return "MRZ"
        case .OCR:
            return "OCR"
        case .barcode:
            return "BARCODE"
        case .barcodeOCR:
            return "BARCODE_OCR"
        default:
            return "NONE"
        }
    }
    
    private func getMrzData(from data: NetverifyMrzData?) -> [String: Any] {
        if let mrzData = data {
            let mrzResult: [String: Any?] = [
                "format": getMrzFormat(from: mrzData.format),
                "line1": mrzData.line1,
                "line2": mrzData.line2,
                "line3": mrzData.line3,
                "idNumberValid": mrzData.idNumberValid(),
                "dobValid": mrzData.dobValid(),
                "expiryDateValid": mrzData.expiryDateValid(),
                "personalNumberValid": mrzData.personalNumberValid(),
                "compositeValid": mrzData.compositeValid()
            ]
            return mrzResult.compactMapValues { $0 }
        }
        
        return [:]
    }
    
    private func getMrzFormat(from format: NetverifyMRZFormat) -> String {
        switch format {
        case .MRP:
            return "MRP"
        case .TD1:
            return "TD1"
        case .TD2:
            return "TD2"
        case .CNIS:
            return "CNIS"
        case .MRVA:
            return "MRVA"
        case .MRVB:
            return "MRVB"
        default:
            return "UNKNOWN"
        }
    }
    
    private func getDocumentType(from selectedDocumentType: NetverifyDocumentType) -> String {
        switch selectedDocumentType {
        case .driverLicense:
            return "DRIVER_LICENSE"
        case .identityCard:
            return "IDENTITY_CARD"
        case .passport:
            return "PASSPORT"
        case .visa:
            return "VISA"
        default:
            return ""
        }
    }
    
    private func getGenderString(from documentData: NetverifyGender) -> String {
        switch documentData {
        case .F:
            return "F"
        case .M:
            return "M"
        case .X:
            return "X"
        default:
            return ""
        }
    }
    
    private func dismissViewController() {
        netverifyViewController?.dismiss(animated: true) {
            self.netverifyViewController?.destroy()
            self.netverifyViewController = nil
        }
    }
    
    private func getDocumentType(cardTypes: [String]) -> [NetverifyDocumentType] {
        return cardTypes.compactMap { getDocumentType(type: $0) }
    }
    
    private func getDocumentType(type: String) -> NetverifyDocumentType? {
        switch type.lowercased() {
        case "passport":
            return .passport
        case "driver_license":
            return .driverLicense
        case "identity_card":
            return .identityCard
        case "visa":
            return .visa
        default:
            return nil
        }
    }
    
    func enableEMRTD() {
        result?(nil)
    }
}

extension NetverifyModuleFlutter: NetverifyViewControllerDelegate {
    public func netverifyViewController(_ netverifyViewController: NetverifyViewController, didFinishWith documentData: NetverifyDocumentData, scanReference: String) {
        result?(getScanResult(scanReference: scanReference, documentData: documentData))
        dismissViewController()
    }
    
    public func netverifyViewController(_ netverifyViewController: NetverifyViewController, didCancelWithError error: NetverifyError?, scanReference: String?) {
        
        let errorCode = error?.code ?? "unknown"
        let errorMessage = error?.message ?? "unknown"
        
        let errorResult: [String: Any?] = [
            "errorCode": errorCode,
            "errorMessage": errorMessage,
            "scanReference": scanReference ?? "unknown"
        ]

        result?(FlutterError(code: errorCode, message: errorMessage, details: errorResult))
        dismissViewController()
    }
}
