import ArchHelpers
import CorporateTestflightDomain

protocol VersionDetailsInteractorProtocol { }

final class VersionDetailsInteractor: VersionDetailsInteractorProtocol {

    private let version: Version
    private let worker: VersionDetailsWorking
    private let presenter: VersionDetailsPresenting

    init(version: Version, presenter: VersionDetailsPresenting, worker: VersionDetailsWorking) {
        self.version = version
        self.presenter = presenter
        self.worker = worker
    }

    deinit {
        print("Deinit \(self)")
    }

    func viewDidLoad() {

    }

    // MARK: - Private logic
}
