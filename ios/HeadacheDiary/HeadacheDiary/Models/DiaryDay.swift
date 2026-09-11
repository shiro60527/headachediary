//
//  DiaryDay.swift
//  HeadacheDiary
//
//  Web版 localStorage の store.days["YYYY-MM-DD"] に対応するルートモデル。
//

import Foundation
import SwiftData

extension HeadacheDiarySchemaV1 {
    @Model
    final class DiaryDay {
        @Attribute(.unique) var dateKey: String
        var impact: Int?
        var memo: String

        @Relationship(deleteRule: .cascade, inverse: \HeadacheEntry.day)
        var entries: [HeadacheEntry] = []

        @Relationship(deleteRule: .cascade, inverse: \Medication.day)
        var medications: [Medication] = []

        init(dateKey: String, impact: Int? = nil, memo: String = "") {
            self.dateKey = dateKey
            self.impact = impact
            self.memo = memo
        }

        /// Web版 cleanupDay の削除条件と同一。
        var isEmpty: Bool {
            entries.isEmpty && medications.isEmpty && impact == nil && memo.isEmpty
        }

        var sortedEntries: [HeadacheEntry] {
            entries.sorted { DateKey.timeToMinutes($0.time) < DateKey.timeToMinutes($1.time) }
        }

        var sortedMedications: [Medication] {
            medications.sorted { DateKey.timeToMinutes($0.time.isEmpty ? "00:00" : $0.time) < DateKey.timeToMinutes($1.time.isEmpty ? "00:00" : $1.time) }
        }

        /// 履歴カード・印刷シートの服薬サマリー（挿入順＝createdAt昇順）
        var medicationsByInsertionOrder: [Medication] {
            medications.sorted { $0.createdAt < $1.createdAt }
        }

        var maxLevel: HeadacheLevel? {
            entries.map { HeadacheLevel(rawValueClamped: $0.level) }.max { $0.rawValue < $1.rawValue }
        }
    }
}

typealias DiaryDay = HeadacheDiarySchemaV1.DiaryDay
