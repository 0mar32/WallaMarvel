import Foundation

public struct HeroesContainer: Sendable {
    public let count: Int
    public let limit: Int
    public let offset: Int
    public let total: Int
    public let characters: [Hero]

    public init(count: Int, limit: Int, offset: Int, total: Int, characters: [Hero]) {
        self.count = count
        self.limit = limit
        self.offset = offset
        self.total = total
        self.characters = characters
    }
}

public struct Hero: Sendable {
    public let id: Int
    public let name: String
    public let thumbnail: Thumbnail

    public init(id: Int, name: String, thumbnail: Thumbnail) {
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
    }
}

public struct Thumbnail: Sendable {
    public let path: String
    public let `extension`: String

    public init(path: String, `extension`: String) {
        self.path = path
        self.extension = `extension`
    }
}

