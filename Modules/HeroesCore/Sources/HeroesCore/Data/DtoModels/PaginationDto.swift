//
//  PaginationDto.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 15/8/25.
//
import Foundation

public struct PaginationDto: Encodable {
    let limit: Int
    let offset: Int
}
