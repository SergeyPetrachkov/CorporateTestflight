import Fluent

struct CreateProjects: AsyncMigration {

	private let prepopulatedData: [Project] = [
		.init(id: 1, name: "Successful Startup"),
		.init(id: 2, name: "Less than ideal Startup")
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
