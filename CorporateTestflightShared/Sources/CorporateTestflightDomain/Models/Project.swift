import Foundation

public struct Project {

    public typealias ID = UUID

    public let id: ID
    public let name: String

    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}

extension Project: Codable {}
