import Fluent
import Vapor

struct TicketsController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let tickets = routes.grouped("tickets")
        tickets.get(use: index)
        tickets.group(":key") { ticket in
            ticket.get(use: show)
        }
    }

    func index(req: Request) async throws -> [Ticket] {
        try await Ticket.query(on: req.db).all()
    }

    func show(req: Request) async throws -> Ticket {
        guard let keyParam = req.parameters.get("key") else {
            throw Abort(.badRequest)
        }

        guard
            let ticket = try await Ticket
                .query(on: req.db)
                .filter(\.$key == keyParam)
                .all()
                .last
        else {
            throw Abort(.notFound)
        }
        return ticket
    }
}
