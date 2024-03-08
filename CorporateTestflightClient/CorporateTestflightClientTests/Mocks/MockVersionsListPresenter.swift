@testable import CorporateTestflightClient
import CorporateTestflightDomain

final class MockVersionsListPresenter: VersionsListPresenting, @unchecked Sendable {

    lazy var showDataMock = MockFunc.mock(for: showData)
    func showData(versions: [CorporateTestflightDomain.Version], project: CorporateTestflightDomain.Project) {
        showDataMock.call(with: (versions, project))
    }

    lazy var showErrorMock = MockFunc.mock(for: showError)
    func showError(_ error: Error) {
        showErrorMock.call(with: error)
    }
}
