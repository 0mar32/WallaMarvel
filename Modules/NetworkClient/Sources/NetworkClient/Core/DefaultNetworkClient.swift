import Foundation

final public class DefaultNetworkClient: NetworkClientProtocol {
    private let baseURL: URL
    private let session: NetworkSessionProtocol
    private let decoder: ResponseDecoderProtocol
    private let middlewares: [MiddlewareProtocol]

    public init(
        baseURL: URL,
        session: NetworkSessionProtocol = URLSessionNetworkSession(),
        decoder: ResponseDecoderProtocol = JSONResponseDecoder(),
        middlewares: [MiddlewareProtocol] = [LoggerMiddleware()]
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.middlewares = middlewares
    }

    public func send<T: Decodable>(
        _ request: NetworkRequest,
        responseType: T.Type
    ) async throws -> T {
        var urlRequest = try request.buildURLRequest(baseURL: baseURL)

        do {
            // Apply middlewares before sending
            for middleware in middlewares {
                urlRequest = try middleware.prepare(urlRequest)
            }

            let (data, response) = try await session.send(urlRequest)

            // Apply middlewares after receiving
            for middleware in middlewares {
                try middleware.process(response, data: data, error: nil)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
            }

            return try decoder.decode(data, as: T.self)
        } catch {
            throw NetworkError.map(error)
        }
    }
}
