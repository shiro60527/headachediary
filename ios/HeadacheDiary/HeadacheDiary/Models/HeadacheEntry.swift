//
//  HeadacheEntry.swift
//  HeadacheDiary
//
//  Web版 day.entries[] の要素 { time, level, note } に対応。
//

import Foundation
import SwiftData

extension HeadacheDiarySchemaV1 {
    @Model
    final class HeadacheEntry {
        var time: String
        var level: Int
        var note: String
        var createdAt: Date
        var day: DiaryDay?

        init(time: String, level: Int, note: String, createdAt: Date = .now) {
            self.time = time
            self.level = level
            self.note = note
            self.createdAt = createdAt
        }
    }
}

typealias HeadacheEntry = HeadacheDiarySchemaV1.HeadacheEntry
