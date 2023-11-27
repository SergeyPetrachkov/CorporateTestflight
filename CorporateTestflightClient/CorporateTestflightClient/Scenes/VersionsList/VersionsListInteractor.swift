protocol VersionsListInteractorProtocol: AnyObject {
    func viewDidLoad()
}

final class VersionsListInteractor: VersionsListInteractorProtocol, @unchecked Sendable {

    private var task: Task<Void, Never>?
    private let presenter: VersionsListPresenting
    private let worker: VersionsListWorking

    init(presenter: VersionsListPresenting, worker: VersionsListWorking) {
        self.presenter = presenter
        self.worker = worker
    }

    func viewDidLoad() {
        task = Task { @MainActor in
            await fetchVersions()
        }
    }

    @MainActor
    private func fetchVersions() async {
        do {
            _ = try await worker.getVersions(projectId: 1)
        } catch {

        }
    }
}
