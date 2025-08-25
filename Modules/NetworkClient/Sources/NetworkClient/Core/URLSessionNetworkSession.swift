import Foundation

final public class URLSessionNetworkSession: NetworkSessionProtocol {
    private let session: URLSession

    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    public func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}
