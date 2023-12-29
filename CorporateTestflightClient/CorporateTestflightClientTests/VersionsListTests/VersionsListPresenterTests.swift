import XCTest
import CorporateTestflightDomain
@testable import CorporateTestflightClient

final class VersionsListPresenterTests: XCTestCase {

    @MainActor
    func test_whenShowDataCalled_controllerFunctionsGetCalled() {
        let env = Environment()
        let sut = env.makeSUT()

        sut.showData(
            versions: [Version(id: UUID(), buildNumber: 1, associatedTicketKeys: ["Key-1", "Key-2"])],
            project: Project(id: 1, name: "")
        )

        XCTAssertTrue(env.controller.showVersionsMock.called)
        XCTAssertTrue(env.controller.showProjectNameMock.called)
    }

    @MainActor
    func test_whenShowErrorCalled_controllerFunctionsGetCalled() {
        let env = Environment()
        let sut = env.makeSUT()

        sut.showError(NSError(domain: "test", code: -1))

        XCTAssertTrue(env.controller.showErrorMock.called)
    }
}

@MainActor
private final class Environment {

    let controller = MockVersionsListViewController()

    func makeSUT() -> VersionsListPresenter {
        let sut = VersionsListPresenter()
        sut.controller = controller
        return sut
    }
}
