//
//  RecordView.swift
//  HeadacheDiary
//
//  Web版「記録」タブ（index.html:290-368, view-record）。
//

import SwiftUI
import SwiftData

struct RecordView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                DayDetailView(dateKey: appState.currentDateKey)
                    .id(appState.currentDateKey)
                    .padding(12)
            }
            .background(DesignConstants.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DesignConstants.teal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    DateNavBar()
                }
            }
        }
    }
}

/// dateKey ごとに @Query を再構築するため、親側で .id(dateKey) を付与して使うこと。
struct DayDetailView: View {
    let dateKey: String
    @Query private var days: [DiaryDay]

    init(dateKey: String) {
        self.dateKey = dateKey
        _days = Query(filter: #Predicate<DiaryDay> { $0.dateKey == dateKey })
    }

    private var day: DiaryDay? { days.first }

    var body: some View {
        VStack(spacing: 12) {
            SectionCard(title: "今日のタイムライン", hint: "記録すると自動で線が引かれます") {
                HeadacheTimelineChart(
                    entries: (day?.entries ?? []).map { TimelineEntryInput(time: $0.time, level: $0.level) },
                    meds: (day?.medications ?? []).map { TimelineMedInput(time: $0.time) },
                    compact: false
                )
            }

            HeadacheEntryCard(dateKey: dateKey, day: day)
            MedicationCard(dateKey: dateKey, day: day)
            ImpactCard(dateKey: dateKey, day: day)
            MemoCard(dateKey: dateKey, day: day)
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: DiaryDay.self, inMemory: true)
}
