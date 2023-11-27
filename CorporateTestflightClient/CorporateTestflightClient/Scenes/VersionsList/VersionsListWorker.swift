import CorporateTestflightDomain
import Foundation

protocol VersionsListWorking {
    func getVersions(projectId: Int) async throws -> [CorporateTestflightDomain.Version]
}

struct VersionsRepositoryImpl: VersionsRepository {

    func getVersions(request: CorporateTestflightDomain.VersionsRequest) async throws -> [CorporateTestflightDomain.Version] {
        []
    }
    
    func getVersion(by id: CorporateTestflightDomain.Version.ID) async throws -> CorporateTestflightDomain.Version {
        throw NSError()
    }
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
