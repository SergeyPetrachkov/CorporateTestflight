import CorporateTestflightDomain

actor TicketsCacheActor: TicketsRepository {

	private let repository: any TicketsRepository
	private var tickets: [String: Task<Ticket, any Error>] = [:]

	init(repository: any TicketsRepository) {
		self.repository = repository
	}

	func getTickets() async throws -> [CorporateTestflightDomain.Ticket] {
		try await repository.getTickets()
	}

	func getTicket(key: String) async throws -> CorporateTestflightDomain.Ticket {
		print("Entering actor for \(key)")
		if let ticketTask = tickets[key] {
			print("Return cached value by \(key)")
			do {
				let value = try await ticketTask.value
				return value
			} catch {
				print("Previously cached task for the ticket \(key) returned error \(error). Will start a new task.")
			}
		}
		let newTicketTask = fetchTicketTask(key: key)
		print("Returning value by fetching \(key)")
		return try await newTicketTask.value
	}

	private func fetchTicketTask(key: String) -> Task<Ticket, any Error> {
		print("Fetching value by \(key)")
		let ticketTask = Task { try await repository.getTicket(key: key) }
		print("Caching value by \(key)")
		tickets[key] = ticketTask
		return ticketTask
	}
}
