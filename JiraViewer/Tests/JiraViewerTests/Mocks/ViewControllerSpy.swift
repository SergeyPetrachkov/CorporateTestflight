import UIKit
import MockFunc

final class ViewControllerSpy: UIViewController {

	typealias Input = (UIViewController, Bool)

	let presentMock = MockFunc<Input, Void>()

	override func present(
		_ viewControllerToPresent: UIViewController,
		animated flag: Bool,
		completion: (() -> Void)? = nil
	) {
		presentMock.callAndReturn((viewControllerToPresent, flag))
	}
}
