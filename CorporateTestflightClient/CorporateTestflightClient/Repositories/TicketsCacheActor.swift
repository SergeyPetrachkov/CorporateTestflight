import CorporateTestflightDomain

actor TicketsCacheActor: TicketsRepository {

	private enum Cacheable<T> {
		case cached(T)
		case inProgress(Task<T, any Error>)
	}

	/// The underlying repo implementation, that does the actual fetching
	private let repository: any TicketsRepository

	/// Tickets property stores the cached Tickets or Tasks-in-progress to retrieve tickets
	private var tickets: [String: Cacheable<Ticket>] = [:]

	init(repository: any TicketsRepository) {
		self.repository = repository
	}

	// We don't care about cache here, thus it's just a proxy call
	func getTickets() async throws -> [CorporateTestflightDomain.Ticket] {
		try await repository.getTickets()
	}

	// This is handing an actor re-entrancy problem
	// * If we've got a ticket with the key - return it immediately and synchronously
	// * If we've got an in-progress ticket - await it for the value
	// * If we've got no records, start a new thing:
	//   1. Create a task that calls a repo
	//   2. Put this task into the `tickets` property to make the actor aware of the in-progress state
	//   3. Await the value of the fetching Task
	//      3.1 If the task succeeds, update the `tickets` property with `.cached(T)`
	//      3.2 If the task fails, evict the record from the `ticketsz property, so it can be re-tried
	func getTicket(key: String) async throws -> CorporateTestflightDomain.Ticket {
		print("Entering actor for \(key)")
		switch tickets[key] {
		case .cached(let ticket):
			print("Returning cached value by \(key)")
			return ticket
		case .inProgress(let task):
			print("Awaiting existing task for \(key)")
			return try await task.value
		case .none:
			print("Creating a new task for \(key)")
			let ticketTask = Task {
				print("Fetching value by \(key)")
				return try await repository.getTicket(key: key)
			}
			print("Marking value by \(key) in-progress")
			tickets[key] = .inProgress(ticketTask)
			do {
				let ticketValue = try await ticketTask.value
				print("Caching value by \(key)")
				tickets[key] = .cached(ticketValue)
				print("Returning value by \(key)")
				return ticketValue
			} catch {
				print("Failed to catch value by \(key). Will evict the operation from cache")
				tickets[key] = nil
				print("Will rethrow error")
				throw error
			}
		}
	}
}
