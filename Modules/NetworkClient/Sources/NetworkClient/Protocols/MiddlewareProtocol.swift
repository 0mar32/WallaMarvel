import Foundation

public protocol MiddlewareProtocol: Sendable {
    func prepare(_ request: URLRequest) throws -> URLRequest
    func process(_ response: URLResponse?, data: Data?, error: Error?) throws
}

extension MiddlewareProtocol {
    public func prepare(_ request: URLRequest) throws -> URLRequest {
        return request
    }

    public func process(_ response: URLResponse?, data: Data?, error: Error?) throws {
    }
}
