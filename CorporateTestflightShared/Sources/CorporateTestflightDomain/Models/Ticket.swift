import Foundation

public struct Ticket {

    public typealias ID = UUID

    public let id: ID
    public let key: String
    public let title: String
    public let description: String

    public init(id: ID, key: String, title: String, description: String) {
        self.id = id
        self.key = key
        self.title = title
        self.description = description
    }
}

extension Ticket: Codable {}
