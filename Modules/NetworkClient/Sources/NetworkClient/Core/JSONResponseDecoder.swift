import Foundation

public struct JSONResponseDecoder: ResponseDecoderProtocol {
    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func decode<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        try decoder.decode(T.self, from: data)
    }
}
