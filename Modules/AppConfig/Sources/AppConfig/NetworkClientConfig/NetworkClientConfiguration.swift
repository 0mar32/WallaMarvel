import Foundation
import NetworkClient

public extension DefaultNetworkClient {
    static let shared: DefaultNetworkClient = .init(
        baseURL: URL(string: "https://gateway.marvel.com:443")!,
        middlewares: [
            // TODO: private key be securely hashed stored, not exposed in the code
            NetworkAPIKeysMiddleware(
                privateApiKey: "20e4c73ebe64fb87efbc02edc21900010c25446e",
                publicApiKey: "d8d7fe1d324f7bf32e53968ee34609ab"
            ),
            LoggerMiddleware()
        ]
    )
}

// some time the APIs are crazy and it just fail with InvalidCredentials error.
// here some alternative keys.
// some time none of them works and some time hey work again 🤷🏻‍♂️

//privateApiKey: "40e44718ecd56f7ca4c88f0f1551793ff2a14f2b"
//publicApiKey: "7ff3eedb58d4a88f4b8c0b59edb1ad37"
//
//privateApiKey: "259034404561768ff21da45183689efe33febbd3"
//publicApiKey: "c40723d058e53912bf7f583907947b11"
