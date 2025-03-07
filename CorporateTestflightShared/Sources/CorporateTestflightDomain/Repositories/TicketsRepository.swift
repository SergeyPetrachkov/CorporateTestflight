import Foundation

public protocol TicketsRepository: Sendable {
	func getTickets() async throws -> [Ticket]
	func getTicket(key: String) async throws -> Ticket
}

