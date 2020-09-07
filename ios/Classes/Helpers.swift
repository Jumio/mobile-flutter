import Foundation

func getRootViewController() -> UIViewController? {
    if let delegate = UIApplication.shared.delegate, let windows = delegate.window, let vc = windows?.rootViewController {
        return vc
    }
    return nil
}
