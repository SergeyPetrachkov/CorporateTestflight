import CorporateTestflightDomain
import MockFunc

final class MockTicketsRepository: TicketsRepository {

	let getTicketsMock = ThreadSafeMockThrowingFunc<Void, [CorporateTestflightDomain.Ticket]>()
	func getTickets() async throws -> [CorporateTestflightDomain.Ticket] {
		try await getTicketsMock.callAndReturn(())
	}

	let getTicketMock = ThreadSafeMockThrowingFunc<String, CorporateTestflightDomain.Ticket>()
	func getTicket(key: String) async throws -> CorporateTestflightDomain.Ticket {
		try await getTicketMock.callAndReturn(key)
	}
}
