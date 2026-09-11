//
//  LevelSelectorButton.swift
//  HeadacheDiary
//
//  頭痛の程度4段階のトグル選択グリッド（Web版 .level-btn 相当）。
//  同じものの再タップで選択解除する。
//

import SwiftUI

struct LevelSelectorGrid: View {
    @Binding var selected: HeadacheLevel?

    private let order: [HeadacheLevel] = [.severe, .moderate, .mild, .resolved]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            ForEach(order) { level in
                let isSelected = selected == level
                Button {
                    selected = isSelected ? nil : level
                } label: {
                    VStack(spacing: 4) {
                        Text(level.mark).font(.system(size: 18))
                        Text(level.label).font(.system(size: 13, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .foregroundColor(isSelected ? level.color : DesignConstants.gray)
                .background(isSelected ? level.color.opacity(0.08) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? level.color : DesignConstants.border, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
