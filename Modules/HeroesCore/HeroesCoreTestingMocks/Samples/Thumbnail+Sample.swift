//
//  Thumbnail+Sample.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

@testable import HeroesCore

extension Thumbnail {
    static func sample(
        path: String = "https://example.com/image",
        `extension`: String = "jpg"
    ) -> Thumbnail {
        Thumbnail(path: path, extension: `extension`)
    }
}
