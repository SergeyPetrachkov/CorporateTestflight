import Foundation
import CorporateTestflightDomain
import MockFunc
import TestflightNetworking

public final class TestflightAPIProvidingMock: TestflightAPIProviding {

	public init() {}

	public let getProjectMock = ThreadSafeMockThrowingFunc<Project.ID, Project>()
	public func getProject(id: Project.ID) async throws -> Project {
		try await getProjectMock.callAndReturn(id)
	}

	public let getVersionsMock = ThreadSafeMockThrowingFunc<Project.ID, [Version]>()
	public func getVersions(for projectId: Project.ID) async throws -> [Version] {
		try await getVersionsMock.callAndReturn(projectId)
	}

	public let getTicketMock = ThreadSafeMockThrowingFunc<String, Ticket>()
	public func getTicket(key: String) async throws -> Ticket {
		try await getTicketMock.callAndReturn(key)
	}

	public let getResourceMock = ThreadSafeMockThrowingFunc<URL, Data>()
	public func getResource(url: URL) async throws -> Data {
		try await getResourceMock.callAndReturn(url)
	}
}
