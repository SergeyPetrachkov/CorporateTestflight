import XCTest
import MockFunc
import CorporateTestflightDomain
@testable import CorporateTestflightClient

final class TicketsCacheActorTests: XCTestCase {

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

	struct Environment {
		let repository = MockTicketsRepository()

		func makeSUT() -> TicketsCacheActor {
			TicketsCacheActor(repository: repository)
		}
	}

	func test_GetTickets_ProxiesToRepository() async throws {
		// Given
		let env = Environment()
		let sut = env.makeSUT()
		let expectedTickets = [
			Ticket(id: UUID(), key: "TEST-1", title: "Test", description: "Test description"),
			Ticket(id: UUID(), key: "TEST-2", title: "Test 2", description: "Test description 2")
		]
		await env.repository.getTicketsMock.returns(expectedTickets)

		// When
		let tickets = try await sut.getTickets()

		// Then
		let calledOnce = await env.repository.getTicketsMock.calledOnce
		XCTAssertEqual(tickets, expectedTickets)
		XCTAssertTrue(calledOnce)
	}

	func test_GetTicket_CachesValue() async throws {
		// Given
		let env = Environment()
		let sut = env.makeSUT()
		let expectedTicket = Ticket(id: UUID(), key: "TEST-1", title: "Test", description: "Test description")
		await env.repository.getTicketMock.returns(expectedTicket)

		// When
		let firstResult = try await sut.getTicket(key: "TEST-1")
		let secondResult = try await sut.getTicket(key: "TEST-1")

		// Then
		let calledOnce = await env.repository.getTicketMock.calledOnce
		XCTAssertEqual(firstResult, expectedTicket)
		XCTAssertEqual(secondResult, expectedTicket)
		XCTAssertTrue(calledOnce)
	}

	func test_GetTicket_ReusesInProgressTask() async throws {
		// Given
		let env = Environment()
		let sut = env.makeSUT()
		let expectedTicket = Ticket(id: UUID(), key: "TEST-1", title: "Test", description: "Test description")
		await env.repository.getTicketMock.returns(expectedTicket)

		// When
		await withTaskGroup(of: Void.self) { group in
			for _ in 0..<1000 {
				group.addTask {
					_ = try? await sut.getTicket(key: "TEST-1")
				}
			}
			for await _ in group { }
		}

		// Then
		let calledOnce = await env.repository.getTicketMock.calledOnce
		XCTAssertTrue(calledOnce)
	}

	func test_GetTicket_EvictsFailedRequest() async throws {
		// Given
		let env = Environment()
		let sut = env.makeSUT()
		let testError = NSError(domain: "test", code: -1)
		await env.repository.getTicketMock.throws(testError)

		// When/Then
		do {
			_ = try await sut.getTicket(key: "TEST-1")
			XCTFail("Expected error")
		} catch {
			// Now try again with success
			let expectedTicket = Ticket(id: UUID(), key: "TEST-1", title: "Test", description: "Test description")
			await env.repository.getTicketMock.returns(expectedTicket)

			let result = try await sut.getTicket(key: "TEST-1")
			let callCount = await env.repository.getTicketMock.count
			XCTAssertEqual(result, expectedTicket)
			XCTAssertEqual(callCount, 2)
		}
	}
}
