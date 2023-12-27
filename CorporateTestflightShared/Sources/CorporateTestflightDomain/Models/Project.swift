import Foundation

public struct Project: Sendable, Equatable {

    public typealias ID = Int

    public let id: ID
    public let name: String

    public init(id: ID, name: String) {
        self.id = id
        self.name = name
    }
}

extension Project: Codable {}
