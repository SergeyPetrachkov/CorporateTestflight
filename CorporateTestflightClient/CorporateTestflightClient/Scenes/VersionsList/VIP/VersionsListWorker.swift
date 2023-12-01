import CorporateTestflightDomain

protocol VersionsListWorking {
    func getVersions(projectId: Int) async throws -> [CorporateTestflightDomain.Version]
}

final class VersionsListWorker: VersionsListWorking {
    
    private let repository: VersionsRepository

    init(repository: VersionsRepository) {
        self.repository = repository
    }

    func getVersions(projectId: Int) async throws -> [CorporateTestflightDomain.Version] {
        try await repository.getVersions(request: .init(projectId: projectId))
    }
}
