import Foundation
import NetworkClient

public extension DefaultNetworkClient {
    static let shared: DefaultNetworkClient = .init(
        baseURL: URL(string: "https://gateway.marvel.com:443")!,
        middlewares: [
            // TODO: should be securely stored
            NetworkAPIKeysMiddleware(
                privateApiKey: "259034404561768ff21da45183689efe33febbd3",
                publicApiKey: "c40723d058e53912bf7f583907947b11"
            ),
            LoggerMiddleware()
        ]
    )
}
