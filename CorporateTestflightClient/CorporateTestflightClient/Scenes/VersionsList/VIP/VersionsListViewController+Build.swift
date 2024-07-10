import UIKit
import CorporateTestflightDomain

extension VersionsListViewController {

    static func build(
        projectId: Int,
        versionsRepository: VersionsRepository,
        projectsRepository: ProjectsRepository,
        output: VersionsListInteractorOutput
    ) -> VersionsListViewController {

        let presenter = VersionsListPresenter()
        let interactor = VersionsListInteractor(
            projectId: projectId,
            presenter: presenter,
            versionsRepository: versionsRepository,
            projectsRepository: projectsRepository
        )
        interactor.output = output

        let controller = VersionsListViewController(interactor: interactor)
        presenter.controller = controller
        return controller
    }
}
