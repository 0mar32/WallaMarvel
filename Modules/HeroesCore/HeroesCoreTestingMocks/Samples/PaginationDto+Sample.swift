//
//  PaginationDto.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//
@testable import HeroesCore

extension PaginationDto {
    static func sample(
        limit: Int = 10,
        offset: Int = 0
    ) -> PaginationDto {
        PaginationDto(limit: limit, offset: offset)
    }
}
