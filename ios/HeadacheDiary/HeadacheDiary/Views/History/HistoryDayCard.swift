//
//  HistoryDayCard.swift
//  HeadacheDiary
//
//  Web版 .history-day 相当（index.html:748-764）。
//

import SwiftUI

struct HistoryDayCard: View {
    let day: DiaryDay
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(DateKey.longLabel(day.dateKey))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(DesignConstants.text)
                    Spacer()
                    if let maxLevel = day.maxLevel, maxLevel.rawValue > 0 {
                        HStack(spacing: 4) {
                            Text("最大")
                                .font(.system(size: 12))
                            LevelBadge(level: maxLevel)
                        }
                    }
                }

                HeadacheTimelineChart(
                    entries: day.entries.map { TimelineEntryInput(time: $0.time, level: $0.level) },
                    meds: day.medications.map { TimelineMedInput(time: $0.time) },
                    compact: true
                )

                if !metaText.isEmpty {
                    Text(metaText)
                        .font(.system(size: 12))
                        .foregroundColor(DesignConstants.gray)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignConstants.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignConstants.cornerRadius))
            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var metaText: String {
        var parts: [String] = []
        if let impact = day.impact, let level = ImpactLevel(rawValue: impact) {
            parts.append("影響度: \(level.mark)")
        }
        let meds = day.medicationsByInsertionOrder
        if !meds.isEmpty {
            let medsTxt = meds.map { m -> String in
                let effect = MedEffect.from(m.effect)
                let countText = m.count.truncatingRemainder(dividingBy: 1) == 0
                    ? String(format: "%.0f", m.count) : String(format: "%.1f", m.count)
                return "\(m.name)\(countText)錠\(effect.shortLabel)"
            }.joined(separator: "、")
            parts.append("薬: \(medsTxt)")
        }
        if !day.memo.isEmpty {
            parts.append("メモ: \(day.memo)")
        }
        return parts.joined(separator: "　")
    }
}
