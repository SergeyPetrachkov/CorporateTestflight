import Foundation
import CorporateTestflightDomain
import TestflightNetworking

struct ProjectsRepositoryImpl: ProjectsRepository {

	private let api: TestflightAPIProviding

	init(api: TestflightAPIProviding) {
		self.api = api
	}

	func getProjects() async throws -> [CorporateTestflightDomain.Project] {
		throw NSError(domain: "com.corporatetestflight.playground::getProjects", code: -1)
	}

	func getProject(by id: CorporateTestflightDomain.Project.ID) async throws -> CorporateTestflightDomain.Project {
		try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
		return try await api.getProject(id: id)
	}
}
