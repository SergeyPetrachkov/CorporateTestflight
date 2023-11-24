public struct VersionsRequest {
    
    public let projectId: Project.ID

    public init(projectId: Project.ID) {
        self.projectId = projectId
    }
}

public protocol VersionsRepository {
    func getVersions(request: VersionsRequest) async throws -> [Version]
    func getVersion(by id: Version.ID) async throws -> Version
}
