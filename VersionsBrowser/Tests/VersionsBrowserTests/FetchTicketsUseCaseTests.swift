import CorporateTestflightDomain
@testable import VersionsBrowser
import Foundation
import Testing


@Suite("FetchTicketsUseCase behavioral tests")
struct FetchTicketsUseCaseTests {

	enum TestErrors: Error {
		case test
	}

	let ticketsRepository = MockTicketsRepository()

	func makeSUT() -> FetchTicketsUseCase {
		FetchTicketsUseCase(ticketsRepository: ticketsRepository)
	}

	@Test(
		"Fetch tickets happy path",
		arguments: [[], ["Key1"], ["Key2", "Key3"]]
	)
	func fetchTicketsHappyPath(tickets: [String]) async throws {
		print("Testing \(tickets)")
		let version = Version(id: Version.ID(), buildNumber: 1, associatedTicketKeys: tickets)
		await ticketsRepository.getTicketMock.returns(Ticket(id: Ticket.ID(), key: "Fake", title: "", description: ""))
		let sut = makeSUT()

		let _ = try await sut.execute(for: version)

		await #expect(ticketsRepository.getTicketMock.count == tickets.count)
	}

	@Test("Fetch tickets when error throws")
	func fetchTicketsErrorThrown() async throws {
		let version = Version(id: Version.ID(), buildNumber: 1, associatedTicketKeys: ["Key1"])
		await ticketsRepository.getTicketMock.throws(URLError(.badServerResponse))
		let sut = makeSUT()

		await #expect(throws: CancellationError.self, performing: {
			_ = try await sut.execute(for: version)
		})

		await #expect(ticketsRepository.getTicketMock.count == 1)
		await #expect(ticketsRepository.getTicketMock.input == "Key1")
	}
}
