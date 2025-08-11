import Foundation

public enum Payload {
    case empty
    case parameters(Encodable)

    var parameters: Encodable? {
        switch self {
        case .empty:
            return nil
        case .parameters(let encodable):
            return encodable
        }
    }
}

public struct NetworkRequest {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let payload: Payload

    public init(
        path: String,
        method: HTTPMethod,
        headers: [String: String] = [:],
        payload: Payload = .empty
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.payload = payload
    }

    func buildURLRequest(baseURL: URL) throws -> URLRequest {
        var url = baseURL.appendingPathComponent(path)
        var request: URLRequest

        if method == .get, let payload = payload.parameters {
            let queryItems = try URLQueryItemEncoder.encode(payload)
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            url = components?.url ?? url
            request = URLRequest(url: url)
        } else {
            request = URLRequest(url: url)
            if let payload = payload.parameters {
                request.httpBody = try JSONEncoder().encode(payload)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        request.httpMethod = method.rawValue
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
}
