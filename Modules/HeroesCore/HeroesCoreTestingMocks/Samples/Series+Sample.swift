//
//  Series+Sample.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//

@testable import HeroesCore

extension Series {
    static func sample(
        name: String = "Sample Series"
    ) -> Series {
        Series(name: name)
    }
}
