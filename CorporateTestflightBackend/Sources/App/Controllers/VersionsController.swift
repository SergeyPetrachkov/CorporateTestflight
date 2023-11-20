import Fluent
import Vapor

struct VersionsController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let versions = routes.grouped("versions")
        versions.get(use: index)
    }

    func index(req: Request) async throws -> [Version] {
        try await Version.query(on: req.db).all()
    }
}
