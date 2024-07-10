import UIKit

final class AppCoordinator {

    private let rootNavigationController: UINavigationController
    private let dependenciesContainer: DependencyContaining

    private var childCoordinator: VersionsListCoordinator?

    init(rootNavigationController: UINavigationController, dependenciesContainer: DependencyContaining) {
        self.rootNavigationController = rootNavigationController
        self.dependenciesContainer = dependenciesContainer
    }

    func start() {
        childCoordinator = VersionsListCoordinator(
            flowParameters: .init(
                projectId: 1,
                rootViewController: rootNavigationController,
                dependenciesContainer: dependenciesContainer
            )
        )
        childCoordinator?.start()
    }
}
