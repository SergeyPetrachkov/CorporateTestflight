import Foundation
import Combine

public struct SimpleRequestExecutor {

    public enum Errors: Swift.Error {
        case unknownResponseType
        case decodingError(body: Data, statusCode: Int)
    }

    private let urlSession: URLSession
    private let decoder: JSONDecoder

    public init(urlSession: URLSession, decoder: JSONDecoder) {
        self.urlSession = urlSession
        self.decoder = decoder
    }

    public func execute<Response: Decodable>(_ urlRequest: URLRequest) async throws -> Response {
        let response: (Data, URLResponse) = try await urlSession.data(for: urlRequest)
        let decodingResult = try decoder.decode(Response.self, from: response.0)
        return decodingResult

    }

    public func execute(_ urlRequest: URLRequest) async throws {
        _ = try await urlSession.data(for: urlRequest)
    }
}
