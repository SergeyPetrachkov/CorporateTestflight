import UIKit
import SwiftUI
import CorporateTestflightDomain

struct VersionsListFlowParameters {
	let projectId: Int
	let rootViewController: UINavigationController
	let dependenciesContainer: DependencyContaining
}

@MainActor
final class VersionsListCoordinator {

	private let rootViewController: UINavigationController
	private let dependenciesContainer: DependencyContaining
	private let projectId: Int

	init(flowParameters: VersionsListFlowParameters) {
		self.rootViewController = flowParameters.rootViewController
		self.dependenciesContainer = flowParameters.dependenciesContainer
		self.projectId = flowParameters.projectId
	}

	func start() {
		let environment = VersionsListStore.Environment(
			project: projectId,
			usecase: FetchProjectAndVersionsUsecaseImpl(versionsRepository: dependenciesContainer.versionsRepository, projectsRepository: dependenciesContainer.projectsRepository),
			mapper: VersionList.RowMapper(),
			output: { [weak self] action in
				switch action {
				case .selectedVersion(let version):
					self?.showVersionDetails(version)
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
		let viewModel = VersionDetailsViewModel(
			version: version,
			fetchTicketsUsecase: FetchTicketsUseCase(ticketsRepository: dependenciesContainer.ticketsRepository)
		)
		let view = VersionDetailsView(viewModel: viewModel)
		let hostingVC = UIHostingController(rootView: view)
		rootViewController.pushViewController(hostingVC, animated: true)
	}
}
