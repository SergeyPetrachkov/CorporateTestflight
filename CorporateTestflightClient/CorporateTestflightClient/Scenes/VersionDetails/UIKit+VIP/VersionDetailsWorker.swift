import CorporateTestflightDomain

protocol VersionDetailsWorking {
    func fetchTickets(for version: Version) async throws -> [Ticket]
}

final class VersionDetailsWorker: VersionDetailsWorking {

    private let ticketsRepository: TicketsRepository

    init(ticketsRepository: TicketsRepository) {
        self.ticketsRepository = ticketsRepository
    }

    deinit {
        print("Deinit \(self)")
    }

    func fetchTickets(for version: Version) async throws -> [Ticket] {
        []
    }
}
