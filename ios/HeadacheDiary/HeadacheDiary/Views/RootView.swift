//
//  RootView.swift
//  HeadacheDiary
//

import SwiftUI
import SwiftData

struct RootView: View {
    @State private var appState = AppState()

    var body: some View {
        TabView(selection: Binding(
            get: { appState.selectedTab },
            set: { appState.selectedTab = $0 }
        )) {
            RecordView()
                .tabItem { Label("記録", systemImage: "pencil.line") }
                .tag(AppState.Tab.record)

            HistoryView()
                .tabItem { Label("履歴", systemImage: "calendar") }
                .tag(AppState.Tab.history)

            PrintView()
                .tabItem { Label("印刷", systemImage: "printer") }
                .tag(AppState.Tab.print)

            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
                .tag(AppState.Tab.settings)
        }
        .tint(DesignConstants.teal)
        .environment(appState)
        .environment(\.locale, Locale(identifier: "ja_JP"))
    }
}

#Preview {
    RootView()
        .modelContainer(for: DiaryDay.self, inMemory: true)
}
