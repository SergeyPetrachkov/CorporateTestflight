import Foundation
import CorporateTestflightDomain
import CoreNetworking

public protocol TestflightAPIProviding {
    func getProject(id: Project.ID) async throws -> Project
    func getVersions(for projectId: Project.ID) async throws -> [Version]
    func getTicket(key: String) async throws -> Ticket
}

public final class TestflightAPIProvider: TestflightAPIProviding {

    private let session: URLSession
    private let decoder: JSONDecoder

    public init(session: URLSession = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    public func getProject(id: Project.ID) async throws -> Project {
        let apiEndpoint = APIEndpoint<Project>.project(id: id)
        return try await get(apiEndpoint: apiEndpoint)
    }

    public func getVersions(for projectId: Project.ID) async throws -> [Version] {
        let apiEndpoint = APIEndpoint<[Version]>.versions(projectId: projectId)
        return try await get(apiEndpoint: apiEndpoint)
    }

    public func getTicket(key: String) async throws -> Ticket {
        let apiEndpoint = APIEndpoint<Ticket>.ticket(ticketKey: key)
        return try await get(apiEndpoint: apiEndpoint)
    }

    private func get<Type: Decodable>(apiEndpoint: APIEndpoint<Type>) async throws -> Type {
        let urlRequest = apiEndpoint.asURLRequest()
        return try await SimpleRequestExecutor(urlSession: session, decoder: decoder).execute(urlRequest)
    }
}
