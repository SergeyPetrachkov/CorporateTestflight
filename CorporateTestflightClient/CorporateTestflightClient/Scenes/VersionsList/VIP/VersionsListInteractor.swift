import ArchHelpers
import CorporateTestflightDomain

protocol VersionsListInteractorProtocol: ViewControllerLifeCycleBoundInteractor, AsyncSingleTaskInteractor {
    func viewDidLoad()
    func viewWillUnload()
}

final class VersionsListInteractor: VersionsListInteractorProtocol {

    private(set) var currentTask: Task<Void, Never>?
    private let projectId: Int
    private let presenter: VersionsListPresenting
    private let worker: VersionsListWorking

    init(projectId: Int, presenter: VersionsListPresenting, worker: VersionsListWorking) {
        self.projectId = projectId
        self.presenter = presenter
        self.worker = worker
    }

    func viewDidLoad() {
        currentTask = Task(operation: fetchData)
    }

    @Sendable
    @MainActor
    func fetchData() async {
        do {
            let data = try await worker.fetchData(projectId: projectId)
            presenter.showData(versions: data.versions, project: data.project)
        } catch {
            print(error)
        }
    }
}
