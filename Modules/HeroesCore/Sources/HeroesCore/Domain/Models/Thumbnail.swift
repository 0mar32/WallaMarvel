//
//  Thumbnail.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//
import Foundation

public struct Thumbnail: Equatable, Sendable {
    public let path: String
    public let `extension`: String

    public init(path: String, `extension`: String) {
        self.path = path
        self.extension = `extension`
    }
}

extension ThumbnailDto {
    func toDomainModel() -> Thumbnail {
        .init(path: path, extension: `extension`)
    }
}
