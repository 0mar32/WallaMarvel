import Foundation

public protocol MiddlewareProtocol: Sendable {
    func prepare(_ request: URLRequest) throws -> URLRequest
    func process(_ response: URLResponse?, data: Data?, error: Error?) throws
}

import Foundation

public final class LoggerMiddleware: MiddlewareProtocol {

    public init() {}

    public func prepare(_ request: URLRequest) throws -> URLRequest {
        print("➡️ Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")

        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }

        return request
    }

    public func process(_ response: URLResponse?, data: Data?, error: Error?) throws {
        if let error = error {
            print("❌ Error: \(error.localizedDescription)")
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("⬅️ Response: Non-HTTP response")
            return
        }

        print("⬅️ Response: \(httpResponse.statusCode) \(httpResponse.url?.absoluteString ?? "")")

        if let data = data,
           let responseBody = String(data: data, encoding: .utf8) {
            print("Response Body: \(responseBody)")
        }
    }
}
