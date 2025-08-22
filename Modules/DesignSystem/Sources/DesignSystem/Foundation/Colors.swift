//
//  Foundation.swift
//  DesignSystem
//
//  Created by Omar Tarek Mansour Omar on 16/8/25.
//

import Foundation
import UIKit

public enum Colors {

    // MARK: - Semantic Colors
    public enum Primary {
        public static let red = Primitives.Colors.red50
        public static let blue = Primitives.Colors.blue50
        public static let lightBlue = Primitives.Colors.blue20
        public static let yellow = Primitives.Colors.yellow50
    }

    public enum Secondary {
        public static let orange = Primitives.Colors.red20
        public static let green = Primitives.Colors.blue20
        public static let purple = Primitives.Colors.gray50
    }

    public enum General {
        public static let white = Primitives.Colors.white
        public static let black = Primitives.Colors.gray90
    }

    // MARK: - Backgrounds
    public enum Background {
        public static let main = Primitives.Colors.gray10
        public static let card = Primitives.Colors.gray20
        public static let modal = Primitives.Colors.white
        public static let section = Primitives.Colors.gray10
    }

    // MARK: - Foreground
    public enum Foreground {
        public static let primary = Primitives.Colors.gray90
        public static let secondary = Primitives.Colors.gray50
        public static let placeholder = Primitives.Colors.gray30
        public static let inverse = Primitives.Colors.white
    }

    // MARK: - Text Colors
    public enum Text {
        public static let primary = Primitives.Colors.gray90
        public static let secondary = Primitives.Colors.gray50
        public static let placeholder = Primitives.Colors.gray30
        public static let inverse = Primitives.Colors.white
    }

    // MARK: - Alerts / Status
    public enum Status {
        public static let success = Secondary.green
        public static let warning = Primary.yellow
        public static let error = Primary.red
    }
}
