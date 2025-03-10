import CorporateTestflightDomain
import MockFunc

final class MockTicketsRepository: TicketsRepository {
	let getTicketsMock = MockFunc<Void, [CorporateTestflightDomain.Ticket]>()
	func getTickets() async throws -> [CorporateTestflightDomain.Ticket] {
		getTicketsMock.callAndReturn()
	}

	let getTicketMock = MockThrowingFunc<String, CorporateTestflightDomain.Ticket>()
	func getTicket(key: String) async throws -> CorporateTestflightDomain.Ticket {
		try getTicketMock.callAndReturn(key)
	}
}
