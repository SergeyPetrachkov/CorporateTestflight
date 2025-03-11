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
	private var qrCoordinator: (any QRReaderFlowCoordinating)?

	init(rootNavigationController: UINavigationController, resolver: Resolver) {
		self.rootNavigationController = rootNavigationController
		self.resolver = resolver
	}

	func start() {
		let input = VersionsBrowserFlowInput(projectId: 1, parentViewController: rootNavigationController, resolver: resolver)
		guard let versionsListCoordinator = resolver.resolve((any VersionsBrowserCoordinator).self, argument: input) else {
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
		// Here we start a new Task, it may be not that ellegant.
		// But if we make this parent coordinator async on the top level, then everything will just be async-await.
		// Bonus point:
		// no need to retain this coordinator, because it will live exactly as long as the purpose of the coordinator (until it returns the result),
		// and then will deallocate
		Task {
			let result = await coordinator.startAsync()
			handleQRFlowResult(result)
		}
		// or
		// conservative coordinator with the output closure.
		// we need to retain it in the property, otherwise it will be deallocated as soon as the scope of this function ends
//		coordinator.output = { [weak self] result in
//			self?.handleQRFlowResult(result)
//			self?.qrCoordinator = nil
//		}
//		coordinator.start()
//		qrCoordinator = coordinator
	}

	private func handleQRFlowResult(_ result: QRReaderFlowResult) {
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
