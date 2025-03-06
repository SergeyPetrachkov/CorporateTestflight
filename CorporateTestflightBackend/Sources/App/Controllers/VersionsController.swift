import Fluent
import Vapor
import CorporateTestflightDomain

struct VersionsController: RouteCollection {

	func boot(routes: RoutesBuilder) throws {
		let versions = routes.grouped("versions")
		versions.get(use: index)
	}

	func index(req: Request) async throws -> [CorporateTestflightDomain.Version] {
		guard let projectId = req.query[Int.self, at: "projectId"] else {
			throw Abort(.badRequest)
		}
		return try await req.factory.versionsRepository().getVersions(request: .init(projectId: projectId))
	}
}
