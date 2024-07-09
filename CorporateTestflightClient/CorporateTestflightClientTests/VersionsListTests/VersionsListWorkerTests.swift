import Testing
import CorporateTestflightDomain
@testable import CorporateTestflightClient

@Suite("Versions list worker behavioral tests")
struct VersionsListWorkerTests {

    enum TestError: Error {
        case test
    }

    let versionsRepository = MockVersionsRepository()
    let projectsRepository = MockProjectsRepository()

    func makeSUT() -> VersionsListWorker {
        VersionsListWorker(
            versionsRepository: versionsRepository,
            projectsRepository: projectsRepository
        )
    }

    // MARK: - Tests

    @Test("Happy path")
    func fetchData_CallsRepositories() async throws {
        let projectId = Project.ID()
        let expectedProject = Project(id: projectId, name: "Sample Project")
        projectsRepository.getProjectByIdMock.returns(expectedProject)
        versionsRepository.getVersionsMock.returns([])
        let sut = makeSUT()

        let result = try await sut.fetchData(projectId: projectId)

        #expect(result.project == expectedProject, "Returned project does not meet the expectations")
        #expect(result.versions.isEmpty, "Should not have returned any versions")
        #expect(projectsRepository.getProjectsMock.count == 0, "Should not have called getProjects")
        #expect(projectsRepository.getProjectByIdMock.count == 1, "Should not have called getProject more than once")
        #expect(versionsRepository.getVersionByIdMock.count == 0, "Should not have called getVersion")
        #expect(versionsRepository.getVersionsMock.count == 1, "Should not have called getVersions more than once")
    }

    @Test("Failing versions repository causes worker failure")
    func fetchData_failsWhenVersionsRepoFails() async throws {
        let projectId = Project.ID()
        let expectedProject = Project(id: projectId, name: "Sample Project")
        projectsRepository.getProjectByIdMock.returns(expectedProject)
        versionsRepository.getVersionsMock.throws(TestError.test)
        let sut = makeSUT()

        await #expect(throws: TestError.test, performing: {
            _ = try await sut.fetchData(projectId: projectId)
        })

        #expect(projectsRepository.getProjectsMock.count == 0, "Should not have called getProjects")
        #expect(projectsRepository.getProjectByIdMock.count == 1, "Should not have called getProject more than once")
        #expect(versionsRepository.getVersionByIdMock.count == 0, "Should not have called getVersion")
        #expect(versionsRepository.getVersionsMock.count == 1, "Should not have called getVersions more than once")
    }

    @Test("Failing projects repository causes worker failure")
    func fetchData_failsWhenProjectsRepoFails() async throws {
        let projectId = Project.ID()
        projectsRepository.getProjectByIdMock.throws(TestError.test)
        versionsRepository.getVersionsMock.returns([])
        let sut = makeSUT()

        await #expect(throws: TestError.test, performing: {
            _ = try await sut.fetchData(projectId: projectId)
        })

        #expect(projectsRepository.getProjectsMock.count == 0, "Should not have called getProjects")
        #expect(projectsRepository.getProjectByIdMock.count == 1, "Should not have called getProject more than once")
        #expect(versionsRepository.getVersionByIdMock.count == 0, "Should not have called getVersion")
        #expect(versionsRepository.getVersionsMock.count == 1, "Should not have called getVersions more than once")
    }
}
