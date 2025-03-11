import UIKit
import QRReaderInterface
import SimpleDI
import SwiftUI
import CorporateTestflightDomain
import TestflightNetworking
import JiraViewerInterface
import VersionsBrowserInterface
import Foundation
import TestflightFoundation

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
		let input = QRReaderFlowInput(
			parentViewController: rootNavigationController
		)

		guard let coordinator: any QRReaderFlowCoordinating = resolver.resolve(
			(any QRReaderFlowCoordinating).self,
			argument: input
		) else {
			return
		}
		Task {
			let result = await coordinator.start()
			switch result {
			case .codeRetrieved(let code):
				do {
					let parseResult = try QRCodeParser.parse(code)
					switch parseResult {
					case .ticket(let ticketKey):
						showTicket(key: ticketKey)
					case .version(let versionId):
						showAlert(message: "Scanned version: \(versionId)")
					case .invalid:
						showAlert(message: "Invalid QR code format")
					}
				} catch {
					showAlert(message: "Failed to parse QR code: \(error.localizedDescription)")
				}
			case .cancelled:
				break
			}
		}
	}

	private func showTicket(key: String) {
		guard let coordinator: any JiraViewerFlowCoordinating = resolver.resolve(
			(any JiraViewerFlowCoordinating).self,
			argument: JiraViewerFlowInput(
				ticket: Ticket(key: key),
				parentViewController: rootNavigationController,
				resolver: resolver
			)
		) else {
			return
		}
		coordinator.start()
	}

	private func showAlert(message: String) {
		let alertVC = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default)
		alertVC.addAction(okAction)
		rootNavigationController.present(alertVC, animated: true)
	}
}

private extension Ticket {
	init(key: String) {
		self.init(id: UUID.zero, key: key, title: "", description: "")
	}
}
