import CorporateTestflightDomain

final class MockTicketsRepository: TicketsRepository {
    
    lazy var getTicketsMock = MockThrowingFunc.mock(for: getTickets)
    func getTickets() async throws -> [CorporateTestflightDomain.Ticket] {
        getTicketsMock.call(with: ())
        return try await getTicketsMock.asyncOutput
    }
    
    var getTicketCallsCount = 0
    var getTicketCalled: Bool {
        getTicketCallsCount > 0
    }
    var getTicketReceivedTicketKey: String?
    var getTicketReceivedInvocations: [String] = []
    var getTicketClosure: ((String) async throws -> CorporateTestflightDomain.Ticket)?

    func getTicket(key: String) async throws -> CorporateTestflightDomain.Ticket {
        getTicketCallsCount += 1
        getTicketReceivedTicketKey = key
        getTicketReceivedInvocations.append(key)
        return try await getTicketClosure!(key)
    }
}
