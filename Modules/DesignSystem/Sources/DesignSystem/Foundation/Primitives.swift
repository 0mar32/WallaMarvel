import Foundation
import UIKit
import SwiftUI

public enum Primitives {
    // MARK: - Spacing / Rhythm Units
    public enum Units {
        public static let u0: CGFloat = 0
        public static let u1: CGFloat = 1
        public static let u2: CGFloat = 2
        public static let u4: CGFloat = 4
        public static let u8: CGFloat = 8
        public static let u12: CGFloat = 12
        public static let u16: CGFloat = 16
        public static let u18: CGFloat = 18
        public static let u20: CGFloat = 20
        public static let u24: CGFloat = 24
        public static let u28: CGFloat = 28
        public static let u32: CGFloat = 32
        public static let u36: CGFloat = 36
        public static let u40: CGFloat = 40
        public static let u44: CGFloat = 44
        public static let u48: CGFloat = 48
        public static let u52: CGFloat = 52
        public static let u56: CGFloat = 56
        public static let u60: CGFloat = 60
        public static let u64: CGFloat = 64
        public static let u72: CGFloat = 72
        public static let u80: CGFloat = 80
        public static let u96: CGFloat = 96
        public static let u128: CGFloat = 128
        public static let u144: CGFloat = 144
        public static let u160: CGFloat = 160
        public static let u192: CGFloat = 192
        public static let u224: CGFloat = 224
        public static let u256: CGFloat = 256
        public static let u320: CGFloat = 320
        public static let u384: CGFloat = 384
        public static let u448: CGFloat = 448
        public static let u512: CGFloat = 512
    }

    // MARK: - Colors
    public enum Colors {
        public static let gray10 = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        public static let gray20 = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0)
        public static let gray30 = UIColor(red: 0.76, green: 0.76, blue: 0.76, alpha: 1.0)
        public static let gray50 = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        public static let gray70 = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        public static let gray90 = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        public static let red20 = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        public static let red50 = UIColor(red: 0.84, green: 0.0, blue: 0.0, alpha: 1.0)
        public static let blue20 = UIColor(red: 0.25, green: 0.45, blue: 0.95, alpha: 1.0)
        public static let blue50 = UIColor(red: 0.0, green: 0.18, blue: 0.8, alpha: 1.0)
        public static let yellow20 = UIColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0)
        public static let yellow50 = UIColor(red: 0.95, green: 0.75, blue: 0.0, alpha: 1.0)
        public static let orange20 = UIColor(red: 1.0, green: 0.55, blue: 0.2, alpha: 1.0)
        public static let green20 = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
        public static let purple20 = UIColor(red: 0.6, green: 0.2, blue: 0.85, alpha: 1.0)
        public static let black = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        public static let white = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
    }
}
