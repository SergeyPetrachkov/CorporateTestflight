import ArchHelpers
import CorporateTestflightDomain

protocol VersionsListInteractorProtocol {
    func viewDidLoad()
    func viewWillUnload()
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
    private let versionsRepository: VersionsRepository
    private let projectsRepository: ProjectsRepository
    weak var output: VersionsListInteractorOutput?

    // MARK: - State

    // MARK: - Init
    init(
        projectId: Int,
        presenter: VersionsListPresenting,
        versionsRepository: VersionsRepository,
        projectsRepository: ProjectsRepository
    ) {
        self.projectId = projectId
        self.presenter = presenter
        self.versionsRepository = versionsRepository
        self.projectsRepository = projectsRepository
    }

    // MARK: - Class interface

    func viewDidLoad() {

    }

    func viewWillUnload() {

    }
}
