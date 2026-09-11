//
//  HistoryView.swift
//  HeadacheDiary
//
//  Web版「履歴」タブ（index.html:370-373, 742-773）。
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: [SortDescriptor(\DiaryDay.dateKey, order: .reverse)]) private var days: [DiaryDay]

    var body: some View {
        NavigationStack {
            ScrollView {
                if days.isEmpty {
                    Text("まだ記録がありません。\n「記録」タブから頭痛を記録してみましょう。")
                        .font(.system(size: 14))
                        .foregroundColor(DesignConstants.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 48)
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(days) { day in
                            HistoryDayCard(day: day) {
                                appState.goToRecord(dateKey: day.dateKey)
                            }
                        }
                    }
                    .padding(12)
                }
            }
            .background(DesignConstants.background)
            .navigationTitle("履歴")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
