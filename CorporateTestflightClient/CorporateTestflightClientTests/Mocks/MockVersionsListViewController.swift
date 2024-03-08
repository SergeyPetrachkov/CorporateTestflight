@testable import CorporateTestflightClient

final class MockVersionsListViewController: VersionsListViewControlling, @unchecked Sendable {

    lazy var showVersionsMock = MockFunc.mock(for: showVersions(_:))
    func showVersions(_ versions: [CorporateTestflightClient.VersionsListModels.VersionViewModel]) {
        showVersionsMock.call(with: versions)
    }

    lazy var showProjectNameMock = MockFunc.mock(for: showProjectName(_:))
    func showProjectName(_ projectName: String) {
        showProjectNameMock.call(with: projectName)
    }

    lazy var showErrorMock = MockFunc.mock(for: showError(_:))
    func showError(_ error: Error) {
        showErrorMock.call(with: error)
    }
}
