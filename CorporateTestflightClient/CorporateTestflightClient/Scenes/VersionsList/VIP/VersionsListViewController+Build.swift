import UIKit
import CorporateTestflightDomain

extension VersionsListViewController {
    
    static func build(
        projectId: Int,
        output: VersionsListInteractorOutput
    ) -> VersionsListViewController {

        let presenter = VersionsListPresenter()
        let interactor = VersionsListInteractor(
            projectId: projectId,
            presenter: presenter
        )
        interactor.output = output

        let controller = VersionsListViewController(interactor: interactor)
        presenter.controller = controller
        return controller
    }
}
