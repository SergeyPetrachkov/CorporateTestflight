import UIKit
import SwiftUI

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
        let viewModel = VersionDetailsViewModel()
        let view = VersionDetailsView(viewModel: viewModel)
        let hostingVC = UIHostingController(rootView: view)
        rootViewController.pushViewController(hostingVC, animated: true)
    }
}
