//
//  HeadacheEntryCard.swift
//  HeadacheDiary
//
//  Web版「頭痛の記録」カード（index.html:298-321, 662-671）。
//

import SwiftUI
import SwiftData

struct HeadacheEntryCard: View {
    let dateKey: String
    let day: DiaryDay?
    @Environment(\.modelContext) private var context

    @State private var time = Date()
    @State private var note = ""
    @State private var selectedLevel: HeadacheLevel? = nil
    @State private var showValidationAlert = false

    var body: some View {
        SectionCard(title: "頭痛の記録", hint: "時刻と程度を選んで記録") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        fieldLabel("時刻")
                        DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        fieldLabel("メモ(任意)")
                        TextField("ズキズキする、吐き気 など", text: $note)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                fieldLabel("頭痛の程度")
                LevelSelectorGrid(selected: $selectedLevel)

                Button(action: addEntry) {
                    Text("＋ この時刻で記録する")
                        .font(.system(size: 15, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .background(DesignConstants.teal)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                if let entries = day?.sortedEntries, !entries.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(entries.enumerated()), id: \.element.persistentModelID) { index, entry in
                            DiaryRow(time: entry.time) {
                                let level = HeadacheLevel(rawValueClamped: entry.level)
                                HStack(spacing: 10) {
                                    LevelBadge(level: level)
                                    if !entry.note.isEmpty {
                                        Text(entry.note)
                                            .font(.system(size: 14))
                                            .foregroundColor(DesignConstants.gray)
                                            .lineLimit(1)
                                    }
                                }
                            } onDelete: {
                                delete(entry)
                            }
                            if index < entries.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .alert("頭痛の程度を選んでください", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(DesignConstants.gray)
    }

    private func addEntry() {
        guard let level = selectedLevel else {
            showValidationAlert = true
            return
        }
        let target = day ?? {
            let newDay = DiaryDay(dateKey: dateKey)
            context.insert(newDay)
            return newDay
        }()

        let entry = HeadacheEntry(
            time: DateKey.timeString(from: time),
            level: level.rawValue,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        entry.day = target
        context.insert(entry)

        // Web版はメモ・時刻のみクリアし、レベル選択はリセットしない
        note = ""
    }

    private func delete(_ entry: HeadacheEntry) {
        guard let target = day else { return }
        context.delete(entry)
        DayMaintenance.pruneIfEmpty(target, context: context)
    }
}
