//
//  DiaryExportDTO.swift
//  HeadacheDiary
//
//  Web版 localStorage の JSON ({version, days:{...}}) と完全同一スキーマの
//  Codable DTO。Web版のゆるい欠損値補完 (|| "", || [], || 1 等) に合わせ、
//  寛容なデコード（欠損キーでエラーにしない）をカスタム init(from:) で行う。
//

import Foundation

struct DiaryStoreDTO: Codable {
    var version: Int
    var days: [String: DiaryDayDTO]

    enum CodingKeys: String, CodingKey { case version, days }

    init(version: Int = 1, days: [String: DiaryDayDTO] = [:]) {
        self.version = version
        self.days = days
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = (try? container.decode(Int.self, forKey: .version)) ?? 1
        self.days = (try? container.decode([String: DiaryDayDTO].self, forKey: .days)) ?? [:]
    }
}

struct DiaryDayDTO: Codable {
    var entries: [HeadacheEntryDTO]
    var meds: [MedicationDTO]
    var impact: Int?
    var memo: String

    enum CodingKeys: String, CodingKey { case entries, meds, impact, memo }

    init(entries: [HeadacheEntryDTO] = [], meds: [MedicationDTO] = [], impact: Int? = nil, memo: String = "") {
        self.entries = entries
        self.meds = meds
        self.impact = impact
        self.memo = memo
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.entries = (try? container.decode([HeadacheEntryDTO].self, forKey: .entries)) ?? []
        self.meds = (try? container.decode([MedicationDTO].self, forKey: .meds)) ?? []
        self.impact = (try? container.decodeIfPresent(Int.self, forKey: .impact)) ?? nil
        self.memo = (try? container.decode(String.self, forKey: .memo)) ?? ""
    }
}

struct HeadacheEntryDTO: Codable {
    var time: String
    var level: Int
    var note: String

    enum CodingKeys: String, CodingKey { case time, level, note }

    init(time: String, level: Int, note: String) {
        self.time = time
        self.level = level
        self.note = note
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.time = (try? container.decode(String.self, forKey: .time)) ?? ""
        self.level = (try? container.decode(Int.self, forKey: .level)) ?? 0
        self.note = (try? container.decode(String.self, forKey: .note)) ?? ""
    }
}

struct MedicationDTO: Codable {
    var time: String
    var name: String
    var count: Double
    var effect: String

    enum CodingKeys: String, CodingKey { case time, name, count, effect }

    init(time: String, name: String, count: Double, effect: String) {
        self.time = time
        self.name = name
        self.count = count
        self.effect = effect
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.time = (try? container.decode(String.self, forKey: .time)) ?? ""
        self.name = (try? container.decode(String.self, forKey: .name)) ?? ""
        // Web版の parseFloat(...) || 1 は 0 も falsy として 1 に丸める挙動を再現
        let decodedCount = (try? container.decode(Double.self, forKey: .count)) ?? 0
        self.count = decodedCount > 0 ? decodedCount : 1
        let decodedEffect = (try? container.decode(String.self, forKey: .effect)) ?? "unknown"
        self.effect = MedEffect.from(decodedEffect).rawValue
    }
}
