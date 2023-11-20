import Fluent
import Vapor

struct ProjectsController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let projects = routes.grouped("projects")
        projects.get(use: index)
        projects.group(":id") { project in
            project.get(use: show)
        }
    }

    func index(req: Request) async throws -> [Project] {
        try await Project.query(on: req.db).all()
    }

    func show(req: Request) async throws -> Project {
        guard let project = try await Project.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return project
    }
}
