//
//  HeroesResponseDto+sample.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//
@testable import HeroesCore

extension HeroesResponseDto {
    static func sample(
        data: HeroesContainerDto = .sample()
    ) -> HeroesResponseDto {
        HeroesResponseDto(data: data)
    }
}
