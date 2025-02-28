import UIKit
import SimpleDI
import QRReader

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	var coordinator: AppCoordinator?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = scene as? UIWindowScene else { return }

		if let _ = NSClassFromString("XCTestCase") {
			return
		}

		let navigationController = UINavigationController()
		let window = UIWindow(windowScene: windowScene)
		self.window = window
		window.rootViewController = navigationController
		window.makeKeyAndVisible()

		let container = Container()

		for assembly: Assembly in [QRReaderAssembly(), AppAssembly()] {
			assembly.assemble(container: container)
		}

		let coordinator = AppCoordinator(
			rootNavigationController: navigationController,
			resolver: container
		)
		coordinator.start()
		self.coordinator = coordinator
	}

	func sceneDidDisconnect(_ scene: UIScene) {}

	func sceneDidBecomeActive(_ scene: UIScene) {}

	func sceneWillResignActive(_ scene: UIScene) {}

	func sceneWillEnterForeground(_ scene: UIScene) {}

	func sceneDidEnterBackground(_ scene: UIScene) {}
}

