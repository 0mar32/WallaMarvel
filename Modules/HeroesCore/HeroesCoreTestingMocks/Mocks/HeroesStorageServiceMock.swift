//
//  HeroesStorageServiceMock.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//
@testable import HeroesCore

final class HeroesStorageServiceMock: HeroesStorageServiceProtocol {
    var stubbedAllHeroes: [Hero] = []

    private(set) var recordedStores: [(heroes: [Hero], offset: Int)] = []

    func fetchAllHeroes() throws -> [Hero] {
        stubbedAllHeroes
    }

    func storeHeroes(_ heroes: [Hero], offset: Int) throws {
        recordedStores.append((heroes, offset))
        // Optional: simulate persistent replacement at positions offset..<(offset+heroes.count)
        // Not required for assertions in these tests.
    }

    func flushHeroes() throws {
        stubbedAllHeroes = []
        recordedStores.removeAll()
    }
}
