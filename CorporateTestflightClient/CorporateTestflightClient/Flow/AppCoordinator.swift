import AVFoundation
import UIKit
import QRReaderInterface
import SimpleDI
import SwiftUI
import CorporateTestflightDomain
import TestflightNetworking
import JiraViewerInterface
import VersionsBrowserInterface

@MainActor
final class AppCoordinator {

	private let rootNavigationController: UINavigationController
	private let resolver: Resolver

	private var childCoordinator: (any VersionsBrowserCoordinator)?

	init(rootNavigationController: UINavigationController, resolver: Resolver) {
		self.rootNavigationController = rootNavigationController
		self.resolver = resolver
	}

	func start() {
		let input = VersionsBrowserFlowInput(projectId: 1, parentViewController: rootNavigationController, resolver: resolver)
		guard var versionsListCoordinator = resolver.resolve((any VersionsBrowserCoordinator).self, argument: input) else {
			return
		}
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
