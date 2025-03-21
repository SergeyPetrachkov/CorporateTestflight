import MockFunc
import CorporateTestflightDomain

final class MockVersionsRepository: VersionsRepository {

	let getVersionsMock = MockThrowingFunc<VersionsRequest, [Version]>()
	func getVersions(request: CorporateTestflightDomain.VersionsRequest) async throws -> [CorporateTestflightDomain.Version] {
		try getVersionsMock.callAndReturn(request)
	}

	let getVersionMock = MockThrowingFunc<CorporateTestflightDomain.Version.ID, Version>()
	func getVersion(by id: CorporateTestflightDomain.Version.ID) async throws -> CorporateTestflightDomain.Version {
		try getVersionMock.callAndReturn(id)
	}
}
