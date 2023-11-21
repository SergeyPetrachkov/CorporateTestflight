import Foundation

public enum TicketRequest {
    case byId(UUID)
    case byKey(String)
}

public protocol TicketsRepository {
    func getTickets() async throws -> [Ticket]
    func getTicket(request: TicketRequest) async throws -> Ticket
}
