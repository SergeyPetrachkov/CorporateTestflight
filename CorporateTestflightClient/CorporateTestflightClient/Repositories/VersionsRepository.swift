import Foundation
import CorporateTestflightDomain
import TestflightNetworking

struct VersionsRepositoryImpl: VersionsRepository {

	private let api: TestflightAPIProviding

	init(api: TestflightAPIProviding) {
		self.api = api
	}

	func getVersions(request: CorporateTestflightDomain.VersionsRequest) async throws -> [CorporateTestflightDomain.Version] {
		try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
		return try await api.getVersions(for: request.projectId)
	}

	func getVersion(by id: CorporateTestflightDomain.Version.ID) async throws -> CorporateTestflightDomain.Version {
		throw NSError(domain: "com.corporatetestflight.playground::getVersion", code: -1)
	}
}
