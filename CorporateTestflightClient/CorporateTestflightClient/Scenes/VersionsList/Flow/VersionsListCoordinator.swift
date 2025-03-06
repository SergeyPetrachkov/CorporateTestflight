import UIKit
import SwiftUI
import CorporateTestflightDomain
import JiraViewerInterface

struct VersionsListFlowParameters {
	let projectId: Int
	let rootViewController: UINavigationController
	let dependenciesContainer: DependencyContaining
}

enum VersionsListOutput {
	case qrRequested
	case ticketDetailsRequested(Ticket)
}

@MainActor
final class VersionsListCoordinator {

	private let rootViewController: UINavigationController
	private let dependenciesContainer: DependencyContaining
	private let projectId: Int

	var output: ((VersionsListOutput) -> Void)?

	init(flowParameters: VersionsListFlowParameters) {
		self.rootViewController = flowParameters.rootViewController
		self.dependenciesContainer = flowParameters.dependenciesContainer
		self.projectId = flowParameters.projectId
	}

	func start() {
		let environment = VersionsListStore.Environment(
			project: projectId,
			usecase: FetchProjectAndVersionsUsecaseImpl(
				versionsRepository: dependenciesContainer.versionsRepository,
				projectsRepository: dependenciesContainer.projectsRepository
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
		let store = VersionsListStore(environment: environment)
		let hostingVC = UIHostingController(rootView: VersionsListContainer(store: store))
		rootViewController.setViewControllers([hostingVC], animated: true)

//		let versionsVC = VersionsListViewController.build(
//			projectId: projectId,
//			versionsRepository: dependenciesContainer.versionsRepository,
//			projectsRepository: dependenciesContainer.projectsRepository,
//			output: self
//		)
//		rootViewController.setViewControllers([versionsVC], animated: true)
	}
}

extension VersionsListCoordinator: VersionsListInteractorOutput {

	func didEmitEvent(_ event: VersionsListEvent) {
		switch event {
		case .requestVersionDetails(let version):
			showVersionDetails(version)
		}
	}

	private func showVersionDetails(_ version: Version) {
		let environment = VersionDetails.Environment(
			version: version,
			fetchTicketsUsecase: FetchTicketsUseCase(
				ticketsRepository: dependenciesContainer.ticketsRepository
			),
			onTickedTapped: { [weak self] ticket in
				self?.output?(.ticketDetailsRequested(ticket))
			}
		)
		let store = VersionDetailsStore(
			initialState: .initial, environment: environment
		)
		let view = VersionDetailsContainer(store: store)
		let hostingVC = UIHostingController(rootView: view)
		rootViewController.pushViewController(hostingVC, animated: true)
	}
}
