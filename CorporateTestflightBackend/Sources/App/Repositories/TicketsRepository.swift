import CorporateTestflightDomain
import Fluent
import Vapor

struct TicketsRepositoryImpl: TicketsRepository {

    private let database: Database

    init(database: Database) {
        self.database = database
    }

    func getTickets() async throws -> [CorporateTestflightDomain.Ticket] {
        let persistedEntities = try await Ticket.query(on: database).all()

        return persistedEntities.compactMap { persistedEntity in
            guard let id = persistedEntity.id else {
                return nil
            }
            return CorporateTestflightDomain.Ticket(
                id: id,
                key: persistedEntity.key,
                title: persistedEntity.title,
                description: persistedEntity.description
            )
        }
    }

    func getTicket(request: TicketRequest) async throws -> CorporateTestflightDomain.Ticket {
        switch request {
        case .byId:
            throw Abort(.notImplemented)
        case .byKey(let key):
            guard
                let persistedEntity = try await Ticket
                    .query(on: database)
                    .filter(\.$key == key)
                    .all()
                    .last
            else {
                throw Abort(.notFound)
            }

            return try CorporateTestflightDomain.Ticket(
                id: persistedEntity.requireID(),
                key: persistedEntity.key,
                title: persistedEntity.title,
                description: persistedEntity.description
            )
        }
    }
}
