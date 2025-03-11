//import CorporateTestflightDomain
//
//final class MockVersionsRepository: VersionsRepository {
//
//	let getVersionByIdMock = MockThrowingFunc<Version.ID, Version>()
//	func getVersion(by id: Version.ID) async throws -> Version {
//		try getVersionByIdMock.callAndReturn(id)
//	}
//
//	let getVersionsMock = MockThrowingFunc<VersionsRequest, [Version]>()
//	func getVersions(request: VersionsRequest) async throws -> [Version] {
//		try getVersionsMock.callAndReturn(request)
//	}
//}

