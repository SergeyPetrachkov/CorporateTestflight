import Foundation
import CorporateTestflightDomain
import TestflightNetworking

public struct TicketsRepositoryImpl: TicketsRepository {

	private let api: any TestflightAPIProviding

	public init(api: any TestflightAPIProviding) {
		self.api = api
	}

	public func getTickets() async throws -> [CorporateTestflightDomain.Ticket] {
		throw NSError(domain: "com.corporatetestflight.playground::getTickets", code: -1)
	}

	public func getTicket(key: String) async throws -> Ticket {
		try await Task.sleep(nanoseconds: UInt64.random(in: 1...2) * 1_000_000_000)
		return try await api.getTicket(key: key)
	}
}

