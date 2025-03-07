public struct VersionsRequest: Sendable {

	public let projectId: Project.ID

	public init(projectId: Project.ID) {
		self.projectId = projectId
	}
}

public protocol VersionsRepository: Sendable {
	func getVersions(request: VersionsRequest) async throws -> [Version]
	func getVersion(by id: Version.ID) async throws -> Version
}
