import AVFoundation
import UIKit
import QRReaderInterface
import SimpleDI
import SwiftUI

@MainActor
final class AppCoordinator {

	private let rootNavigationController: UINavigationController
	private let dependenciesContainer: DependencyContaining
	private let resolver: Resolver

	private var childCoordinator: VersionsListCoordinator?

	init(rootNavigationController: UINavigationController, dependenciesContainer: DependencyContaining, resolver: Resolver) {
		self.rootNavigationController = rootNavigationController
		self.dependenciesContainer = dependenciesContainer
		self.resolver = resolver
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
			guard let self else { return }
			guard let coordinator: any QRReaderFlowCoordinating = resolver.resolve((any QRReaderFlowCoordinating).self, argument: QRReaderFlowInput.init(session: AVCaptureSession(), parentViewController: rootNavigationController)) else {
				return
			}
			coordinator.start()
		}
	}
}
