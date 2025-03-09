import Foundation
import CorporateTestflightDomain

enum QRCodeParseResult: Equatable {
	case ticket(String)
	case version(Version.ID)
	case invalid
}

enum QRCodeParser {
	enum ParsingError: LocalizedError {
		case invalidFormat
		case missingValue

		public var errorDescription: String? {
			switch self {
			case .invalidFormat:
				return "QR code format is invalid"
			case .missingValue:
				return "QR code is missing a value"
			}
		}
	}

	static func parse(_ code: String) throws -> QRCodeParseResult {
		let components = code.split(separator: ":")
		guard components.count == 2 else {
			throw ParsingError.invalidFormat
		}

		let type = components[0]
		let value = String(components[1])

		guard !value.isEmpty else {
			throw ParsingError.missingValue
		}

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
