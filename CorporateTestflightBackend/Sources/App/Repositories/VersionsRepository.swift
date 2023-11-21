import CorporateTestflightDomain
import Fluent
import Vapor

struct VersionsRepositoryImpl: VersionsRepository {

    private let database: Database

    init(database: Database) {
        self.database = database
    }

    func getVersions() async throws -> [CorporateTestflightDomain.Version] {
        let persistedEntities = try await Version.query(on: database).all()

        return persistedEntities.compactMap { persistedEntity in
            guard let id = persistedEntity.id else {
                return nil
            }
            return CorporateTestflightDomain.Version(
                id: id,
                buildNumber: persistedEntity.buildNumber,
                releaseNotes: persistedEntity.releaseNotes,
                associatedTicketKeys: persistedEntity.associatedTicketKeys
            )
        }
    }
    
    func getVersion(by id: CorporateTestflightDomain.Version.ID) async throws -> CorporateTestflightDomain.Version {
        throw Abort(.notImplemented)
    }
}
