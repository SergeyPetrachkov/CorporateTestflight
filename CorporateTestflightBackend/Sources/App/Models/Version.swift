import Vapor
import Fluent

final class Version: Model, Content {

    static var schema: String {
        "versions"
    }

    @ID(key: .id)
    var id: UUID?

    @Field(key: "buildNumber")
    var buildNumber: Int

    @Field(key: "releaseNotes")
    var releaseNotes: String?

    @Field(key: "associatedTicketKeys")
    var associatedTicketKeys: [String]

    init(id: UUID? = nil, buildNumber: Int, releaseNotes: String? = nil, associatedTicketKeys: [String]) {
        self.id = id
        self.buildNumber = buildNumber
        self.releaseNotes = releaseNotes
        self.associatedTicketKeys = associatedTicketKeys
    }

    init() { }
}
