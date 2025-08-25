import Foundation

final public class LoggerMiddleware: MiddlewareProtocol {

    public init() {}

    public func prepare(_ request: URLRequest) throws -> URLRequest {
        debugPrint("➡️ Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")

        if let headers = request.allHTTPHeaderFields {
            debugPrint("Headers: \(headers)")
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            debugPrint("Body: \(bodyString)")
        }

        return request
    }

    public func process(_ response: URLResponse?, data: Data?, error: Error?) throws {
        if let error = error {
            debugPrint("❌ Error: \(error.localizedDescription)")
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            debugPrint("⬅️ Response: Non-HTTP response")
            return
        }

        debugPrint("⬅️ Response: \(httpResponse.statusCode) \(httpResponse.url?.absoluteString ?? "")")

        if let data = data,
           let responseBody = String(data: data, encoding: .utf8) {
            debugPrint("Response Body: \(responseBody)")
        }
    }
}
