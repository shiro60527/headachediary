//
//  MemoCard.swift
//  HeadacheDiary
//
//  Web版「原因・きっかけメモ」カード（index.html:363-366, 730-739）。
//  入力後400msデバウンスで自動保存する。
//

import SwiftUI
import SwiftData

struct MemoCard: View {
    let dateKey: String
    let day: DiaryDay?
    @Environment(\.modelContext) private var context

    @State private var text = ""
    @State private var saveTask: Task<Void, Never>?

    var body: some View {
        SectionCard(title: "原因・きっかけメモ", hint: "わかれば記入(自動保存)") {
            TextEditor(text: $text)
                .frame(minHeight: 72)
                .font(.system(size: 16))
                .padding(4)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(DesignConstants.border, lineWidth: 1.5))
                .onChange(of: text) { _, newValue in
                    scheduleSave(newValue)
                }
        }
        .onAppear {
            text = day?.memo ?? ""
        }
    }

    private func scheduleSave(_ value: String) {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            save(value)
        }
    }

    @MainActor
    private func save(_ value: String) {
        let target = day ?? {
            let newDay = DiaryDay(dateKey: dateKey)
            context.insert(newDay)
            return newDay
        }()
        target.memo = value
        DayMaintenance.pruneIfEmpty(target, context: context)
    }
}
