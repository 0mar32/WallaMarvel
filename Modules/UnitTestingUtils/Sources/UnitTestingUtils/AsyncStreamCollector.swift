//
//  AsyncStreamCollector.swift
//  UnitTestingUtils
//
//  Created by Omar Tarek Mansour Omar on 19/8/25.
//
import Foundation
import Combine

public struct AsyncStreamCollector<Element: Sendable>: Sendable {
    private let stream: AsyncStream<Element>

    public init(_ stream: AsyncStream<Element>) {
        self.stream = stream
    }

    /// Returns the first element within `timeout` seconds, or nil if none arrives in time.
    public func first(timeout: TimeInterval) async -> Element? {
        let nanos = UInt64(max(0, timeout) * 1_000_000_000)

        return await withTaskGroup(of: Element?.self) { group in
            // Task 1: wait for the next element
            group.addTask {
                var it = stream.makeAsyncIterator()
                return await it.next()
            }

            // Task 2: timeout
            group.addTask {
                if nanos > 0 { try? await Task.sleep(nanoseconds: nanos) }
                return nil
            }

            // Whichever finishes first wins
            let result = await group.next()!
            group.cancelAll()
            return result
        }
    }
}
