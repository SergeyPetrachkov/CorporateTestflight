import CorporateTestflightDomain
@preconcurrency import Fluent
import Vapor

struct ProjectsRepositoryImpl: ProjectsRepository {

    private let database: Database

    init(database: Database) {
        self.database = database
    }

    func getProjects() async throws -> [CorporateTestflightDomain.Project] {
        let persistedEntities = try await Project.query(on: database).all()

        return persistedEntities.compactMap { persistedEntity in
            guard let id = persistedEntity.id else {
                return nil
            }
            return CorporateTestflightDomain.Project(id: id, name: persistedEntity.name)
        }
    }

    func getProject(by id: CorporateTestflightDomain.Project.ID) async throws -> CorporateTestflightDomain.Project {
        guard
            let persistedEntity = try await Project.find(id, on: database)
        else {
            throw Abort(.notFound)
        }

        return try CorporateTestflightDomain.Project(
            id: persistedEntity.requireID(),
            name: persistedEntity.name
        )
    }
}
