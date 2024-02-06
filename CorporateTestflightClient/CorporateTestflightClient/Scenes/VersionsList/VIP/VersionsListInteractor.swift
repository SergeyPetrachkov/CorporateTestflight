import ArchHelpers
import CorporateTestflightDomain

protocol VersionsListInteractorProtocol {
    func viewDidLoad()
}

enum VersionsListEvent: Sendable {
    case requestVersionDetails(version: Version)
}

protocol VersionsListInteractorOutput: AnyObject {
    func didEmitEvent(_ event: VersionsListEvent)
}

final class VersionsListInteractor: VersionsListInteractorProtocol {

    // MARK: - Injectables
    private let projectId: Int
    private let presenter: VersionsListPresenting
    private let projectsRepository: ProjectsRepository
    private let versionsRepository: VersionsRepository
    weak var output: VersionsListInteractorOutput?

    // MARK: - State


    // MARK: - Init
    init(
        projectId: Int,
        presenter: VersionsListPresenting,
        projectsRepository: ProjectsRepository,
        versionsRepository: VersionsRepository
    ) {
        self.projectId = projectId
        self.presenter = presenter
        self.projectsRepository = projectsRepository
        self.versionsRepository = versionsRepository
    }

    // MARK: - Class interface
    func viewDidLoad() {

    }
}
