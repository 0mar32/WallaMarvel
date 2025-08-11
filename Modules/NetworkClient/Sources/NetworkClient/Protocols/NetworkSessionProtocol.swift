import Foundation

public protocol NetworkSessionProtocol: Sendable {
    func send(_ request: URLRequest) async throws -> (Data, URLResponse)
}

