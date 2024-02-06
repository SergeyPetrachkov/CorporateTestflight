import CorporateTestflightDomain

protocol FetchProjectOverviewUseCaseProtocol {
    func fetchData(projectId: Int) async throws -> (project: Project, versions: [Version])
}

struct FetchProjectOverviewUseCase: FetchProjectOverviewUseCaseProtocol {

    private let versionsRepository: VersionsRepository
    private let projectsRepository: ProjectsRepository

    init(versionsRepository: VersionsRepository, projectsRepository: ProjectsRepository) {
        self.versionsRepository = versionsRepository
        self.projectsRepository = projectsRepository
    }

    func fetchData(projectId: Int) async throws -> (project: Project, versions: [Version]) {
        async let versions = versionsRepository.getVersions(request: .init(projectId: projectId))
        async let project = projectsRepository.getProject(by: projectId)

        let result = try await (project, versions)
        return result
    }
}
