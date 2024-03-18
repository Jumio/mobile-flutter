import Foundation
import Jumio

class JumioModuleFlutter: NSObject, JumioMobileSdkModule {
    fileprivate var jumio: Jumio.SDK?
    fileprivate var jumioVC: Jumio.ViewController?
    var result: FlutterResult?

    func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any?] ?? [:]

        let token = args["authorizationToken"] as? String ?? ""
        let dataCenter = args["dataCenter"] as? String ?? ""

        jumio = Jumio.SDK()
        jumio?.defaultUIDelegate = self
        jumio?.token = token
        jumio?.setResourcesBundle(Bundle.main)

        switch dataCenter.lowercased() {
        case "eu":
            jumio?.dataCenter = .EU
        case "sg":
            jumio?.dataCenter = .SG
        default:
            jumio?.dataCenter = .US
        }
        result(nil)
    }

    func start(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any?] ?? [:]

        self.result = result

        guard let jumio = jumio else { return }

        jumio.startDefaultUI()

        // Check if customization argument is added
        if let customizations = args["customizations"] as? [String: Any?] {
            let customTheme = customizeSDKColors(customizations: customizations)
            jumio.customize(theme: customTheme)
        }

        do {
            try ObjcExceptionHelper.catchException {
                self.jumioVC = try? jumio.viewController()
            }
        } catch {
            let nsError = error as NSError
            result(FlutterError(code: "\(nsError.code)", message: nsError.localizedDescription, details: nil))
            return
        }

        guard let jumioVC = jumioVC else { return }

        jumioVC.modalPresentationStyle = .fullScreen

        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController
        else { return }

        rootViewController.present(jumioVC, animated: true)
    }

    private func getIDResult(idResult: Jumio.IDResult) -> [String: Any] {
        let result: [String: Any?] = [
            "selectedCountry": idResult.country,
            "selectedDocumentType": idResult.idType,
            "selectedDocumentSubType": idResult.idSubType,
            "idNumber": idResult.documentNumber,
            "personalNumber": idResult.personalNumber,
            "issuingDate": idResult.issuingDate,
            "expiryDate": idResult.expiryDate,
            "issuingCountry": idResult.issuingCountry,
            "firstName": idResult.firstName,
            "lastName": idResult.lastName,
            "gender": idResult.gender,
            "nationality": idResult.nationality,
            "dateOfBirth": idResult.dateOfBirth,
            "addressLine": idResult.address,
            "city": idResult.city,
            "subdivision": idResult.subdivision,
            "postCode": idResult.postalCode,
            "placeOfBirth": idResult.placeOfBirth,
            "mrzLine1": idResult.mrzLine1,
            "mrzLine2": idResult.mrzLine2,
            "mrzLine3": idResult.mrzLine3,
        ]

        return result.compactMapValues { $0 }
    }

    private func getFaceResult(faceResult: Jumio.FaceResult) -> [String: Any] {
        let result: [String: Any?] = [
            "passed": (faceResult.passed ?? false) ? "true" : "false",
        ]

        return result.compactMapValues { $0 }
    }
}

extension JumioModuleFlutter: Jumio.DefaultUIDelegate {
    func jumio(sdk: Jumio.SDK, finished result: Jumio.Result) {
        jumioVC?.dismiss(animated: true) { [weak self] in
            guard let weakself = self else { return }

            weakself.jumioVC = nil
            weakself.jumio = nil

            weakself.handleResult(jumioResult: result)
        }
    }

    private func handleResult(jumioResult: Jumio.Result) {
        let accountId = jumioResult.accountId
        let authenticationResult = jumioResult.isSuccess
        let credentialInfos = jumioResult.credentialInfos
        let workflowId = jumioResult.workflowExecutionId

        if authenticationResult == true {
            var body:[String: Any?] = [
                "accountId": accountId,
                "workflowId" : workflowId
            ]
            var credentialArray = [[String: Any?]]()
            
            credentialInfos.forEach { credentialInfo in
                var eventResultMap: [String: Any?] = [
                    "credentialId": credentialInfo.id,
                    "credentialCategory": "\(credentialInfo.category)",
                ]

                switch credentialInfo.category {
                    case .id:
                    if let idResult = jumioResult.getIDResult(of: credentialInfo) {
                        eventResultMap = eventResultMap.merging(getIDResult(idResult: idResult), uniquingKeysWith: { (first, _) in first })
                    }
                    case .face:
                    if let faceResult = jumioResult.getFaceResult(of: credentialInfo) {
                        eventResultMap = eventResultMap.merging(getFaceResult(faceResult: faceResult), uniquingKeysWith: { (first, _) in first })
                    }
                    default:
                    break
                }
                
                credentialArray.append(eventResultMap)
            }
            body["credentials"] = credentialArray
            
            result?(body)
        } else {
            guard let error = jumioResult.error else { return }
            let errorMessage = error.message
            let errorCode = error.code

            let body: [String: Any?] = [
                "errorCode": errorCode,
                "errorMessage": errorMessage,
            ]

            result?(FlutterError(code: errorCode, message: errorMessage, details: body))
        }
    }
}
