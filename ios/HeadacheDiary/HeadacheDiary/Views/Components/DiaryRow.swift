//
//  DiaryRow.swift
//  HeadacheDiary
//
//  頭痛記録・服薬記録の一覧行（Web版 .entry-list li 相当）。
//

import SwiftUI

struct DiaryRow<Trailing: View>: View {
    let time: String
    @ViewBuilder let content: () -> Trailing
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(time)
                .font(.system(size: 14, weight: .bold))
                .monospacedDigit()
            content()
            Spacer(minLength: 0)
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: 0xb91c1c))
                    .padding(6)
            }
            .accessibilityLabel("削除")
        }
        .padding(.vertical, 8)
    }
}
