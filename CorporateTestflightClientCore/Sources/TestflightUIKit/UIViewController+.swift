#if canImport(UIKit)
import UIKit

public extension UIViewController {

    /// Add a passed viewController to self as a child (Respecting the life cycle).
    ///
    /// - Parameters:
    ///    - viewController: vc that will be attached
    ///    - fillParent: if `true` stretch the `viewController` to the bounds of the parent viewController
    @discardableResult
    func attachChild(_ viewController: UIViewController, fillParent: Bool = true) -> UIViewController {
        addChild(viewController)
        view.addSubview(viewController.view)
        if fillParent {
            viewController.view.frame = view.bounds
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        viewController.didMove(toParent: self)
        return viewController
    }

    /// Remove the `viewController` from parent respecting the life cycle.
    func detachChild(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}
#endif
