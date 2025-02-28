import AVFoundation
import UIKit
import QRReaderInterface
import SimpleDI
import SwiftUI
import CorporateTestflightDomain
import TestflightNetworking

@MainActor
final class AppCoordinator {

	private let rootNavigationController: UINavigationController
	private let resolver: Resolver

	private var childCoordinator: VersionsListCoordinator?

	init(rootNavigationController: UINavigationController, resolver: Resolver) {
		self.rootNavigationController = rootNavigationController
		self.resolver = resolver
	}

	func start() {
		let container = DependencyContainer(
			api: resolver.resolve(TestflightAPIProviding.self)!,
			versionsRepository: resolver.resolve(VersionsRepository.self)!,
			projectsRepository: resolver.resolve(ProjectsRepository.self)!,
			ticketsRepository: resolver.resolve(TicketsRepository.self)!
		)
		childCoordinator = VersionsListCoordinator(
			flowParameters: .init(
				projectId: 1,
				rootViewController: rootNavigationController,
				dependenciesContainer: container
			)
		)
		childCoordinator?.start()
		childCoordinator?.onQRRequested = { [weak self] in
			guard let self else { return }
			guard let coordinator: any QRReaderFlowCoordinating = resolver.resolve((any QRReaderFlowCoordinating).self, argument: QRReaderFlowInput(session: AVCaptureSession(), parentViewController: rootNavigationController)) else {
				return
			}
			coordinator.start()
		}
	}
}
