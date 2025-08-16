//
//  TextStyle.swift
//  DesignSystem
//
//  Created by Omar Tarek Mansour Omar on 16/8/25.
//
import SwiftUI

public enum TextStyles {
    // MARK: - Headings
    public static let heading1 = Font.system(
        size: Primitives.Units.u32,
        weight: .bold
    )
    public static let heading2 = Font.system(
        size: Primitives.Units.u24,
        weight: .semibold
    )
    public static let heading3 = Font.system(
        size: Primitives.Units.u20,
        weight: .medium
    )

    public static let subHeading = Font.system(
        size: Primitives.Units.u18,
        weight: .medium
    )

    // MARK: - Body
    public static let body = Font.system(
        size: Primitives.Units.u16,
        weight: .regular
    )
    public static let bodyBold = Font.system(
        size: Primitives.Units.u16,
        weight: .semibold
    )
    public static let bodyItalic = Font.system(
        size: Primitives.Units.u16,
        weight: .regular
    ).italic()

    // MARK: - Caption / Small text
    public static let caption = Font.system(
        size: Primitives.Units.u12,
        weight: .regular
    )
    public static let captionBold = Font.system(
        size: Primitives.Units.u16,
        weight: .semibold
    )
}
