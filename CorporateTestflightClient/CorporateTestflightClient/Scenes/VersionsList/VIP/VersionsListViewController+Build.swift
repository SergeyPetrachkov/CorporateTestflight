import UIKit
import CorporateTestflightDomain

extension VersionsListViewController {
    
    static func build(
        projectId: Int,
        output: VersionsListInteractorOutput,
        projectsRepository: ProjectsRepository,
        versionsRepository: VersionsRepository
    ) -> VersionsListViewController {

        let presenter = VersionsListPresenter()
        let interactor = VersionsListInteractor(
            projectId: projectId,
            presenter: presenter,
            projectsRepository: projectsRepository,
            versionsRepository: versionsRepository
        )
        interactor.output = output

        let controller = VersionsListViewController(interactor: interactor)
        presenter.controller = controller
        return controller
    }
}
