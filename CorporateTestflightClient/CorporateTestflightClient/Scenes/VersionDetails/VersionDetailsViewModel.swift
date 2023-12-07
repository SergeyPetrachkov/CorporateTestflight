import Foundation
import CorporateTestflightDomain

final class VersionDetailsViewModel: ObservableObject {

    enum State {
        case loading(Version)
        case loaded(Version, [Ticket])
        case failed(Error)
    }

    @Published private(set) var state: State

    init(state: State) {
        self.state = state
    }
}
