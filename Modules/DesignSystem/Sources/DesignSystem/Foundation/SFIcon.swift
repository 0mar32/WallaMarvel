//
//  SFIcon.swift
//  DesignSystem
//
//  Created by Omar Tarek Mansour Omar on 17/8/25.
//
import Foundation

public enum SFIcon: String {
    case series = "rectangle.stack.fill"
    case stories = "book.fill"
    case general = "circle.grid.2x2.fill"

    public var systemName: String { rawValue }
}

