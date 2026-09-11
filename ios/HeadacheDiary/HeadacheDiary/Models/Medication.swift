//
//  Medication.swift
//  HeadacheDiary
//
//  Web版 day.meds[] の要素 { time, name, count, effect } に対応。
//  time は未入力（空文字列）を許容する。
//

import Foundation
import SwiftData

extension HeadacheDiarySchemaV1 {
    @Model
    final class Medication {
        var time: String
        var name: String
        var count: Double
        var effect: String
        var createdAt: Date
        var day: DiaryDay?

        init(time: String, name: String, count: Double, effect: String, createdAt: Date = .now) {
            self.time = time
            self.name = name
            self.count = count
            self.effect = effect
            self.createdAt = createdAt
        }
    }
}

typealias Medication = HeadacheDiarySchemaV1.Medication
