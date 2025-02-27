import AVFoundation
import UIKit
import QRReader
import SwiftUI

@MainActor
final class AppCoordinator {

	private let rootNavigationController: UINavigationController
	private let dependenciesContainer: DependencyContaining

	private var childCoordinator: VersionsListCoordinator?

	init(rootNavigationController: UINavigationController, dependenciesContainer: DependencyContaining) {
		self.rootNavigationController = rootNavigationController
		self.dependenciesContainer = dependenciesContainer
	}

	func start() {
		childCoordinator = VersionsListCoordinator(
			flowParameters: .init(
				projectId: 1,
				rootViewController: rootNavigationController,
				dependenciesContainer: dependenciesContainer
			)
		)
		childCoordinator?.start()
		childCoordinator?.onQRRequested = { [weak self] in
			let session = AVCaptureSession()
			let env = QRCode.Environment(qrListener: QRCodeCaptureListener.init(session: session, sessionConfigurator: CaptureSessionConfigurator()))
			let state = QRCode.State(session: session)
			let store = QRReaderStore(initialState: state, environment: env)
			let view = QRReaderView(store: store)
			let hostingVC = UIHostingController(rootView: view)
			self?.rootNavigationController.pushViewController(hostingVC, animated: true)
		}
	}
}
