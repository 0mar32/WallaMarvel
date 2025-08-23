import XCTest
import NetworkStubsUITestUtils
@testable import Heroes

final class HeroesList_Smoke_UITests: XCTestCase {

    private func launchApp(
        args: [String] = [],
        stubs: StubsConfiguration = StubsConfiguration()
    ) -> XCUIApplication {
        XCUIApplication()
            .launchForUITestsWithStubs(args: args, stubs: stubs)
    }

    func test_list_appears_with_first_hero() {
        let app = launchApp()
        let list = HeroesListScreen(app: app).waitLoaded()
        XCTAssertGreaterThanOrEqual(list.visibleCellCount(), 1, "Expected at least one hero row")
    }

    func test_pagination_reaches_end_matches_last_name_from_page1() throws {
        let app = launchApp()
        let heroesListScreen = HeroesListScreen(app: app).waitLoaded()

        let expectedLastName = try HeroesFixture.loadHeroFromFixture(
            page: .second,
            index: 19 // last hero in the file
        )

        heroesListScreen.scrollUntilTextVisible(text: expectedLastName, maxSwipes: 30)

        // 4) Assert it’s on screen
        XCTAssertTrue(
            app.text(.labelEquals(expectedLastName)).exists,
            "Expected the last avatar name of page 2 '\(expectedLastName)' to be visible at the end"
        )
    }

    func test_pagination_offline_shows_retry_row() {
        let app = launchApp(stubs: .init(heroesAPIServiceUseCase: .secondPageOffline))
        let list = HeroesListScreen(app: app).waitLoaded()

        list.scrollToBottom(times: 3)
        _ = list.waitForRetryRow()
        XCTAssertTrue(list.tapRetryRow())
    }

    func test_offline_first_page_shows_retry_column_immediately() {
        let app = launchApp(stubs: .init(heroesAPIServiceUseCase: .offline))
        let list = HeroesListScreen(app: app)

        _ = list.waitForRetryColumn()
        XCTAssertEqual(list.visibleCellCount(), 0, "Expected no hero rows when fully offline")

        XCTAssertTrue(list.tapRetryColumn(), "Retry button should be tappable")
        // Still offline → column should reappear (re-wait; don’t reuse the old element)
        _ = list.waitForRetryColumn(timeout: 4)
    }

    func test_tapping_first_hero_navigates_to_details() throws {
        let app = launchApp(stubs: .init(heroesAPIServiceUseCase: .twoPages))
        let list = HeroesListScreen(app: app).waitLoaded()

        // the first hero name from page 0, index 0
        let expectedName = try HeroesFixture.loadHeroFromFixture(page: .first, index: 0)

        list.tapFirstHeroCell()

        // assert details appeared and shows the correct title
        let detailScreen = HeroDetailScreen(app: app)
        detailScreen.waitLoaded(expectedName: expectedName)
    }

}

