@testable import CorporateTestflightClient
import CorporateTestflightDomain

final class MockVersionsListWorker: VersionsListWorkerProtocol {

    lazy var fetchDataMock = MockThrowingFunc.mock(for: fetchData)
    func fetchData(projectId: Int) async throws -> (project: CorporateTestflightDomain.Project, versions: [CorporateTestflightDomain.Version]) {
        fetchDataMock.call(with: projectId)
        return try await fetchDataMock.asyncOutput
    }
}
