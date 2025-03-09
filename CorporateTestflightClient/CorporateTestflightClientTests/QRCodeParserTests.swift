import XCTest
@testable import CorporateTestflightClient

final class QRCodeParserTests: XCTestCase {
	func testParseTicketCode() throws {
		let code = "ticket:JIRA-4"
		let result = try QRCodeParser.parse(code)

		guard case .ticket(let ticketKey) = result else {
			XCTFail("Expected ticket case")
			return
		}
		XCTAssertEqual(ticketKey, "JIRA-4")
	}

	func testParseVersionCode() throws {
		let uuid = UUID()
		let code = "version:\(uuid.uuidString)"
		let result = try QRCodeParser.parse(code)

		guard case .version(let versionId) = result else {
			XCTFail("Expected version case")
			return
		}
		XCTAssertEqual(versionId, uuid)
	}

	func testInvalidFormat() {
		let code = "invalid-format"
		XCTAssertThrowsError(try QRCodeParser.parse(code)) { error in
			XCTAssertEqual(error as? QRCodeParser.ParsingError, .invalidFormat)
		}
	}

	func testInvalidVersionUUID() {
		let code = "version:not-a-uuid"
		XCTAssertThrowsError(try QRCodeParser.parse(code)) { error in
			XCTAssertEqual(error as? QRCodeParser.ParsingError, .invalidFormat)
		}
	}

	func testMissingValue() {
		let code = "ticket:"
		XCTAssertThrowsError(try QRCodeParser.parse(code)) { error in
			XCTAssertEqual(error as? QRCodeParser.ParsingError, .missingValue)
		}
	}
}

