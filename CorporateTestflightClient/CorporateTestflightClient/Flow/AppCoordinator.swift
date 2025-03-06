import AVFoundation
import UIKit
import QRReaderInterface
import SimpleDI
import SwiftUI
import CorporateTestflightDomain
import TestflightNetworking
import JiraViewerInterface

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
		childCoordinator?.output = { [weak self] argument in
			guard let self else { return }
			switch argument {
			case .qrRequested:
				guard let coordinator: any QRReaderFlowCoordinating = resolver.resolve(
					(any QRReaderFlowCoordinating).self,
					argument: QRReaderFlowInput(session: AVCaptureSession(), parentViewController: rootNavigationController)
				) else {
					return
				}
				coordinator.start()
			case .ticketDetailsRequested(let ticket):
				guard let coordinator: any JiraViewerFlowCoordinating = resolver.resolve(
					(any JiraViewerFlowCoordinating).self,
					argument: JiraViewerFlowInput(
						ticket: ticket,
						parentViewController: rootNavigationController,
						resolver: resolver
					)
				) else {
					return
				}
				coordinator.start()
			}
		}
	}
}
