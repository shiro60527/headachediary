//
//  ImpactSelectorButton.swift
//  HeadacheDiary
//
//  日常生活への影響度4段階のトグル選択（Web版 .impact-btn 相当）。
//  同じものの再タップで選択解除する。
//

import SwiftUI

struct ImpactSelectorGrid: View {
    @Binding var selected: ImpactLevel?

    private let order: [ImpactLevel] = [.severe, .moderate, .mild, .none]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(order) { level in
                let isSelected = selected == level
                Button {
                    selected = isSelected ? nil : level
                } label: {
                    HStack(spacing: 10) {
                        Text(level.mark)
                            .font(.system(size: 18, weight: .bold))
                            .frame(minWidth: 32)
                            .foregroundColor(level.color)
                        Text(level.description)
                            .font(.system(size: 13))
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .padding(10)
                }
                .foregroundColor(isSelected ? DesignConstants.tealDark : DesignConstants.gray)
                .background(isSelected ? DesignConstants.tealLight : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? DesignConstants.teal : DesignConstants.border, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
