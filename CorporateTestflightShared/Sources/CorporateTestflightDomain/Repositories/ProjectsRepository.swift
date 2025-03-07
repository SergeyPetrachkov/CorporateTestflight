public protocol ProjectsRepository: Sendable {
	func getProjects() async throws -> [Project]
	func getProject(by id: Project.ID) async throws -> Project
}
