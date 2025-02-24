import Fluent
import Foundation

struct CreateTickets: AsyncMigration {

	struct TicketData: Decodable {
		let id: UUID
		let key: String
		let title: String
		let description: String
		let attachments: [String]?
	}

	private let dataUrl: String

	init(dataUrl: String) {
		self.dataUrl = dataUrl
	}

	func prepare(on database: Database) async throws {
		try await database.schema(Ticket.schema)
			.id()
			.field("key", .string, .required)
			.field("title", .string, .required)
			.field("description", .string, .required)
			.field("attachments", .array(of: .string), .required)
			.create()

		let data = try Data(contentsOf: URL(fileURLWithPath: dataUrl))
		let decoder = JSONDecoder()
		let preppedData = try decoder.decode([TicketData].self, from: data)
		for ticket in preppedData {
			try await Ticket(
				id: ticket.id,
				key: ticket.key,
				title: ticket.title,
				description: ticket.description,
				attachments: ticket.attachments ?? []
			)
			.create(
				on: database
			)
		}
	}

	func revert(on database: Database) async throws {
		try await database.schema(Ticket.schema).delete()
	}
}
