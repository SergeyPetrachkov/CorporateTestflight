import ArchHelpers
import CorporateTestflightDomain

protocol VersionsListInteractorProtocol {
    func viewDidLoad()
}

enum VersionsListEvent: Sendable {
    case requestVersionDetails(version: Version)
}

protocol VersionsListInteractorOutput: AnyObject {
    
}

final class VersionsListInteractor: VersionsListInteractorProtocol {

    // MARK: - Injectables
    private let projectId: Int
    private let presenter: VersionsListPresenting
    weak var output: VersionsListInteractorOutput?

    // MARK: - State


    // MARK: - Init
    init(projectId: Int, presenter: VersionsListPresenting) {
        self.projectId = projectId
        self.presenter = presenter
    }

    // MARK: - Class interface
    func viewDidLoad() {

    }
}
