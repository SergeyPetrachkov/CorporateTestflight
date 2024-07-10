import Foundation
import CorporateTestflightDomain
import ArchHelpers

final class VersionDetailsViewModel: ObservableObject {

    // MARK: - Injectables
    private let version: Version

    // MARK: - State
    @Published private(set) var state: State
    private var currentTask: Task<Void, Never>?

    // MARK: - Init
    init(version: Version) {
        self.version = version
        self.state = .loading(VersionDetailsLoadingView.State(version: version))
    }

    deinit {
        print("Deinit \(self)")
    }

    // MARK: - Sync interface controlled by us

    func send(_ action: Action) {
        // load data here somehow (version.associatedTicketKeys & TicketsRepository.getTicket(key: String))
        // create .loaded state
        // update self.state
    }
}
