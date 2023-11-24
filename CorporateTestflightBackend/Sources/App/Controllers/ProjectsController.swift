import Fluent
import Vapor
import CorporateTestflightDomain

struct ProjectsController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let projects = routes.grouped("projects")
        projects.get(use: index)
        projects.group(":id") { project in
            project.get(use: show)
        }
    }

    func index(req: Request) async throws -> [CorporateTestflightDomain.Project] {
        try await req.factory.projectsRepository().getProjects()
    }

    func show(req: Request) async throws -> CorporateTestflightDomain.Project {
        guard
            let stringId = req.parameters.get("id"),
            let intId = Int(stringId)
        else {
            throw Abort(.badRequest)
        }
        return try await req.factory.projectsRepository().getProject(by: intId)
    }
}
