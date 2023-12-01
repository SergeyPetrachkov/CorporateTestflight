import UIKit
import CorporateTestflightDomain

extension VersionsListViewController {
    
    static func build(projectId: Int, versionsRepository: VersionsRepository) -> VersionsListViewController {

        let presenter = VersionsListPresenter()
        let interactor = VersionsListInteractor(
            projectId: projectId,
            presenter: presenter,
            worker: VersionsListWorker(repository: versionsRepository)
        )

        let controller = VersionsListViewController(interactor: interactor)
        presenter.controller = controller
        return controller
    }
}
