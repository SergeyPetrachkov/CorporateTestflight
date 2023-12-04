import CorporateTestflightDomain

protocol VersionsListWorking {
    func fetchData(projectId: Int) async throws -> (project: Project, versions: [Version])
    func getVersions(projectId: Int) async throws -> [CorporateTestflightDomain.Version]
    func getProject(projectId: Int) async throws -> CorporateTestflightDomain.Project
}

final class VersionsListWorker: VersionsListWorking, Sendable {

    private let versionsRepository: VersionsRepository
    private let projectsRepository: ProjectsRepository

    init(versionsRepository: VersionsRepository, projectsRepository: ProjectsRepository) {
        self.versionsRepository = versionsRepository
        self.projectsRepository = projectsRepository
    }

    func fetchData(projectId: Int) async throws -> (project: Project, versions: [Version]) {
        async let versions = getVersions(projectId: projectId)
        async let project = getProject(projectId: projectId)

        do {
            let result = try await (project, versions)
            return result
        } catch {
            print(error)
            fatalError()
        }
    }

    func getVersions(projectId: Int) async throws -> [CorporateTestflightDomain.Version] {
        try await versionsRepository.getVersions(request: .init(projectId: projectId))
    }

    func getProject(projectId: Int) async throws -> CorporateTestflightDomain.Project {
        try await projectsRepository.getProject(by: projectId)
    }
}
