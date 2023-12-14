import UIKit
import CorporateTestflightDomain

extension VersionDetailsViewController {

    static func build(
        version: Version,
        ticketsRepository: TicketsRepository
    ) -> VersionDetailsViewController {

        let presenter = VersionDetailsPresenter()
        let interactor = VersionDetailsInteractor(
            version: version,
            presenter: presenter,
            worker: VersionDetailsWorker(ticketsRepository: ticketsRepository)
        )

        let controller = VersionDetailsViewController(interactor: interactor)
        presenter.controller = controller
        return controller
    }
}
