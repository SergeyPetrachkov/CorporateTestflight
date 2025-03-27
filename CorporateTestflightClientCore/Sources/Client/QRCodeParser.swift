import Foundation
import CorporateTestflightDomain

public enum QRCodeParseResult: Equatable {
	case ticket(String)
	case version(Version.ID)
	case invalid
}

public enum QRCodeParser {
	enum ParsingError: LocalizedError {
		case invalidFormat

		public var errorDescription: String? {
			switch self {
			case .invalidFormat:
				return "QR code format is invalid"
			}
		}
	}

	public static func parse(_ code: String) throws -> QRCodeParseResult {
		let components = code.split(separator: ":")
		guard components.count == 2 else {
			throw ParsingError.invalidFormat
		}

		let type = components[0]
		let value = String(components[1])

		switch type {
		case "ticket":
			return .ticket(value)
		case "version":
			guard let uuid = UUID(uuidString: value) else {
				throw ParsingError.invalidFormat
			}
			return .version(uuid)
		default:
			return .invalid
		}
	}
}
