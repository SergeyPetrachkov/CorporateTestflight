import MockFunc
import UIKit

final class ViewControllerSpy: UINavigationController {

	typealias SetInput = ([UIViewController], Bool)

	let setMock = MockFunc<SetInput, Void>()
	override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
		setMock.callAndReturn((viewControllers, animated))
	}

	typealias PushInput = (UIViewController, Bool)
	let pushMock = MockFunc<PushInput, Void>()
	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		pushMock.callAndReturn((viewController, animated))
	}
}
