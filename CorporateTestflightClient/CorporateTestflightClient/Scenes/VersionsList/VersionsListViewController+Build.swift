import UIKit

extension VersionsListViewController {
    static func build() -> VersionsListViewController {
        
        let presenter = VersionsListPresenter()
        let interactor = VersionsListInteractor(
            presenter: presenter,
            worker: VersionsListWorker(repository: VersionsRepositoryImpl())
        )

        return VersionsListViewController(interactor: interactor)
    }
}
