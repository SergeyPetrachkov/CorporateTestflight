import Foundation
import CorporateTestflightDomain
import ArchHelpers

final class VersionDetailsViewModel: ObservableObject {

    // MARK: - Injectables
    private let version: Version
    private let fetchTicketsUsecase: FetchTicketsUseCaseProtocol

    // MARK: - State
    @Published private(set) var state: State
    private var currentTask: Task<Void, Never>?

    // MARK: - Init
    init(version: Version, fetchTicketsUsecase: FetchTicketsUseCaseProtocol) {
        self.version = version
        self.fetchTicketsUsecase = fetchTicketsUsecase
        self.state = .loading(VersionDetailsLoadingView.State(version: version))
    }

    deinit {
        print("Deinit \(self)")
    }

    // MARK: - Sync interface controlled by us

    @MainActor
    func send(_ action: Action) {
        switch action {
        case .onAppear, .onReload:
            currentTask?.cancel()
            currentTask = Task {
                await fetchData()
            }
        case .onDisappear:
            currentTask?.cancel()
        }
    }

    // MARK: - Private logic

    @MainActor
    private func fetchData() async {
        do {
            let tickets = try await fetchTicketsUsecase.execute(for: version)
            if !Task.isCancelled {
                state = .loaded(.init(version: version, tickets: tickets))
            } else {
                print("VM is stopped. State won't be published")
            }
        } catch {
            state = .failed(State.ErrorViewModel(message: error.localizedDescription))
        }
    }
}
