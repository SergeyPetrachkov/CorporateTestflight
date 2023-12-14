import Foundation
import CorporateTestflightDomain
import ArchHelpers

final class VersionDetailsViewModel: ObservableObject, ViewModelLifeCycle {

    // MARK: - Injectables
    private let version: Version
    private let ticketsRepository: TicketsRepository

    // MARK: - State
    @Published private(set) var state: State
    private var currentTask: Task<Void, Never>?

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
    func start() async {
        let tickets = await fetchTickets(for: version)
        state = .loaded(.init(version: version, tickets: tickets))
    }

    // MARK: - Sync interface controlled by us
    func start() {
        currentTask?.cancel()
        currentTask = Task(operation: fetchData)
    }

    func stop() {
        currentTask?.cancel()
    }

    // MARK: - Private logic

    @Sendable
    @MainActor
    private func fetchData() async {
        let tickets = await fetchTickets(for: version)
        state = .loaded(.init(version: version, tickets: tickets))
    }

    private func fetchTickets(for version: Version) async -> [Ticket] {
        await withTaskGroup(of: Ticket?.self) { group in
            version.associatedTicketKeys.forEach { ticketKey in
                group.addTask { [ticketsRepository] in
                    do {
                        return try await ticketsRepository.getTicket(key: ticketKey)
                    } catch {
                        print(error)
                        return nil
                    }
                }
            }
            var tickets: [Ticket] = []
            for await ticket in group {
                if let ticket {
                    tickets.append(ticket)
                }
            }
            return tickets
        }
    }
}
