import Foundation

enum URLQueryItemEncoder {
    static func encode<T: Encodable>(_ value: T) throws -> [URLQueryItem] {
        let data = try JSONEncoder().encode(value)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return []
        }
        return dict.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
    }
}
