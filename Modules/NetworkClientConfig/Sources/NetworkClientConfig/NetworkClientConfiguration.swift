import Foundation
import NetworkClient

public extension DefaultNetworkClient {
    static let shared: DefaultNetworkClient = .init(
        baseURL: URL(string: "https://gateway.marvel.com:443")!,
        middlewares: [
            NetworkAPIKeysMiddleware(
                privateApiKey: "40e44718ecd56f7ca4c88f0f1551793ff2a14f2b",
                publicApiKey: "7ff3eedb58d4a88f4b8c0b59edb1ad37"
            ),
            LoggerMiddleware()
        ]
    )
}
