import ArchHelpers
import CorporateTestflightDomain

protocol VersionDetailsInteractorProtocol: ViewControllerLifeCycleBoundInteractor, AsyncSingleTaskInteractor {

}

final class VersionDetailsInteractor: VersionDetailsInteractorProtocol {
    
    private(set) var currentTask: Task<Void, Never>?
    private let version: Version

    init(version: Version) {
        self.version = version
    }

    func viewDidLoad() {

    }
}
