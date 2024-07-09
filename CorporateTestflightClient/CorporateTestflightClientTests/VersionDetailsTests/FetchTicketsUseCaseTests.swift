import Testing
import CorporateTestflightDomain
import Foundation
@testable import CorporateTestflightClient

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
        ticketsRepository.getTicketMock.returns(Ticket(id: Ticket.ID(), key: "Fake", title: "", description: ""))
        let sut = makeSUT()

        let result = try await sut.execute(for: version)

        #expect(ticketsRepository.getTicketMock.count == tickets.count)
        #expect(ticketsRepository.getTicketMock.parameters == tickets)
    }

    @Test("Fetch tickets when error throws")
    func fetchTicketsErrorThrown() async throws {
        let version = Version(id: Version.ID(), buildNumber: 1, associatedTicketKeys: ["Key1"])
        ticketsRepository.getTicketMock.throws(URLError(.badServerResponse))
        let sut = makeSUT()

        await #expect(throws: CancellationError.self, performing: {
            _ = try await sut.execute(for: version)
        })

        #expect(ticketsRepository.getTicketMock.count == 1)
        #expect(ticketsRepository.getTicketMock.input == "Key1")
    }
}
