import Foundation

public struct HeroesResponseDto: Decodable {
    let data: HeroesContainerDto
}

struct HeroesContainerDto: Decodable {
    let count: Int
    let limit: Int
    let offset: Int
    let total: Int
    let results: [HeroDto]
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

struct HeroDto: Decodable {
    let id: Int
    let name: String
    let thumbnail: ThumbnailDto
}

extension HeroDto {
    func toDomainModel() -> Hero {
        .init(
            id: id,
            name: name,
            thumbnail: thumbnail.toDomainModel()
        )
    }
}

struct ThumbnailDto: Decodable {
    let path: String
    let `extension`: String
}

extension ThumbnailDto {
    func toDomainModel() -> Thumbnail {
        .init(path: path, extension: `extension`)
    }
}
