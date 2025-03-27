import UIKit
import SwiftUI
import CorporateTestflightDomain
import JiraViewerInterface
import SimpleDI
import UniFlow
import VersionsBrowserInterface

final class VersionsListCoordinator: VersionsBrowserCoordinator {

	typealias Input = VersionsBrowserFlowInput

	private let input: Input
	private let factory: VersionsBrowserFactory

	var output: ((VersionsBrowserOutput) -> Void)?

	init(input: Input, factory: VersionsBrowserFactory) {
		self.input = input
		self.factory = factory
	}

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
		let environment = VersionDetails.Environment(
			version: version,
			fetchTicketsUsecase: FetchTicketsUseCase(
				ticketsRepository: input.resolver.resolve(TicketsRepository.self)!
			),
			onTickedTapped: { [weak self] ticket in
				self?.showJiraTicket(ticket)
			}
		)
		let store = VersionDetailsStore(
			initialState: .initial,
			environment: environment
		)
		let view = VersionDetailsContainer(store: store)
		let hostingVC = UIHostingController(rootView: view)
		input.parentViewController.pushViewController(hostingVC, animated: true)
	}

	private func showJiraTicket(_ ticket: Ticket) {
		guard
			let coordinator: any JiraViewerFlowCoordinating = input.resolver.resolve(
				(any JiraViewerFlowCoordinating).self,
				argument: JiraViewerFlowInput(
					ticket: ticket,
					parentViewController: input.parentViewController,
					resolver: input.resolver
				)
			)
		else {
			return
		}
		coordinator.start()
	}
}
