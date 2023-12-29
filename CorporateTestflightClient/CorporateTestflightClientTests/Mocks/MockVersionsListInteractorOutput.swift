@testable import CorporateTestflightClient

final class MockVersionsListInteractorOutput: VersionsListInteractorOutput {
    
    lazy var didEmitEventMock = MockThrowingFunc.mock(for: didEmitEvent(_:))

    func didEmitEvent(_ event: CorporateTestflightClient.VersionsListEvent) {
        didEmitEventMock.call(with: event)
    }
}
