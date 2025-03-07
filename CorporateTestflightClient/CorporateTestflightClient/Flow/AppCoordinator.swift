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
		let versionsListCoordinator = VersionsListCoordinator(
			input: .init(
				projectId: 1,
				rootViewController: rootNavigationController,
				resolver: resolver
			)
		)
		versionsListCoordinator.output = { [weak self] argument in
			guard let self else { return }
			switch argument {
			case .qrRequested:
				showQRReader()
			}
		}
		versionsListCoordinator.start()
		childCoordinator = versionsListCoordinator
	}

	private func showQRReader() {
		guard let coordinator: any QRReaderFlowCoordinating = resolver.resolve(
			(any QRReaderFlowCoordinating).self,
			argument: QRReaderFlowInput(session: AVCaptureSession(), parentViewController: rootNavigationController)
		) else {
			return
		}
		coordinator.start()
	}
}
