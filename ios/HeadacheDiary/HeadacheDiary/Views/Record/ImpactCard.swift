//
//  ImpactCard.swift
//  HeadacheDiary
//
//  Web版「日常生活への影響度」カード（index.html:353-361, 718-727）。
//

import SwiftUI

struct ImpactCard: View {
    let dateKey: String
    let day: DiaryDay?
    @Environment(\.modelContext) private var context

    private var selectedBinding: Binding<ImpactLevel?> {
        Binding(
            get: { day?.impact.map { ImpactLevel(rawValue: $0) ?? .none } },
            set: { newValue in
                let target = day ?? {
                    let newDay = DiaryDay(dateKey: dateKey)
                    context.insert(newDay)
                    return newDay
                }()
                target.impact = newValue?.rawValue
                DayMaintenance.pruneIfEmpty(target, context: context)
            }
        )
    }

    var body: some View {
        SectionCard(title: "日常生活への影響度") {
            ImpactSelectorGrid(selected: selectedBinding)
        }
    }
}
