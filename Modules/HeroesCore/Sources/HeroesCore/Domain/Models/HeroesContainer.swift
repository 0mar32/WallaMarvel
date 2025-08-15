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

extension HeroesContainerDto {
    func toDomainModel() -> HeroesContainer {
        .init(
            count: count,
            limit: limit,
            offset: offset,
            total: total,
            characters: results.map { $0.toDomainModel() }
        )
    }
}
