import CorporateTestflightDomain

// Plan: 7.3 First actor TDD
// Straight-forward implementation with Dictionary
// Actor re-entrancy ==> Cacheable<T>
// Final implementation:
// * If we've got a ticket with the key - return it immediately and synchronously
// * If we've got an in-progress ticket - await it for the value
// * If we've got no records, start a new thing:
//   1. Create a task that calls a repo
//   2. Put this task into the `tickets` property to make the actor aware of the in-progress state
//   3. Await the value of the fetching Task
//      3.1 If the task succeeds, update the `tickets` property with `.cached(T)`
//      3.2 If the task fails, evict the record from the `tickets property, so it can be re-tried

public actor TicketsCacheActor: TicketsRepository {

	/// The underlying repo implementation, that does the actual fetching
	private let repository: any TicketsRepository

	public init(repository: any TicketsRepository) {
		self.repository = repository
	}

	// We don't care about cache here, thus it's just a proxy call
	public func getTickets() async throws -> [CorporateTestflightDomain.Ticket] {
		try await repository.getTickets()
	}

	public func getTicket(key: String) async throws -> CorporateTestflightDomain.Ticket {
		print("Entering actor for \(key)")
		enum Error: Swift.Error {
			case notImplemented
		}
		throw Error.notImplemented
	}
}
