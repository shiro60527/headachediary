//
//  DesignConstants.swift
//  HeadacheDiary
//
//  Web版 index.html の CSS変数 (:root) と同値のデザイントークン。
//

import SwiftUI

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

enum DesignConstants {
    static let teal = Color(hex: 0x0e7490)
    static let tealDark = Color(hex: 0x155e75)
    static let tealLight = Color(hex: 0xecfeff)
    static let red = Color(hex: 0xdc2626)
    static let orange = Color(hex: 0xea580c)
    static let amber = Color(hex: 0xd97706)
    static let green = Color(hex: 0x16a34a)
    static let gray = Color(hex: 0x6b7280)
    static let background = Color(hex: 0xf3f6f8)
    static let cardBackground = Color.white
    static let border = Color(hex: 0xd9e2e8)
    static let text = Color(hex: 0x1f2937)
    static let cornerRadius: CGFloat = 12

    /// Web版 DOW 配列（0=日曜）
    static let dow = ["日", "月", "火", "水", "木", "金", "土"]
}
