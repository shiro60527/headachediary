//
//  SectionCard.swift
//  HeadacheDiary
//
//  Web版 .card 相当の共通コンテナ。
//

import SwiftUI

struct SectionCard<Content: View>: View {
    let title: String
    var hint: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(DesignConstants.tealDark)
                if let hint {
                    Text(hint)
                        .font(.system(size: 11))
                        .foregroundColor(DesignConstants.gray)
                }
            }
            content
        }
        .padding(14)
        .background(DesignConstants.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignConstants.cornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
    }
}
