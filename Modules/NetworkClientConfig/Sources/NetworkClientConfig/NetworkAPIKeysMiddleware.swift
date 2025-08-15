import Foundation
import CryptoKit
import NetworkClient

final public class NetworkAPIKeysMiddleware: MiddlewareProtocol {
    private enum Constants {
        static let apiKeyQueryParameterName = "apikey"
        static let timeStampParameterName = "ts"
        static let hashParameterName = "hash"

    }

    private let privateApiKey: String
    private let publicApiKey: String

    init(privateApiKey: String, publicApiKey: String) {
        self.privateApiKey = privateApiKey
        self.publicApiKey = publicApiKey
    }

    public func prepare(_ request: URLRequest) throws -> URLRequest {
        var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)

        // Generate timestamp
        let ts = String(Int(Date().timeIntervalSince1970))

        // Create hash: ts + privateKey + publicKey
        let rawString = ts + privateApiKey + publicApiKey
        let digest = Insecure.MD5.hash(data: rawString.data(using: .utf8)!)
        let hash = digest.map { String(format: "%02hhx", $0) }.joined()

        // Inject query params
        var queryItems = components?.queryItems ?? []
        queryItems
            .append(
                URLQueryItem(
                    name: Constants.apiKeyQueryParameterName,
                    value: publicApiKey
                )
            )
        queryItems
            .append(
                URLQueryItem(name: Constants.timeStampParameterName, value: ts)
            )
        queryItems
            .append(
                URLQueryItem(name: Constants.hashParameterName, value: hash)
            )
        components?.queryItems = queryItems

        var modifiedRequest = request
        modifiedRequest.url = components?.url
        return modifiedRequest
    }
}
