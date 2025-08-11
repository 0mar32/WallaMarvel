import Foundation

final public class URLSessionNetworkSession: NetworkSessionProtocol {

    public init() {}
    
    public func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(for: request)
    }
}
