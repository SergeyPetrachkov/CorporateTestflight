import CoreNetworking
import CorporateTestflightDomain

public enum Environment {
    public static var baseUrl = "http://127.0.0.1:8080"
}

public extension APIEndpoint {
    
    static func project(id: Project.ID) -> APIEndpoint<Project> {
        APIEndpoint<Project>(path: "\(Environment.baseUrl)/projects/\(id)", customHeaders: nil)
    }

    static func versions(projectId: Project.ID) -> APIEndpoint<[Version]> {
        APIEndpoint<[Version]>(path: "\(Environment.baseUrl)/versions", customHeaders: nil, parameters: ["projectId": projectId])
    }

    static func ticket(ticketKey: String) -> APIEndpoint<Ticket> {
        APIEndpoint<Ticket>(path: "\(Environment.baseUrl)/ticket/\(ticketKey)", customHeaders: nil)
    }
}
