import Fluent
import Vapor
import CorporateTestflightDomain

struct TicketsController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let tickets = routes.grouped("tickets")
        tickets.get(use: index)
        tickets.group(":key") { ticket in
            ticket.get(use: show)
        }
    }

    func index(req: Request) async throws -> [CorporateTestflightDomain.Ticket] {
        try await req.factory.ticketsRepository().getTickets()
    }

    func show(req: Request) async throws -> CorporateTestflightDomain.Ticket {
        guard let keyParam = req.parameters.get("key") else {
            throw Abort(.badRequest)
        }
        return try await req.factory.ticketsRepository().getTicket(key: keyParam)
    }
}
