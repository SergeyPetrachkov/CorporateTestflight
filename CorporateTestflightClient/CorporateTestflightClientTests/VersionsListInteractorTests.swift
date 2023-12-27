import XCTest
@testable import CorporateTestflightClient
import CorporateTestflightDomain

final class VersionsListInteractorTests: XCTestCase {

    func test_whenCallSucceeds_showDataGetsCalled() async {
        let env = Environment()
        let sut = env.makeSUT()
        let sample = (project: Project(id: 2, name: "Name"),
                      versions: [Version(id: UUID(), buildNumber: 1, associatedTicketKeys: [])])
        env.usecase.fetchDataMock.returns(sample)
        let expectation = expectation(description: "Show data expectation")
        env.presenter.showDataMock.didCall = { _ in
            expectation.fulfill()
        }

        sut.viewDidLoad()

        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertTrue(env.presenter.showDataMock.called)
        XCTAssertEqual(env.presenter.showDataMock.input.0, sample.versions)
        XCTAssertEqual(env.presenter.showDataMock.input.1, sample.project)
    }

    func test_whenCallFails_showErrorGetsCalled() async {
        let env = Environment()
        let sut = env.makeSUT()
        let error = NSError(domain: "com.tests.error", code: -1)
        env.usecase.fetchDataMock.throws(error)
        let expectation = expectation(description: "Show error expectation")
        env.presenter.showErrorMock.didCall = { _ in
            expectation.fulfill()
        }
        sut.viewDidLoad()
        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertTrue(env.presenter.showErrorMock.called)
    }
}

private final class Environment {

    let presenter = MockVersionsListPresenter()
    let usecase = MockFetchProjectOverviewUseCase()

    func makeSUT() -> VersionsListInteractor {
        VersionsListInteractor(projectId: 1, presenter: presenter, usecase: usecase)
    }
}
