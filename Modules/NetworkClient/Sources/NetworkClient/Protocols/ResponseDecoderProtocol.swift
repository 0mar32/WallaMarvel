import Foundation

public protocol ResponseDecoderProtocol: Sendable {
    func decode<T: Decodable>(_ data: Data, as type: T.Type) throws -> T
}
