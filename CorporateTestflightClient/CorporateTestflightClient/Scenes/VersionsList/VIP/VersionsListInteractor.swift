import ArchHelpers
import CorporateTestflightDomain

protocol VersionsListInteractorProtocol: ViewControllerLifeCycleBoundInteractor, AsyncSingleTaskInteractor {
    func viewDidLoad()
    func viewWillUnload()
    @MainActor
    func didSelect(row: VersionsListModels.VersionViewModel)
}

enum VersionsListEvent: Sendable {
    case requestVersionDetails(version: Version)
}

protocol VersionsListInteractorOutput: AnyObject {
    @MainActor
    func didEmitEvent(_ event: VersionsListEvent)
}

final class VersionsListInteractor: VersionsListInteractorProtocol {

    // MARK: - Injectables
    private let projectId: Int
    private let presenter: VersionsListPresenting
    private let worker: VersionsListWorking
    weak var output: VersionsListInteractorOutput?

    // MARK: - State
    private(set) var currentTask: Task<Void, Never>?
    private var versions: [Version] = []

    // MARK: - Init
    init(projectId: Int, presenter: VersionsListPresenting, worker: VersionsListWorking) {
        self.projectId = projectId
        self.presenter = presenter
        self.worker = worker
    }

    // MARK: - Class interface
    func viewDidLoad() {
        currentTask = Task(operation: fetchData)
    }

    @Sendable
    @MainActor
    private func fetchData() async {
        do {
            let data = try await worker.fetchData(projectId: projectId)
            versions = data.versions
            presenter.showData(versions: data.versions, project: data.project)
        } catch {
            print(error)
        }
    }

    @MainActor
    func didSelect(row: VersionsListModels.VersionViewModel) {
        guard let version = versions.first(where: { $0.id == row.id }) else {
            return assertionFailure("Inconsistency in data")
        }
        output?.didEmitEvent(.requestVersionDetails(version: version))
    }
}
