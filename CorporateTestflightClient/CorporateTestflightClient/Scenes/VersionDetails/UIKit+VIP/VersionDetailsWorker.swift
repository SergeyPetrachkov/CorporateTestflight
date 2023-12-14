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
        try await withThrowingTaskGroup(of: Ticket?.self) { group in
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
            try Task.checkCancellation()
            for try await ticket in group {
                
                if let ticket {
                    tickets.append(ticket)
                }
            }
            return tickets
        }
    }
}
