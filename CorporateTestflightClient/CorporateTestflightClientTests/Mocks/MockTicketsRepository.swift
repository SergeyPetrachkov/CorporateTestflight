import CorporateTestflightDomain

final class MockTicketsRepository: TicketsRepository, @unchecked Sendable {

    lazy var getTicketsMock = MockThrowingFunc.mock(for: getTickets)
    func getTickets() async throws -> [CorporateTestflightDomain.Ticket] {
        getTicketsMock.call(with: ())
        return try await getTicketsMock.asyncOutput
    }

    let getTicketMock = MockThrowingFunc<String, CorporateTestflightDomain.Ticket>()
    func getTicket(key: String) async throws -> CorporateTestflightDomain.Ticket {
        try getTicketMock.callAndReturn(key)
    }
}
