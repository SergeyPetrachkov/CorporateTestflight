public protocol ProjectsRepository {
    func getProjects() async throws -> [Project]
    func getProject(by id: Project.ID) async throws -> Project
}
