import XCTest
import CorporateTestflightDomain
import Combine
@testable import CorporateTestflightClient

final class VersionDetailsViewModelTests: XCTestCase {

    @MainActor
    func test_whenStartingViewModel_loadingAndLoadedStatesShouldBePublished() async {
        let env = Environment()
        let returnValue = Ticket(id: UUID(), key: "Key-1", title: "", description: "")
        env.repository.getTicketsMock.returns([returnValue])
        env.repository.getTicketMock.returns(returnValue)
        let sut = env.makeSUT()

        let expectation = expectation(description: "Show data expectation")
        sut.send(.onAppear)
        var states: [VersionDetailsStore.State] = []
        sut.$state
            .dropFirst() // skipping the one that is set on initialisation
            .sink { state in
                states.append(state)
                expectation.fulfill()
            }
            .store(in: &env.cancellables)
        await fulfillment(of: [expectation], timeout: 5)

        XCTAssertEqual(
            states,
            [
                .loaded(
                    .init(
                        version: env.version,
                        tickets: [returnValue]
                    )
                )
            ]
        )
    }

    @MainActor
    func test_whenStartingViewModelAndCancelling_LoadedStateShouldNotBePublished() async {
        let env = Environment()
        let returnValue = Ticket(id: UUID(), key: "Key-1", title: "", description: "")
        env.repository.getTicketsMock.returns([returnValue])
        env.repository.getTicketMock.returns(returnValue)
        let sut = env.makeSUT()

        let expectation = expectation(description: "Show data expectation")
        expectation.isInverted = true
        sut.send(.onAppear)
        sut.send(.onDisappear)
        var states: [VersionDetailsStore.State] = []
        sut.$state
            .sink { state in
                states.append(state)
                if states.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &env.cancellables)
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(states.last, .loading(.init(version: env.version)))
    }
}

private final class Environment {

    let version = Version(
        id: UUID(
            uuidString: "00000000-0000-0000-0000-000000000000"
        )!,
        buildNumber: 1,
        associatedTicketKeys: ["Key-1"]
    )
    var repository = MockTicketsRepository()
    var cancellables: Set<AnyCancellable> = []

    func makeSUT() -> VersionDetailsStore {
        VersionDetailsStore(version: version, fetchTicketsUsecase: FetchTicketsUseCase(ticketsRepository: repository))
    }
}
