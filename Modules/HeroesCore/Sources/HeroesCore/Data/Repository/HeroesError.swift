//
//  HeroesError.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 24/8/25.
//
import NetworkClient

public enum HeroesError: Error {
    case offline
    case generic
}

extension HeroesError {
    static func map(_ error: Error) -> HeroesError {
        if let error = error as? HeroesError { return error }

        if let networkError = error as? NetworkError {
            switch networkError {
            case .noInternet, .timeout:
                return .offline
            default:
                return .generic
            }
        } else {
            return .generic
        }
    }
}
