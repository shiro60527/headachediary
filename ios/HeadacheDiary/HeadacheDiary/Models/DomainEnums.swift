//
//  DomainEnums.swift
//  HeadacheDiary
//
//  SwiftDataの永続プロパティは生のInt/Stringで保持し、
//  表示用のenumはこのファイルでビュー層専用ヘルパーとして分離する。
//

import SwiftUI

/// 頭痛の程度（HeadacheEntry.level）
enum HeadacheLevel: Int, CaseIterable, Identifiable {
    case resolved = 0
    case mild = 1
    case moderate = 2
    case severe = 3

    var id: Int { rawValue }

    init(rawValueClamped raw: Int) {
        self = HeadacheLevel(rawValue: raw) ?? .resolved
    }

    var mark: String {
        switch self {
        case .resolved: return "✓"
        case .mild: return "十"
        case .moderate: return "廾"
        case .severe: return "卅"
        }
    }

    var label: String {
        switch self {
        case .resolved: return "治まった"
        case .mild: return "軽度"
        case .moderate: return "中程度"
        case .severe: return "重度"
        }
    }

    var color: Color {
        switch self {
        case .resolved: return DesignConstants.green
        case .mild: return DesignConstants.amber
        case .moderate: return DesignConstants.orange
        case .severe: return DesignConstants.red
        }
    }
}

/// 日常生活への影響度（DiaryDay.impact）
enum ImpactLevel: Int, CaseIterable, Identifiable {
    case none = 0
    case mild = 1
    case moderate = 2
    case severe = 3

    var id: Int { rawValue }

    var mark: String {
        switch self {
        case .none: return "−"
        case .mild: return "十"
        case .moderate: return "廾"
        case .severe: return "卅"
        }
    }

    var description: String {
        switch self {
        case .none: return "影響なし"
        case .mild: return "頭痛はあるが、日常生活に大きな支障はない"
        case .moderate: return "仕事・学校・家事の能率が通常の半分以下である"
        case .severe: return "何も手につかず、横にならなければならない"
        }
    }

    /// Web版 renderPrintSheet の LEVEL_COLORS 流用（impact===0 が falsy でグレー扱いになる
    /// Web版の実挙動を再現するため、印刷シートではこの color を使わず nil として扱う）
    var color: Color {
        switch self {
        case .none: return DesignConstants.green
        case .mild: return DesignConstants.amber
        case .moderate: return DesignConstants.orange
        case .severe: return DesignConstants.red
        }
    }
}

/// 服薬の効き目（Medication.effect）
enum MedEffect: String, CaseIterable, Identifiable {
    case good
    case partial
    case none
    case unknown

    var id: String { rawValue }

    static func from(_ raw: String) -> MedEffect {
        MedEffect(rawValue: raw) ?? .unknown
    }

    var label: String {
        switch self {
        case .good: return "○ 効いた"
        case .partial: return "△ やや効いた"
        case .none: return "× 効かなかった"
        case .unknown: return "− 未記入"
        }
    }

    /// 一覧・印刷シートでのバッジ表示（未記入は空文字、Web版 EFFECT_LABEL 相当）
    var shortLabel: String {
        switch self {
        case .good: return "○"
        case .partial: return "△"
        case .none: return "×"
        case .unknown: return ""
        }
    }
}
