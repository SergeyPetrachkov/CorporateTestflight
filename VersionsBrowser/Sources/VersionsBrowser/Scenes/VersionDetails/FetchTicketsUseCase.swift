import CorporateTestflightDomain
import Foundation

protocol FetchTicketsUseCaseProtocol: Sendable {
	func execute(for version: Version) async throws -> [Ticket]
}

struct FetchTicketsUseCase: FetchTicketsUseCaseProtocol {

	private let ticketsRepository: TicketsRepository

	init(ticketsRepository: TicketsRepository) {
		self.ticketsRepository = ticketsRepository
	}

	func execute(for version: Version) async throws -> [Ticket] {
		try await withThrowingTaskGroup(of: (Int, Ticket)?.self) { group in
			for (offset, ticketKey) in version.associatedTicketKeys.enumerated() {
				group.addTask {
					do {
						let ticket = try await ticketsRepository.getTicket(key: ticketKey)
						return (offset, ticket)
					} catch is URLError {
						throw CancellationError()
					} catch {
						print(error)
						return nil
					}
				}
			}
			var tickets: [(Int, Ticket)] = []
			for try await ticket in group {
				if let ticket {
					tickets.append(ticket)
				}
			}
			return tickets.sorted(by: { $0.0 < $1.0 }).compactMap(\.1)
		}
	}
}
