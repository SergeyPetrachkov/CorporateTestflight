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
        let versionsVC = VersionsListViewController.build(
            projectId: projectId,
            versionsRepository: dependenciesContainer.versionsRepository,
            projectsRepository: dependenciesContainer.projectsRepository,
            output: self
        )
        rootViewController.setViewControllers([versionsVC], animated: true)
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
        let alternativeVC = UIAlertController(title: "Time to choose", message: "Which side are you on?", preferredStyle: .actionSheet)
        
        let uikitAction = UIAlertAction(title: "UIKit", style: .default) { [weak self] _ in
            self?.showUIKit(version: version)
        }

        let swiftUIAction = UIAlertAction(title: "SwiftUI", style: .destructive) { [weak self] _ in
            self?.showSwiftUI(version: version)
        }

        let cancelAction = UIAlertAction(title: "Flutter", style: .cancel) { _ in
            fatalError("How dare you!")
        }

        alternativeVC.addAction(uikitAction)
        alternativeVC.addAction(swiftUIAction)
        alternativeVC.addAction(cancelAction)
        rootViewController.present(alternativeVC, animated: true)
    }

    private func showUIKit(version: Version) {
        let controller = VersionDetailsViewController.build(version: version, ticketsRepository: dependenciesContainer.ticketsRepository)
        rootViewController.pushViewController(controller, animated: true)
    }

    private func showSwiftUI(version: Version) {
        let viewModel = VersionDetailsViewModel(
            version: version,
            fetchTicketsUsecase: FetchTicketsUseCase(ticketsRepository: dependenciesContainer.ticketsRepository)
        )
        let view = VersionDetailsView(viewModel: viewModel)
        let hostingVC = UIHostingController(rootView: view)
        rootViewController.pushViewController(hostingVC, animated: true)
    }
}
