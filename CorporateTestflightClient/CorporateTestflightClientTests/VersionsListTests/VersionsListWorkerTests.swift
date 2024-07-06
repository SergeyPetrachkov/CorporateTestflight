import Testing
import CorporateTestflightDomain
@testable import CorporateTestflightClient

@Suite("Versions list worker behavioral tests")
struct VersionsListWorkerTests {

    @Test("Happy path")
    func fetchData_CallsRepositories() async throws {
        let env = Environment()
        let projectId = Project.ID()
        let expectedProject = Project(id: projectId, name: "Sample Project")
        env.projectsRepository.getProjectByIdMock.returns(expectedProject)
        env.versionsRepository.getVersionsMock.returns([])
        let sut = env.makeSUT()

        let result = try await sut.fetchData(projectId: projectId)

        #expect(result.project == expectedProject, "Returned project does not meet the expectations")
        #expect(result.versions.isEmpty, "Should not have returned any versions")
        #expect(env.projectsRepository.getProjectsMock.count == 0, "Should not have called getProjects")
        #expect(env.projectsRepository.getProjectByIdMock.count == 1, "Should not have called getProject more than once")
        #expect(env.versionsRepository.getVersionByIdMock.count == 0, "Should not have called getVersion")
        #expect(env.versionsRepository.getVersionsMock.count == 1, "Should not have called getVersions more than once")
    }
}

private struct Environment {

    let versionsRepository = MockVersionsRepository()
    let projectsRepository = MockProjectsRepository()

    func makeSUT() -> VersionsListWorker {
        VersionsListWorker(
            versionsRepository: versionsRepository,
            projectsRepository: projectsRepository
        )
    }
}
