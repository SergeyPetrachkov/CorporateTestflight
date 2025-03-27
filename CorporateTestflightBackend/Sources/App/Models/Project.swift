import Vapor
import Fluent

final class Project {

	@ID(custom: "id")
	var id: Int?

	@Field(key: "name")
	var name: String

	@Children(for: \.$project)
	var versions: [Version]

	init() {}

	init(id: Int? = nil, name: String) {
		self.id = id
		self.name = name
	}
}

extension Project: Model, Content {
	static var schema: String {
		"projects"
	}
}
