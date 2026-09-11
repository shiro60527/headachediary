//
//  DateNavBar.swift
//  HeadacheDiary
//
//  記録タブのヘッダー（Web版 header.appbar 内の datenav 相当）。
//

import SwiftUI

struct DateNavBar: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: 8) {
            Button {
                appState.currentDateKey = DateKey.addDays(appState.currentDateKey, -1)
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .accessibilityLabel("前の日")

            DatePicker(
                "",
                selection: Binding(
                    get: { DateKey.date(from: appState.currentDateKey) ?? Date() },
                    set: { appState.currentDateKey = DateKey.key(for: $0) }
                ),
                displayedComponents: .date
            )
            .labelsHidden()
            .tint(.white)

            Button {
                appState.currentDateKey = DateKey.addDays(appState.currentDateKey, 1)
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .accessibilityLabel("次の日")
        }
        .foregroundColor(.white)
    }
}
