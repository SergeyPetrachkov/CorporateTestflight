import CorporateTestflightDomain
import MockFunc
@testable import VersionsBrowser

final class MockFetchProjectAndVersionsUsecase: FetchProjectAndVersionsUsecase {

	let executeMock = MockThrowingFunc<Int, (project: CorporateTestflightDomain.Project, versions: [CorporateTestflightDomain.Version])>()
	func execute(projectId: Int) async throws -> (project: CorporateTestflightDomain.Project, versions: [CorporateTestflightDomain.Version]) {
		try executeMock.callAndReturn(projectId)
	}
}
