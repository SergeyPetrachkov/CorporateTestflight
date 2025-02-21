import Fluent
import Foundation

struct CreateVersions: AsyncMigration {

	struct VersionData: Decodable {
		let id: UUID
		let buildNumber: Int
		let releaseNotes: String
		let associatedTicketKeys: [String]
		let projectId: Int
	}

	private let dataUrl: String

	init(dataUrl: String) {
		self.dataUrl = dataUrl
	}

	func prepare(on database: Database) async throws {
		try await database.schema(Version.schema)
			.id()
			.field("buildNumber", .int32, .required)
			.field("releaseNotes", .string)
			.field("associatedTicketKeys", .array(of: .string), .required)
			.field("projectId", .int32, .required, .references("projects", "id"))
			.create()

		let data = try Data(contentsOf: URL(fileURLWithPath: dataUrl))
		let decoder = JSONDecoder()
		let preppedData = try decoder.decode([VersionData].self, from: data)
		for version in preppedData {
			try await Version(
				id: version.id,
				buildNumber: version.buildNumber,
				releaseNotes: version.releaseNotes,
				associatedTicketKeys: version.associatedTicketKeys,
				projectId: version.projectId
			)
			.create(
				on: database
			)
		}
	}

	func revert(on database: Database) async throws {
		try await database.schema(Version.schema).delete()
	}
}
