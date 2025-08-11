import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case encodingFailed(Error? = nil)
    case decodingFailed(Error? = nil)
    case serverError(statusCode: Int, data: Data? = nil)
    case noInternet
    case timeout
    case cannotConnect
    case connectionLost
    case urlError(code: Int, description: String)
    case unknown(Error? = nil)
}

extension NetworkError {
    static func map(_ error: Error) -> NetworkError {
        // Already a NetworkError? Pass through
        if let networkError = error as? NetworkError {
            return networkError
        }

        // URL-related errors (invalid, unreachable, etc.)
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return .noInternet
            case .timedOut:
                return .timeout
            case .cannotFindHost, .cannotConnectToHost:
                return .cannotConnect
            case .networkConnectionLost:
                return .connectionLost
            case .badURL:
                return .invalidURL
            default:
                return .urlError(code: urlError.code.rawValue, description: urlError.localizedDescription)
            }
        }

        // Decoding
        if error is DecodingError {
            return .decodingFailed(error)
        }

        // Encoding
        if error is EncodingError {
            return .encodingFailed(error)
        }

        // If nothing matches
        return .unknown(error)
    }
}

