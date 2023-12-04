import UIKit
import CorporateTestflightDomain

extension VersionsListViewController {
    
    static func build(
        projectId: Int,
        versionsRepository: VersionsRepository,
        projectsRepository: ProjectsRepository
    ) -> VersionsListViewController {

        let presenter = VersionsListPresenter()
        let interactor = VersionsListInteractor(
            projectId: projectId,
            presenter: presenter,
            worker: VersionsListWorker(
                versionsRepository: versionsRepository,
                projectsRepository: projectsRepository
            )
        )

        let controller = VersionsListViewController(interactor: interactor)
        presenter.controller = controller
        return controller
    }
}
