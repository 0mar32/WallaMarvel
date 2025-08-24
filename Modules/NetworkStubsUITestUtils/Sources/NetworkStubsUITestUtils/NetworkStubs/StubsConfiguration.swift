//
//  StubsConfiguration.swift
//  NetworkStubsUITestUtils
//
//  Created by Omar Tarek Mansour Omar on 23/8/25.
//

#if DEBUG
public struct StubsConfiguration: Codable {
    public var heroesAPIServiceUseCase: HeroesAPIServiceStubFactory.UseCase

    public init(
        heroesAPIServiceUseCase: HeroesAPIServiceStubFactory.UseCase = .twoPages
    ) {
        self.heroesAPIServiceUseCase = heroesAPIServiceUseCase
    }
}
#endif
