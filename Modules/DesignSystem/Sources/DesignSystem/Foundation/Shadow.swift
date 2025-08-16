//
//  Shadow.swift
//  DesignSystem
//
//  Created by Omar Tarek Mansour Omar on 17/8/25.
//
import Foundation

public enum Shadow {
    case light

    var offsetX: CGFloat {
        switch self {
        case .light:
            return Primitives.Units.u0
        }
    }

    var offsetY: CGFloat {
        switch self {
        case .light:
            return Primitives.Units.u2
        }
    }

    var radius: CGFloat {
        switch self {
        case .light:
            return Primitives.Units.u4
        }
    }
}

