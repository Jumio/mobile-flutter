import BAMCheckout
import Foundation

class BAMCheckoutModuleFlutter: NSObject, JumioMobileSdkModule {
    var result: FlutterResult?
    private var scanReferences: Set<String> = []
    private var bamCheckoutViewController: BAMCheckoutViewController?

    func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result

        let args = call.arguments as? [String: Any?] ?? [:]

        let configuration = BAMCheckoutConfiguration()
        configuration.delegate = self
        configuration.apiToken = args["apiToken"] as? String ?? ""
        configuration.apiSecret = args["apiSecret"] as? String ?? ""
        configuration.dataCenter = (args["dataCenter"] as? String ?? "").toDataCenter()

        setupOptions(args: args, configuration: configuration)

        do {
            try ObjcExceptionHelper.catchException {
                self.bamCheckoutViewController = BAMCheckoutViewController(configuration: configuration)
            }
        } catch {
            let nsError = error as NSError
            result(FlutterError(code: "\(nsError.code)", message: nsError.localizedDescription, details: nil))
        }

        setupCustomization(args: args)
        result(nil)
    }

    func start(result: @escaping FlutterResult) {
        scanReferences = []
        self.result = result
        if let rootViewController = getRootViewController(), let bamCheckoutViewController = bamCheckoutViewController {
            rootViewController.present(bamCheckoutViewController, animated: true, completion: nil)
        }
    }

    private func setupOptions(args: [String: Any?], configuration: BAMCheckoutConfiguration) {
        let options = args["options"] as? [String: Any?] ?? [:]

        if let cardHolderNameRequired = options["cardHolderNameRequired"] as? Bool {
            configuration.cardHolderNameRequired = cardHolderNameRequired
        }

        if let sortCodeAndAccountNumberRequired = options["sortCodeAndAccountNumberRequired"] as? Bool {
            configuration.sortCodeAndAccountNumberRequired = sortCodeAndAccountNumberRequired
        }

        if let expiryRequired = options["expiryRequired"] as? Bool {
            configuration.expiryRequired = expiryRequired
        }

        if let cvvRequired = options["cvvRequired"] as? Bool {
            configuration.cvvRequired = cvvRequired
        }

        if let expiryEditable = options["expiryEditable"] as? Bool {
            configuration.expiryEditable = expiryEditable
        }

        if let cardHolderNameEditable = options["cardHolderNameEditable"] as? Bool {
            configuration.cardHolderNameEditable = cardHolderNameEditable
        }

        if let reportingCriteria = options["reportingCriteria"] as? String {
            configuration.reportingCriteria = reportingCriteria
        }

        if let vibrationEffectEnabled = options["vibrationEffectEnabled"] as? Bool {
            configuration.vibrationEffectEnabled = vibrationEffectEnabled
        }

        if let enableFlashOnScanStart = options["enableFlashOnScanStart"] as? Bool {
            configuration.enableFlashOnScanStart = enableFlashOnScanStart
        }

        if let cardNumberMaskingEnabled = options["cardNumberMaskingEnabled"] as? Bool {
            configuration.cardNumberMaskingEnabled = cardNumberMaskingEnabled
        }

        if let offlineToken = options["offlineToken"] as? String {
            configuration.offlineToken = offlineToken
        }

        if let cameraPosition = options["cameraPosition"] as? String {
            configuration.cameraPosition = cameraPosition.toCameraPosition()
        }

        if let cardTypes = options["cardTypes"] as? [String] {
            let res = getCardTypes(cardTypes: cardTypes)
            configuration.supportedCreditCardTypes = res.reduce(0) { $0 | $1.rawValue }
        }
    }

    private func getCardTypeString(fromType: BAMCheckoutCreditCardType) -> String {
        switch fromType {
        case .visa:
            return "VISA"
        case .masterCard:
            return "MASTER_CARD"
        case .americanExpress:
            return "AMERICAN_EXPRESS"
        case .chinaUnionPay:
            return "CHINA_UNIONPAY"
        case .diners:
            return "DINERS_CLUB"
        case .discover:
            return "DISCOVER"
        case .JCB:
            return "JCB"
        case .all:
            return "ALL"
        @unknown default:
            return "unknown"
        }
    }

    private func getCardTypes(cardTypes: [String]) -> [BAMCheckoutCreditCardType] {
        return cardTypes.compactMap { getCardType(fromString: $0) }
    }

    private func dismissViewController() {
        bamCheckoutViewController?.dismiss(animated: true) {
            self.bamCheckoutViewController = nil
        }
    }

    private func getCardType(fromString: String) -> BAMCheckoutCreditCardType? {
        switch fromString.lowercased() {
        case "visa":
            return .visa
        case "master_card":
            return .masterCard
        case "american_express":
            return .americanExpress
        case "china_unionpay":
            return .chinaUnionPay
        case "diners_club":
            return .diners
        case "discover":
            return .discover
        case "jcb":
            return .JCB
        default:
            return nil
        }
    }

    private func setupCustomization(args: [String: Any?]) {
        let customizations = args["customization"] as? [String: Any?] ?? [:]

        if let disableBlur = customizations["disableBlur"] as? Bool {
            BAMCheckoutBaseView.jumioAppearance().disableBlur = disableBlur as NSNumber
        }

        if let backgroundColor = customizations["backgroundColor"] as? String {
            BAMCheckoutBaseView.jumioAppearance().backgroundColor = UIColor(hexString: backgroundColor)
        }

        if let tintColor = customizations["tintColor"] as? String {
            BAMCheckoutBaseView.jumioAppearance().tintColor = UIColor(hexString: tintColor)
        }

        if let barTintColor = customizations["barTintColor"] as? String {
            UINavigationBar.jumioAppearance().barTintColor = UIColor(hexString: barTintColor)
        }

        if let textTitleColor = customizations["textTitleColor"] as? String {
            UINavigationBar.jumioAppearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: textTitleColor)]
        }

        if let foregroundColor = customizations["foregroundColor"] as? String {
            BAMCheckoutBaseView.jumioAppearance().foregroundColor = UIColor(hexString: foregroundColor)
        }

        if let positiveButtonBackgroundColor = customizations["positiveButtonBackgroundColor"] as? String {
            BAMCheckoutPositiveButton.jumioAppearance().backgroundColor = UIColor(hexString: positiveButtonBackgroundColor)
        }

        if let positiveButtonBorderColor = customizations["positiveButtonBorderColor"] as? String {
            BAMCheckoutPositiveButton.jumioAppearance().borderColor = UIColor(hexString: positiveButtonBorderColor)
        }

        if let positiveButtonTitleColor = customizations["positiveButtonTitleColor"] as? String {
            BAMCheckoutPositiveButton.jumioAppearance().tintColor = UIColor(hexString: positiveButtonTitleColor)
        }

        if let negativeButtonBackgroundColor = customizations["negativeButtonBackgroundColor"] as? String {
            BAMCheckoutNegativeButton.jumioAppearance().backgroundColor = UIColor(hexString: negativeButtonBackgroundColor)
        }

        if let negativeButtonBorderColor = customizations["negativeButtonBorderColor"] as? String {
            BAMCheckoutNegativeButton.jumioAppearance().borderColor = UIColor(hexString: negativeButtonBorderColor)
        }

        if let negativeButtonTitleColor = customizations["negativeButtonTitleColor"] as? String {
            BAMCheckoutNegativeButton.jumioAppearance().tintColor = UIColor(hexString: negativeButtonTitleColor)
        }

        if let scanOverlayTextColor = customizations["scanOverlayTextColor"] as? String {
            BAMCheckoutScanOverlay.jumioAppearance().textColor = UIColor(hexString: scanOverlayTextColor)
        }

        if let scanOverlayBorderColor = customizations["scanOverlayBorderColor"] as? String {
            BAMCheckoutScanOverlay.jumioAppearance().borderColor = UIColor(hexString: scanOverlayBorderColor)
        }
    }
}

