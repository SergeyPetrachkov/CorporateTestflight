import Vapor
import Fluent

final class Project {

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension Project: Model, Content {
    static var schema: String {
        "projects"
    }
}
