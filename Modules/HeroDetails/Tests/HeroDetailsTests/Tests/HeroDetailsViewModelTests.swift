//
//  HeroDetailsUIModelMapperMock.swift
//  HeroDetails
//
//  Created by Omar Tarek Mansour Omar on 20/8/25.
//
import XCTest
import HeroesCore

@testable import HeroesCoreTestingMocks
@testable import HeroDetails

@MainActor
final class HeroDetailsViewModelTests: XCTestCase {
    func test_initialState_isIdle() {
        let mapper = HeroDetailsUIModelMapperMock()
        let vm = HeroDetailsViewModel(
            hero: .sample(id: 42, name: "Spidey"),
            HeroDetailsUIModelMapper: mapper
        )

        if case .idle = vm.state {
            // ok
        } else {
            XCTFail("Expected .idle")
        }
        XCTAssertEqual(vm.state.heroName, "")
    }

    func test_refreshHeroDetails_setsLoaded_withMappedModel() {
        // given
        let hero = Hero.sample(id: 7, name: "Wolverine")
        let mapper = HeroDetailsUIModelMapperMock()
        mapper.stubbed =
            .sample(title: "Wolverine", description: "Logan")

        let vm = HeroDetailsViewModel(hero: hero, HeroDetailsUIModelMapper: mapper)

        // when
        vm.refreshHeroDetails()

        // then
        XCTAssertEqual(mapper.receivedHeroes.map(\.id), [7], "Mapper should be invoked once with the provided hero")

        guard case let .loaded(model) = vm.state else {
            return XCTFail("Expected .loaded")
        }
        XCTAssertEqual(model.title, "Wolverine")
        XCTAssertEqual(model.description, "Logan")
        XCTAssertEqual(vm.state.heroName, "Wolverine")
    }
}
