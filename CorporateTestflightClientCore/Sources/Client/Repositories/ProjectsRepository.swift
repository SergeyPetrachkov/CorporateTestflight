import Foundation
import CorporateTestflightDomain
import TestflightNetworking

public struct ProjectsRepositoryImpl: ProjectsRepository {

	private let api: any TestflightAPIProviding

	public init(api: some TestflightAPIProviding) {
		self.api = api
	}

	public func getProjects() async throws -> [CorporateTestflightDomain.Project] {
		throw NSError(domain: "com.corporatetestflight.playground::getProjects", code: -1)
	}

	public func getProject(by id: CorporateTestflightDomain.Project.ID) async throws -> CorporateTestflightDomain.Project {
		try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
		return try await api.getProject(id: id)
	}
}
