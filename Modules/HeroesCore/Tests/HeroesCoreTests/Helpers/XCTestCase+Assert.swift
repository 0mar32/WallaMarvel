//
//  Helpers.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//
import XCTest

extension XCTestCase {
    func XCTAssertThrowsErrorAsync<T>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "Expected expression to throw",
        file: StaticString = #filePath, line: UInt = #line,
        _ errorHandler: (Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail(message(), file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}
