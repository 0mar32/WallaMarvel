//
//  StubsConfiguration.swift
//  NetworkStubsUITestUtils
//
//  Created by Omar Tarek Mansour Omar on 23/8/25.
//

#if DEBUG
/// This is a configuration object that hold each service stub use case
/// An instance of this object is passed from the UITest process to the app process as Environment Argument to tell the app how to stub the APIs.
/// It is mandatory that the app process be the one who use ``OHHTTPStubs`` to stub the end points
/// UITest Target are incapable to use ``OHHTTPStubs``
///
/// If you need to stub an other service,
/// -  Added a priority for it here in ``StubsConfiguration``
/// - Create a stub factory that implement the protocol ``APIServiceStub`` (see example ``HeroesAPIServiceStubFactory``)
/// - Update ``NetworkStubs/install`` to consider reading configure for the new stub
public struct StubsConfiguration: Codable {
    public var heroesAPIServiceUseCase: HeroesAPIServiceStubFactory.UseCase

    public init(
        heroesAPIServiceUseCase: HeroesAPIServiceStubFactory.UseCase = .twoPages
    ) {
        self.heroesAPIServiceUseCase = heroesAPIServiceUseCase
    }
}
#endif
