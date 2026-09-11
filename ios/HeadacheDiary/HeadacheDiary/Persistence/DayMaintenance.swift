//
//  DayMaintenance.swift
//  HeadacheDiary
//
//  Web版 cleanupDay() 相当。空になった日を自動削除する。
//  エントリ削除後・薬削除後・影響度トグルオフ後・メモ自動保存後に必ず呼ぶこと。
//

import SwiftData

enum DayMaintenance {
    static func pruneIfEmpty(_ day: DiaryDay, context: ModelContext) {
        if day.isEmpty {
            context.delete(day)
        }
    }
}
