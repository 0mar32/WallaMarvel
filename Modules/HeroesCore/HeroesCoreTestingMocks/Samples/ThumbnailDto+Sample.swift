//
//  ThumbnailDto+Sample.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

@testable import HeroesCore

extension ThumbnailDto {
    static func sample(
        path: String = "https://example.com/image",
        `extension`: String = "jpg"
    ) -> ThumbnailDto {
        ThumbnailDto(path: path, extension: `extension`)
    }
}
