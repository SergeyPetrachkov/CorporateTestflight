import Fluent
import Vapor
import CorporateTestflightDomain

struct VersionsController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let versions = routes.grouped("versions")
        versions.get(use: index)
    }

    func index(req: Request) async throws -> [CorporateTestflightDomain.Version] {
        try await req.factory.versionsRepository().getVersions()
    }
}
