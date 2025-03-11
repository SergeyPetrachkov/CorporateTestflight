//@testable import CorporateTestflightClient
//import CorporateTestflightDomain
//
//actor MockVersionsListWorker: VersionsListWorkerProtocol {
//
//	private(set) lazy var fetchDataMock = AsyncThrowingMockFunc.mock(for: fetchData)
//
//	func fetchData(projectId: Int) async throws -> (project: CorporateTestflightDomain.Project, versions: [CorporateTestflightDomain.Version]) {
//		await fetchDataMock.call(with: projectId)
//		return try await fetchDataMock.output
//	}
//}

