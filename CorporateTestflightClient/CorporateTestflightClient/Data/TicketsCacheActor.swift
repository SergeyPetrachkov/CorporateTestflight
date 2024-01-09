import CorporateTestflightDomain

actor TicketsCacheActor: TicketsRepository {

    private let repository: TicketsRepository
    private var tickets: [String: Task<Ticket, Error>] = [:]

    init(repository: TicketsRepository) {
        self.repository = repository
    }

    func getTickets() async throws -> [CorporateTestflightDomain.Ticket] {
        try await repository.getTickets()
    }

    func getTicket(key: String) async throws -> CorporateTestflightDomain.Ticket {
        print("Entering actor for \(key)")
        if let ticketTask = tickets[key] {
            print("Return cached value by \(key)")
            return try await ticketTask.value
        }
        print("Fetching value by \(key)")
        let ticketTask = Task { try await repository.getTicket(key: key) }
        print("Caching value by \(key)")
        tickets[key] = ticketTask
        print("Return value by \(key)")
        return try await ticketTask.value
    }
}
