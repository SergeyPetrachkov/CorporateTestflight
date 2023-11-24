import Foundation

public struct Version {

    public typealias ID = UUID

    public let id: ID
    public let buildNumber: Int
    public let releaseNotes: String?
    public let associatedTicketKeys: [String]

    public init(id: ID, buildNumber: Int, releaseNotes: String? = nil, associatedTicketKeys: [String]) {
        self.id = id
        self.buildNumber = buildNumber
        self.releaseNotes = releaseNotes
        self.associatedTicketKeys = associatedTicketKeys
    }
}

extension Version: Codable {}
