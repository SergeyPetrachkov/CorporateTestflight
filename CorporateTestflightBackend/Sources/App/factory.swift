import CorporateTestflightDomain
import Fluent
import Vapor

struct RepositoriesFactory {

    let database: Database

    func versionsRepository() -> VersionsRepository {
        VersionsRepositoryImpl(database: database)
    }

    func ticketsRepository() -> TicketsRepository {
        TicketsRepositoryImpl(database: database)
    }

    func projectsRepository() -> ProjectsRepository {
        ProjectsRepositoryImpl(database: database)
    }
}

extension Request {

    var factory: RepositoriesFactory {
        RepositoriesFactory(database: db)
    }
}
