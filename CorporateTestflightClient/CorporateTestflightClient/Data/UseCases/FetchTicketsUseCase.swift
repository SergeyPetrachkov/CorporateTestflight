import CorporateTestflightDomain

protocol FetchTicketsUseCaseProtocol {
    func execute(for version: Version) async -> [Ticket]
}

struct FetchTicketsUseCase: FetchTicketsUseCaseProtocol {
    
    private let ticketsRepository: TicketsRepository

    init(ticketsRepository: TicketsRepository) {
        self.ticketsRepository = ticketsRepository
    }

    func execute(for version: Version) async -> [Ticket] {
        await withTaskGroup(of: Ticket?.self) { group in
            version.associatedTicketKeys.forEach { ticketKey in
                group.addTask {
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
