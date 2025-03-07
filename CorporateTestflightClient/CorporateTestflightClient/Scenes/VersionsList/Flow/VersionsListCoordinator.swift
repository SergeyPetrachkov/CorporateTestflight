import UIKit
import SwiftUI
import CorporateTestflightDomain
import JiraViewerInterface
import SimpleDI
import UniFlow

struct VersionsListFlowParameters {
	let projectId: Int
	let rootViewController: UINavigationController
	let resolver: Resolver
}

enum VersionsListOutput {
	case qrRequested
}

@MainActor
final class VersionsListCoordinator: SyncFlowEngine {

	private let input: VersionsListFlowParameters

	var output: ((VersionsListOutput) -> Void)?

	init(input: VersionsListFlowParameters) {
		self.input = input
	}

	func start() {
		let environment = VersionsListStore.Environment(
			project: input.projectId,
			usecase: FetchProjectAndVersionsUsecaseImpl(
				versionsRepository: input.resolver.resolve(VersionsRepository.self)!,
				projectsRepository: input.resolver.resolve(ProjectsRepository.self)!
			),
			mapper: VersionList.RowMapper(),
			output: { [weak self] action in
				switch action {
				case .selectedVersion(let version):
					self?.showVersionDetails(version)
				case .qrRequested:
					self?.output?(.qrRequested)
				}
			}
		)
		let store = VersionsListStore(initialState: VersionsListStore.State(), environment: environment)
		let hostingVC = UIHostingController(rootView: VersionsListContainer(store: store))
		input.rootViewController.setViewControllers([hostingVC], animated: true)
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
			initialState: .initial, environment: environment
		)
		let view = VersionDetailsContainer(store: store)
		let hostingVC = UIHostingController(rootView: view)
		input.rootViewController.pushViewController(hostingVC, animated: true)
	}

	private func showJiraTicket(_ ticket: Ticket) {
		guard let coordinator: any JiraViewerFlowCoordinating = input.resolver.resolve(
			(any JiraViewerFlowCoordinating).self,
			argument: JiraViewerFlowInput(
				ticket: ticket,
				parentViewController: input.rootViewController,
				resolver: input.resolver
			)
		) else {
			return
		}
		coordinator.start()
	}
}
