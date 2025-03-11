//import CorporateTestflightDomain
//
//final class MockProjectsRepository: ProjectsRepository {
//
//	let getProjectsMock = MockThrowingFunc<(), [Project]>()
//	func getProjects() async throws -> [Project] {
//		try getProjectsMock.callAndReturn(())
//	}
//
//	let getProjectByIdMock = MockThrowingFunc<Project.ID, Project>()
//	func getProject(by id: Project.ID) async throws -> Project {
//		try getProjectByIdMock.callAndReturn(id)
//	}
//}

