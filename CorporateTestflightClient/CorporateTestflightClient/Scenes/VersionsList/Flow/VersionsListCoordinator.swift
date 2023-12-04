import UIKit

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
            projectsRepository: dependenciesContainer.projectsRepository
        )
        rootViewController.setViewControllers([versionsVC], animated: true)
    }
}
