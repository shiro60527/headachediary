//
//  TimelineGeometry.swift
//  HeadacheDiary
//
//  Web版 renderTimeline()（index.html:513-585）の座標計算・描画内容を
//  プラットフォーム非依存の「描画プリミティブ列」として再現する。
//  SwiftUI Canvas（HeadacheTimelineChart）と CGContext（PDF出力）の
//  両方がこの1つのロジックを共通利用し、二重実装を避ける。
//

import CoreGraphics
import SwiftUI

struct TimelineGeometry {
    let compact: Bool

    let width: CGFloat = 480
    var height: CGFloat { compact ? 64 : 118 }
    var padL: CGFloat { compact ? 4 : 8 }
    var padR: CGFloat { compact ? 4 : 8 }
    var padT: CGFloat { compact ? 6 : 22 }
    var axisY: CGFloat { height - (compact ? 14 : 24) }
    var plotWidth: CGFloat { width - padL - padR }

    func levelY(_ level: Int) -> CGFloat {
        axisY - CGFloat(level) * ((axisY - padT) / 3)
    }

    func x(ofMinutes minutes: Int) -> CGFloat {
        padL + (CGFloat(minutes) / 1440) * plotWidth
    }
}

struct TimelineEntryInput {
    var time: String
    var level: Int
}

struct TimelineMedInput {
    var time: String
}

enum TimelineTextAnchor {
    case leading
    case center
}

enum TimelinePrimitive {
    case line(from: CGPoint, to: CGPoint, color: Color, lineWidth: CGFloat, dash: [CGFloat], opacity: Double)
    case circle(center: CGPoint, radius: CGFloat, color: Color)
    case rect(origin: CGPoint, size: CGSize, cornerRadius: CGFloat, color: Color)
    case text(String, at: CGPoint, fontSize: CGFloat, color: Color, bold: Bool, anchor: TimelineTextAnchor)
}

enum TimelineBuilder {
    private static let guideGray = Color(hex: 0xe5e7eb)
    private static let axisGray = Color(hex: 0x94a3b8)
    private static let tickLabelGray = Color(hex: 0x6b7280)
    private static let connectorGray = Color(hex: 0xcbd5e1)
    private static let placeholderGray = Color(hex: 0x9ca3af)

    static func build(
        geometry g: TimelineGeometry,
        entries: [TimelineEntryInput],
        meds: [TimelineMedInput]
    ) -> [TimelinePrimitive] {
        var p: [TimelinePrimitive] = []
        let compact = g.compact

        // 程度ガイド線 (lv 1...3)
        for lv in 1...3 {
            let y = g.levelY(lv)
            p.append(.line(from: CGPoint(x: g.padL, y: y), to: CGPoint(x: g.width - g.padR, y: y),
                            color: guideGray, lineWidth: 1, dash: [2, 3], opacity: 1))
            if !compact {
                let level = HeadacheLevel(rawValueClamped: lv)
                p.append(.text("\(level.mark) \(level.label)", at: CGPoint(x: g.padL + 1, y: y - 3),
                                fontSize: 9, color: placeholderGray, bold: false, anchor: .leading))
            }
        }

        // 時間軸
        p.append(.line(from: CGPoint(x: g.padL, y: g.axisY), to: CGPoint(x: g.width - g.padR, y: g.axisY),
                        color: axisGray, lineWidth: 1.5, dash: [], opacity: 1))
        var h = 0
        while h <= 24 {
            let x = g.x(ofMinutes: h * 60)
            p.append(.line(from: CGPoint(x: x, y: g.axisY), to: CGPoint(x: x, y: g.axisY + 4),
                            color: axisGray, lineWidth: 1, dash: [], opacity: 1))
            p.append(.text("\(h)", at: CGPoint(x: x, y: g.axisY + (compact ? 12 : 16)),
                            fontSize: compact ? 9 : 10, color: tickLabelGray, bold: false, anchor: .center))
            h += 3
        }

        let sortedEntries = entries.sorted { DateKey.timeToMinutes($0.time) < DateKey.timeToMinutes($1.time) }

        for (i, e) in sortedEntries.enumerated() {
            let x1 = g.x(ofMinutes: DateKey.timeToMinutes(e.time))
            let y = g.levelY(e.level)
            let level = HeadacheLevel(rawValueClamped: e.level)
            let color = level.color
            let isLast = i == sortedEntries.count - 1
            let x2 = isLast ? (g.width - g.padR) : g.x(ofMinutes: DateKey.timeToMinutes(sortedEntries[i + 1].time))

            if e.level > 0 {
                p.append(.line(from: CGPoint(x: x1, y: y), to: CGPoint(x: x2, y: y),
                                color: color, lineWidth: 3,
                                dash: isLast ? [6, 5] : [], opacity: isLast ? 0.65 : 1))
            }
            if !isLast {
                let yNext = g.levelY(sortedEntries[i + 1].level)
                if yNext != y {
                    p.append(.line(from: CGPoint(x: x2, y: y), to: CGPoint(x: x2, y: yNext),
                                    color: connectorGray, lineWidth: 1.5, dash: [], opacity: 1))
                }
            }
            p.append(.circle(center: CGPoint(x: x1, y: y), radius: compact ? 3.5 : 5, color: color))
            if !compact {
                p.append(.text(e.time, at: CGPoint(x: x1, y: y - 9), fontSize: 9, color: color, bold: true, anchor: .center))
            }
        }

        // 薬マーク（time が空文字列のものはスキップ）
        for m in meds where !m.time.isEmpty {
            let x = g.x(ofMinutes: DateKey.timeToMinutes(m.time))
            let y = g.axisY - (compact ? 5 : 7)
            p.append(.rect(origin: CGPoint(x: x - 4, y: y - 4), size: CGSize(width: 8, height: 8),
                            cornerRadius: 2, color: DesignConstants.teal))
            p.append(.text("薬", at: CGPoint(x: x, y: y + 2.5), fontSize: 7, color: .white, bold: true, anchor: .center))
        }

        if sortedEntries.isEmpty, meds.isEmpty, !compact {
            p.append(.text("まだ記録がありません", at: CGPoint(x: g.width / 2, y: g.height / 2 - 6),
                            fontSize: 12, color: placeholderGray, bold: false, anchor: .center))
        }

        return p
    }
}
