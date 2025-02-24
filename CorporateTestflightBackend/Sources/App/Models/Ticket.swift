import Vapor
import Fluent

final class Ticket: Model, Content {

	static var schema: String {
		"tickets"
	}

	@ID(key: .id)
	var id: UUID?

	@Field(key: "key")
	var key: String

	@Field(key: "title")
	var title: String

	@Field(key: "description")
	var description: String

	@Field(key: "attachments")
	var attachments: [String]

	init() {}

	init(id: UUID? = nil, key: String, title: String, description: String, attachments: [String]) {
		self.id = id
		self.title = title
		self.key = key
		self.description = description
		self.attachments = attachments
	}
}
