//
//  fixtureUrl.swift
//  NetworkStubsUITestUtils
//
//  Created by Omar Tarek Mansour Omar on 23/8/25.
//

#if DEBUG
import Foundation

public func fixtureUrl(for name: String) -> URL {
    guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
        fatalError("❌ [Stubs] Missing fixture \(name).json in \(Bundle.module.resourceURL?.path ?? "<nil>")")
    }

    return url
}
#endif
