//
//  DiaryImportExportService.swift
//  HeadacheDiary
//
//  Web版の「書き出し」「読み込み」（index.html:859-887）に対応。
//

import Foundation
import SwiftData

enum DiaryImportExportError: Error, LocalizedError {
    case invalidFormat

    var errorDescription: String? {
        switch self {
        case .invalidFormat: return "形式が違います"
        }
    }
}

enum DiaryImportExportService {
    static func export(context: ModelContext) throws -> DiaryStoreDTO {
        let descriptor = FetchDescriptor<DiaryDay>()
        let days = try context.fetch(descriptor)
        var dict: [String: DiaryDayDTO] = [:]
        for day in days {
            let entries = day.sortedEntries.map {
                HeadacheEntryDTO(time: $0.time, level: $0.level, note: $0.note)
            }
            let meds = day.medicationsByInsertionOrder.map {
                MedicationDTO(time: $0.time, name: $0.name, count: $0.count, effect: $0.effect)
            }
            dict[day.dateKey] = DiaryDayDTO(entries: entries, meds: meds, impact: day.impact, memo: day.memo)
        }
        return DiaryStoreDTO(version: 1, days: dict)
    }

    static func exportData(context: ModelContext) throws -> Data {
        let dto = try export(context: context)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(dto)
    }

    static func decodeData(_ data: Data) throws -> DiaryStoreDTO {
        try JSONDecoder().decode(DiaryStoreDTO.self, from: data)
    }

    /// Web版 Object.assign(store.days, data.days) と同じ「日単位で丸ごと上書き」を再現する。
    /// ユニーク制約によるupsertには頼らず、既存日を明示的に削除してから新規insertする。
    static func importMerge(_ dto: DiaryStoreDTO, into context: ModelContext) throws {
        for (dateKey, dayDTO) in dto.days {
            let descriptor = FetchDescriptor<DiaryDay>(predicate: #Predicate<DiaryDay> { $0.dateKey == dateKey })
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
            }

            let newDay = DiaryDay(dateKey: dateKey, impact: dayDTO.impact, memo: dayDTO.memo)
            context.insert(newDay)

            for e in dayDTO.entries {
                let entry = HeadacheEntry(time: e.time, level: e.level, note: e.note)
                entry.day = newDay
                context.insert(entry)
            }
            for m in dayDTO.meds {
                let med = Medication(time: m.time, name: m.name, count: m.count, effect: m.effect)
                med.day = newDay
                context.insert(med)
            }
        }
        try context.save()
    }
}
