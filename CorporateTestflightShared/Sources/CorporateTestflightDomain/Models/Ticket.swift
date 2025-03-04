import Foundation

public struct Ticket: Sendable, Equatable {

	public typealias ID = UUID

	public let id: ID
	public let key: String
	public let title: String
	public let description: String
	/// urls for attached images
	public let attachments: [String]?

	public init(id: ID, key: String, title: String, description: String, attachments: [String]? = nil) {
		self.id = id
		self.key = key
		self.title = title
		self.description = description
		self.attachments = attachments
	}
}

extension Ticket: Codable {}

