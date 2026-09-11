//
//  DateKey.swift
//  HeadacheDiary
//
//  "yyyy-MM-dd" 形式の日付キー生成・解析ユーティリティ。
//  Web版 index.html の todayStr/fmtDate/fmtDateLong/addDays に対応。
//
//  和暦カレンダー設定端末での破損を防ぐため、ロケールは常に en_US_POSIX、
//  カレンダーは常にグレゴリオ暦に固定する。
//

import Foundation

enum DateKey {
    static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static var gregorianCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        return cal
    }

    static func key(for date: Date) -> String {
        formatter.string(from: date)
    }

    static func date(from key: String) -> Date? {
        formatter.date(from: key)
    }

    static func today() -> String {
        key(for: Date())
    }

    static func addDays(_ key: String, _ n: Int) -> String {
        guard let d = date(from: key),
              let newDate = gregorianCalendar.date(byAdding: .day, value: n, to: d) else {
            return key
        }
        return DateKey.key(for: newDate)
    }

    /// 0=日曜 ... 6=土曜（Web版 DOW 配列の添字と対応）
    private static func weekdayIndex(_ key: String) -> Int {
        guard let d = date(from: key) else { return 0 }
        return gregorianCalendar.component(.weekday, from: d) - 1
    }

    /// "9/11(木)" 形式（fmtDate相当）
    static func shortLabel(_ key: String) -> String {
        let parts = key.split(separator: "-")
        guard parts.count == 3, let m = Int(parts[1]), let d = Int(parts[2]) else { return key }
        let dow = DesignConstants.dow[weekdayIndex(key)]
        return "\(m)/\(d)(\(dow))"
    }

    /// "2026年9月11日(木)" 形式（fmtDateLong相当）
    static func longLabel(_ key: String) -> String {
        let parts = key.split(separator: "-")
        guard parts.count == 3, let y = Int(parts[0]), let m = Int(parts[1]), let d = Int(parts[2]) else { return key }
        let dow = DesignConstants.dow[weekdayIndex(key)]
        return "\(y)年\(m)月\(d)日(\(dow))"
    }

    /// "09/11" 形式（印刷シートの日付列。ゼロパディングあり）
    static func paddedMonthDay(_ key: String) -> String {
        let parts = key.split(separator: "-")
        guard parts.count == 3 else { return key }
        return "\(parts[1])/\(parts[2])"
    }

    static func timeToMinutes(_ time: String) -> Int {
        let parts = time.split(separator: ":")
        guard parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) else { return 0 }
        return h * 60 + m
    }

    static func nowTimeString() -> String {
        timeString(from: Date())
    }

    /// "HH:mm" 形式（時刻入力欄の値をそのまま保存するために使う）
    static func timeString(from date: Date) -> String {
        let comps = gregorianCalendar.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", comps.hour ?? 0, comps.minute ?? 0)
    }

    static func firstDayOfMonth(containing key: String) -> String {
        let parts = key.split(separator: "-")
        guard parts.count == 3 else { return key }
        return "\(parts[0])-\(parts[1])-01"
    }

    static func lastDayOfMonth(containing key: String) -> String {
        guard let d = date(from: firstDayOfMonth(containing: key)),
              let range = gregorianCalendar.range(of: .day, in: .month, for: d),
              let lastDate = gregorianCalendar.date(byAdding: .day, value: range.count - 1, to: d) else {
            return key
        }
        return DateKey.key(for: lastDate)
    }

    static func previousMonth(of key: String) -> String {
        guard let d = date(from: firstDayOfMonth(containing: key)),
              let prev = gregorianCalendar.date(byAdding: .month, value: -1, to: d) else {
            return key
        }
        return DateKey.key(for: prev)
    }

    static func dayCount(from: String, to: String) -> Int {
        guard let d1 = date(from: from), let d2 = date(from: to) else { return 0 }
        let comps = gregorianCalendar.dateComponents([.day], from: d1, to: d2)
        return (comps.day ?? 0) + 1
    }

    static func range(from: String, to: String, limit: Int = 370) -> [String] {
        guard from <= to else { return [] }
        var result: [String] = []
        var cursor = from
        var guardCount = 0
        while cursor <= to, guardCount < limit {
            result.append(cursor)
            cursor = addDays(cursor, 1)
            guardCount += 1
        }
        return result
    }
}