extension BAMCheckoutModuleFlutter: BAMCheckoutViewControllerDelegate {
    func bamCheckoutViewController(_ controller: BAMCheckoutViewController, didCancelWithError error: Error?, scanReference: String?) {
        if let scanReference = scanReference {
            scanReferences.insert(scanReference)
        }

        let errorCode = (error as NSError?)?.code ?? 0
        let errorMessage = error?.localizedDescription ?? "unknown"
        
        let errorResult: [String: Any?] = [
            "errorCode": errorCode,
            "errorMessage": errorMessage,
            "scanReferences": scanReference ?? "unknown"
        ]

        result?(FlutterError(code: String(errorCode), message: errorMessage, details: errorResult))
        dismissViewController()
    }

    func bamCheckoutViewController(_ controller: BAMCheckoutViewController, didFinishScanWith cardInformation: BAMCheckoutCardInformation, scanReference: String) {
        scanReferences.insert(scanReference)

        let cardInformationResult: [String: Any?] = [
            "cardType": getCardTypeString(fromType: cardInformation.cardType),
            "cardNumber": cardInformation.cardNumber,
            "cardNumberGrouped": cardInformation.cardNumberGrouped,
            "cardNumberMasked": cardInformation.cardNumberMasked,
            "cardExpiryMonth": cardInformation.cardExpiryMonth,
            "cardExpiryYear": cardInformation.cardExpiryYear,
            "cardExpiryDate": cardInformation.cardExpiryDate,
            "cardCVV": cardInformation.cardCVV,
            "cardHolderName": cardInformation.cardHolderName,
            "cardSortCode": cardInformation.cardSortCode,
            "cardAccountNumber": cardInformation.cardAccountNumber,
            "cardSortCodeValid": cardInformation.cardSortCodeValid,
            "cardAccountNumberValid": cardInformation.cardAccountNumberValid,
            "scanReferences": Array(scanReferences)
        ]

        result?(cardInformationResult.compactMapValues { $0 })
        dismissViewController()
    }

    func bamCheckoutViewController(_ controller: BAMCheckoutViewController, didStartScanAttemptWithScanReference scanReference: String) {
        scanReferences.insert(scanReference)
    }
}
