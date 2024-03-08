@preconcurrency import XCTest
@testable import CorporateTestflightClient
import CorporateTestflightDomain

final class VersionsListInteractorTests: XCTestCase {

    @MainActor
    func test_whenCallSucceeds_showDataGetsCalled() async {
        let env = Environment()
        let sut = env.makeSUT()
        let sample = (
            project: Project(id: 2, name: "Name"),
            versions: [Version(id: UUID(), buildNumber: 1, associatedTicketKeys: [])]
        )
        await env.worker.fetchDataMock.returns(sample)
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

    @MainActor
    func test_whenCallFails_showErrorGetsCalled() async {
        let env = Environment()
        let sut = env.makeSUT()
        let error = NSError(domain: "com.tests.error", code: -1)
        await env.worker.fetchDataMock.throws(error)
        let expectation = expectation(description: "Show error expectation")
        env.presenter.showErrorMock.didCall = { _ in
            expectation.fulfill()
        }
        sut.viewDidLoad()
        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertTrue(env.presenter.showErrorMock.called)
    }

    @MainActor
    func test_whenVersionClicked_outputGetsCalled() async {
        let env = Environment()
        let mockOutput = MockVersionsListInteractorOutput()
        let sut = env.makeSUT(output: mockOutput)
        let sampleVersion = Version(id: UUID(), buildNumber: 1, associatedTicketKeys: [])
        let sample = (
            project: Project(id: 2, name: "Name"),
            versions: [sampleVersion]
        )
        await env.worker.fetchDataMock.returns(sample)
        let expectation = expectation(description: "Show data expectation")
        env.presenter.showDataMock.didCall = { _ in
            expectation.fulfill()
        }

        sut.viewDidLoad()
        await fulfillment(of: [expectation], timeout: 2)

        sut.didSelect(row: .init(id: sampleVersion.id, title: "", subtitle: ""))
        XCTAssertTrue(mockOutput.didEmitEventMock.called)
    }
}

private final class Environment {

    let presenter = MockVersionsListPresenter()
    let worker = MockVersionsListWorker()

    func makeSUT(output: VersionsListInteractorOutput? = nil) -> VersionsListInteractor {
        let sut = VersionsListInteractor(projectId: 1, presenter: presenter, worker: worker)
        sut.output = output
        return sut
    }
}
