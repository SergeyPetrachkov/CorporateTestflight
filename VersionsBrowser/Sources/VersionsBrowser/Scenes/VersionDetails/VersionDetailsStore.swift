import CorporateTestflightDomain
import Foundation
import UniFlow

final class VersionDetailsStore: ObservableObject, Store {

    typealias Environment = VersionDetails.Environment
    typealias Action = VersionDetails.Action
    typealias State = VersionDetails.State

    let environment: Environment

    @Published private(set) var state: State {
        didSet {
            print("state >> '\(state)'")
        }
    }

    private var loadedTickets: [Ticket] = []

    init(initialState: State, environment: Environment) {
        self.environment = environment
        self.state = .loading(VersionDetailsLoadingView.State(version: environment.version))
    }

    deinit {
        print("❌ deinit \(self)")
    }

    func send(_ action: VersionDetails.Action) async {
        print("'action: \(action)' >> 'state: \(state)'")
        switch action {
        case .start, .refresh:
            await fetchData()
        case .tap(let ticket):
            guard let matchedTicket = loadedTickets.first(where: { $0.id == ticket.id }) else {
                return
            }
            environment.onTickedTapped(matchedTicket)
        }
    }

    private func fetchData() async {
        do {
            let version = environment.version
            let tickets = try await environment.fetchTicketsUsecase.execute(for: version)
            loadedTickets = tickets

            try Task.checkCancellation()

            state = .loaded(.init(version: version, tickets: tickets))
        }
        catch is CancellationError {
            print("Store is stopped. State won't be published")
        } catch {
            state = .failed(State.ErrorViewModel(message: error.localizedDescription))
        }
    }
}
