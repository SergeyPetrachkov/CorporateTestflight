import Foundation
import CorporateTestflightDomain
import TestflightNetworking

struct TicketsRepositoryImpl: TicketsRepository {

    private let api: TestflightAPIProviding

    init(api: TestflightAPIProviding) {
        self.api = api
    }

    func getTickets() async throws -> [CorporateTestflightDomain.Ticket] {
        throw NSError(domain: "com.corporatetestflight.playground::getTickets", code: -1)
    }

    func getTicket(key: String) async throws -> Ticket {
        try await Task.sleep(nanoseconds: UInt64.random(in: 1...3) * 1_000_000_000)
        return try await api.getTicket(key: key)
    }
}
