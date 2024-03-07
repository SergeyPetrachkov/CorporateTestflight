import ArchHelpers
import CorporateTestflightDomain

protocol VersionDetailsInteractorProtocol: AsyncSingleTaskInteractor {
    @MainActor
    func viewDidLoad()

    func viewWillUnload()
}

final class VersionDetailsInteractor: VersionDetailsInteractorProtocol {

    
    private(set) var currentTask: Task<Void, Never>?
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

    @MainActor
    func viewDidLoad() {
        currentTask?.cancel()
        currentTask = Task {
            await fetchData()
        }
    }

    func viewWillUnload() {
        currentTask?.cancel()
    }

    // MARK: - Private logic

    @MainActor
    private func fetchData() async {
        do {
            presenter.showState(.loading(.init(version: version)))
            let tickets = try await worker.fetchTickets(for: version)
            try Task.checkCancellation()
            presenter.showState(
                .loaded(
                    .init(
                        version: version,
                        tickets: tickets
                    )
                )
            )
        } catch {
            if !Task.isCancelled {
                presenter.showState(.failed(.init(message: error.localizedDescription)))
            }
        }
    }
}
