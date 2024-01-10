import Foundation
import CorporateTestflightDomain
import ArchHelpers

final class VersionDetailsViewModel: ObservableObject, ViewModelLifeCycle {

    // MARK: - Injectables
    private let version: Version
    private let ticketsRepository: TicketsRepository

    // MARK: - State
    @Published private(set) var state: State

    // MARK: - Init
    init(version: Version, ticketsRepository: TicketsRepository) {
        self.version = version
        self.ticketsRepository = ticketsRepository
        self.state = .loading(State.VersionPreviewViewModel(version: version))
    }

    deinit {
        print("Deinit \(self)")
    }

    // MARK: - Async interface controlled by SwiftUI
    @MainActor
    func startAsync() async {

    }

    // MARK: - Sync interface controlled by us
    func start() {

    }

    func stop() {

    }

    // MARK: - Private logic

}
