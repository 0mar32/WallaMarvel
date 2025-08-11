import Foundation

public protocol NetworkClientProtocol: Sendable {
    func send<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type
    ) async throws -> T
}
