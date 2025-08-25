//
//  CollectFromAsyncStream.swift
//  UnitTestingUtils
//
//  Created by Omar Tarek Mansour Omar on 24/8/25.
//

public struct StreamOutcome<T>: @unchecked Sendable {
    public let items: [T]
    public let error: Error?
}

public func collectFromAsyncStream<T>(_ stream: AsyncThrowingStream<T, Error>) async -> StreamOutcome<T> {
    var items: [T] = []
    do {
        for try await item in stream { items.append(item) }
        return .init(items: items, error: nil)
    } catch {
        return .init(items: items, error: error)
    }
}
