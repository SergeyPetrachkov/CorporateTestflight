import CorporateTestflightDomain

// TODO: re-entrancy check + avoid double work
actor TicketsCacheActor: TicketsRepository {

    private let repository: TicketsRepository
    private var tickets: [String: Ticket] = [:]

    init(repository: TicketsRepository) {
        self.repository = repository
    }

    func getTickets() async throws -> [CorporateTestflightDomain.Ticket] {
        try await repository.getTickets()
    }

    func getTicket(key: String) async throws -> CorporateTestflightDomain.Ticket {
        print("Entering actor for \(key)")
        if let ticket = tickets[key] {
            print("Return cached value by \(key)")
            return ticket
        }
        print("Fetching value by \(key)")
        let ticket = try await repository.getTicket(key: key)
        print("Caching value by \(key)")
        tickets[key] = ticket
        print("Return value by \(key)")
        return ticket
    }
}
