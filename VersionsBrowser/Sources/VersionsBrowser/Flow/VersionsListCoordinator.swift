import UIKit
import SwiftUI
import CorporateTestflightDomain
import JiraViewerInterface
import SimpleDI
import UniFlow
import VersionsBrowserInterface

// Plan: 9
// Starting a coordinator

final class VersionsListCoordinator: VersionsBrowserCoordinator {

	typealias Input = VersionsBrowserFlowInput

	private let input: Input
	private let factory: VersionsBrowserFactory

	var output: ((VersionsBrowserOutput) -> Void)?

	init(input: Input, factory: VersionsBrowserFactory) {
		self.input = input
		self.factory = factory
	}

	// MARK: - Module flow
	func start() {
		let output: @MainActor (VersionList.Environment.Output) -> Void = { [weak self] action in
			switch action {
			case .selectedVersion(let version):
				self?.showVersionDetails(version)
			case .qrRequested:
				self?.output?(.qrRequested)
			}
		}
		let environment = factory.environment(inputParameters: (input, output))
		let store = factory.store(inputParameters: (VersionList.State(), environment))
		let hostingVC = UIHostingController(rootView: VersionsListContainer(store: store))
		input.parentViewController.setViewControllers([hostingVC], animated: true)
	}

	private func showVersionDetails(_ version: Version) {
		let detailsVC = factory.versionDetailsController(
			inputParameters: (
				version: version,
				onTicketTapped: { [weak self] ticket in
					self?.showJiraTicket(
						ticket
					)
				}
			)
		)
		input.parentViewController
			.pushViewController(
				detailsVC,
				animated: true
			)
	}

	// MARK: - External flow
	private func showJiraTicket(_ ticket: Ticket) {
		let coordinator = factory
			.jiraFlowCoordinator(
				inputParameters: JiraViewerFlowInput(
					ticket: ticket,
					parentViewController: input.parentViewController,
					resolver: input.resolver
				)
			)
		coordinator.start()
	}
}
