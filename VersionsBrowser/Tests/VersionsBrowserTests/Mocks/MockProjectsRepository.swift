import MockFunc
import CorporateTestflightDomain

final class MockProjectsRepository: ProjectsRepository {

	let getProjectsMock = MockFunc<(), [Project]>()
	func getProjects() async throws -> [CorporateTestflightDomain.Project] {
		getProjectsMock.callAndReturn()
	}

	let getProjectMock = MockFunc<Project.ID, Project>()
	func getProject(by id: CorporateTestflightDomain.Project.ID) async throws -> CorporateTestflightDomain.Project {
		getProjectMock.callAndReturn(id)
	}
}
