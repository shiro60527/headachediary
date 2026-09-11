//
//  LevelBadge.swift
//  HeadacheDiary
//
//  記録一覧・履歴カードで使う程度バッジ（Web版 .badge 相当）。
//

import SwiftUI

struct LevelBadge: View {
    let level: HeadacheLevel

    var body: some View {
        Text("\(level.mark) \(level.label)")
            .font(.system(size: 12, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(level.color.opacity(0.12))
            .foregroundColor(level.color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
