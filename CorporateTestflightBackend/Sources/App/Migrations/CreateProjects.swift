import Fluent

struct CreateProjects: AsyncMigration {

    private let prepopulatedData: [Project] = [
        .init(name: "Successful Startup")
    ]

    func prepare(on database: Database) async throws {
        try await database.schema(Project.schema)
            .id()
            .field("name", .string, .required)
            .create()
        for project in prepopulatedData {
            try await project.create(on: database)
        }
    }

    func revert(on database: Database) async throws {
        try await database.schema(Project.schema).delete()
    }
}
