
protocol ViewControllerLifeCycleBoundInteractor: AnyObject {
    func viewDidLoad()
    func viewWillUnload()
}

protocol AsyncSingleTaskInteractor: AnyObject {
    var currentTask: Task<Void, Never>? { get }
}

extension AsyncSingleTaskInteractor where Self: ViewControllerLifeCycleBoundInteractor {
    func viewWillUnload() {
        currentTask?.cancel()
    }
}

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
        currentTask = Task(operation: fetchVersions)
    }

    @Sendable
    @MainActor
    private func fetchVersions() async {
        do {
            let versions = try await worker.getVersions(projectId: projectId)
            presenter.showVersions(versions)
        } catch {
            print(error)
        }
    }
}
