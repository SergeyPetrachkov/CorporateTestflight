public protocol VersionsRepository {
    func getVersions() async throws -> [Version]
    func getVersion(by id: Version.ID) async throws -> Version
}
