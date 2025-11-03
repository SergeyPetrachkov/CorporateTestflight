import Foundation
import CorporateTestflightDomain
import TestflightNetworking

public struct VersionsRepositoryImpl: VersionsRepository {

	private let api: any TestflightAPIProviding

	public init(api: some TestflightAPIProviding) {
		self.api = api
	}

	public func getVersions(request: CorporateTestflightDomain.VersionsRequest) async throws -> [CorporateTestflightDomain.Version] {
		try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
		return try await api.getVersions(for: request.projectId)
	}

	public func getVersion(by id: CorporateTestflightDomain.Version.ID) async throws -> CorporateTestflightDomain.Version {
		throw NSError(domain: "com.corporatetestflight.playground::getVersion", code: -1)
	}
}
