import BAMCheckout
import Foundation
import JumioCore
import Netverify

extension String {
    func toDataCenter() -> JumioDataCenter {
        switch self.lowercased() {
        case "eu":
            return JumioDataCenterEU
        case "sg":
            return JumioDataCenterSG
        default:
            return JumioDataCenterUS
        }
    }

    func toCameraPosition() -> JumioCameraPosition {
        return self.lowercased() == "front" ? JumioCameraPositionFront : JumioCameraPositionBack
    }

    func toWatchlistScreen() -> NetverifyWatchlistScreening {
        switch self {
        case "enabled":
            return .enabled
        case "disabled":
            return .disabled
        default:
            return .default
        }
    }
}
