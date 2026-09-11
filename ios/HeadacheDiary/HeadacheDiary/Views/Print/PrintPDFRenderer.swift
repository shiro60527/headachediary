//
//  PrintPDFRenderer.swift
//  HeadacheDiary
//
//  Web版 renderPrintSheet()（index.html:804-856）相当のPDF出力。
//  A4縦・12mm(≒34pt)マージン。TimelineGeometry/TimelineBuilder が返す
//  描画プリミティブ列を CGContext に直接ベクタ描画する
//  （ImageRenderer によるラスタライズは行わない。@MainActor拘束・ぼやけ・
//  上下反転CTMの問題を避けるため）。
//

import SwiftUI
import UIKit

enum PrintPDFRenderer {
    private static let pageWidth: CGFloat = 595.2
    private static let pageHeight: CGFloat = 841.8
    private static let margin: CGFloat = 34

    private static let colDate: CGFloat = 55
    private static let colTimeline: CGFloat = 190
    private static let colImpact: CGFloat = 36
    private static var colNotes: CGFloat { pageWidth - margin * 2 - colDate - colTimeline - colImpact }

    private static let headerRowHeight: CGFloat = 20
    private static let minRowHeight: CGFloat = 34

    static func generate(from: String, to: String, dayLookup: (String) -> DiaryDay?) -> Data {
        let bounds = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)

        return renderer.pdfData { rendererContext in
            var cursorY: CGFloat = margin

            func beginPage() {
                rendererContext.beginPage()
                cursorY = margin
                drawTitle(in: rendererContext.cgContext, from: from, to: to, cursorY: &cursorY)
                drawTableHeader(in: rendererContext.cgContext, cursorY: &cursorY)
            }

            beginPage()

            var dateCursor = from
            var guardCount = 0
            while dateCursor <= to, guardCount < 370 {
                guardCount += 1
                let day = dayLookup(dateCursor)
                let rowHeight = computeRowHeight(day: day)

                if cursorY + rowHeight > pageHeight - margin {
                    beginPage()
                }

                drawRow(dateKey: dateCursor, day: day, in: rendererContext.cgContext, cursorY: cursorY, rowHeight: rowHeight)
                cursorY += rowHeight
                dateCursor = DateKey.addDays(dateCursor, 1)
            }

            if cursorY + 60 > pageHeight - margin {
                beginPage()
            }
            drawLegend(in: rendererContext.cgContext, cursorY: cursorY)
        }
    }

    // MARK: - ヘッダー

    private static func drawTitle(in context: CGContext, from: String, to: String, cursorY: inout CGFloat) {
        let title = "頭痛ダイアリー" as NSString
        title.draw(at: CGPoint(x: margin, y: cursorY), withAttributes: [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: uiColor(DesignConstants.tealDark)
        ])
        cursorY += 22

        let sub = "\(DateKey.longLabel(from)) 〜 \(DateKey.longLabel(to))" as NSString
        sub.draw(at: CGPoint(x: margin, y: cursorY), withAttributes: [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: uiColor(DesignConstants.gray)
        ])
        cursorY += 18
    }

    private static func drawTableHeader(in context: CGContext, cursorY: inout CGFloat) {
        let widths = [colDate, colTimeline, colImpact, colNotes]
        let headers = ["日付", "頭痛の程度(0〜24時)", "影響度", "薬・メモ"]

        context.setFillColor(uiColor(hex: 0xe8f1f5).cgColor)
        context.fill(CGRect(x: margin, y: cursorY, width: pageWidth - margin * 2, height: headerRowHeight))

        var x = margin
        for (i, header) in headers.enumerated() {
            (header as NSString).draw(
                in: CGRect(x: x + 3, y: cursorY + 5, width: widths[i] - 6, height: headerRowHeight - 6),
                withAttributes: [.font: UIFont.boldSystemFont(ofSize: 9), .foregroundColor: uiColor(DesignConstants.tealDark)]
            )
            x += widths[i]
        }
        cursorY += headerRowHeight

        context.setStrokeColor(uiColor(hex: 0x94a3b8).cgColor)
        context.setLineWidth(0.75)
        context.move(to: CGPoint(x: margin, y: cursorY))
        context.addLine(to: CGPoint(x: pageWidth - margin, y: cursorY))
        context.strokePath()
    }

    // MARK: - 行

    private static func computeRowHeight(day: DiaryDay?) -> CGFloat {
        guard let day else { return minRowHeight }
        let text = noteText(for: day)
        guard !text.isEmpty else { return minRowHeight }

        let bounding = (text as NSString).boundingRect(
            with: CGSize(width: colNotes - 8, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: UIFont.systemFont(ofSize: 9)],
            context: nil
        )
        return max(minRowHeight, bounding.height + 8)
    }

    private static func drawRow(dateKey: String, day: DiaryDay?, in context: CGContext, cursorY: CGFloat, rowHeight: CGFloat) {
        var x = margin

        context.setStrokeColor(uiColor(hex: 0x94a3b8).cgColor)
        context.setLineWidth(0.4)
        context.move(to: CGPoint(x: margin, y: cursorY + rowHeight))
        context.addLine(to: CGPoint(x: pageWidth - margin, y: cursorY + rowHeight))
        context.strokePath()

        // 日付列
        (DateKey.paddedMonthDay(dateKey) as NSString).draw(
            at: CGPoint(x: x + 4, y: cursorY + 4),
            withAttributes: [.font: UIFont.boldSystemFont(ofSize: 11), .foregroundColor: uiColor(DesignConstants.text)]
        )
        ("(\(weekdayLabel(dateKey)))" as NSString).draw(
            at: CGPoint(x: x + 4, y: cursorY + 18),
            withAttributes: [.font: UIFont.systemFont(ofSize: 8), .foregroundColor: weekdayColor(dateKey)]
        )
        x += colDate

        // タイムライン列
        let entries = (day?.entries ?? []).map { TimelineEntryInput(time: $0.time, level: $0.level) }
        let meds = (day?.medications ?? []).map { TimelineMedInput(time: $0.time) }
        let geometry = TimelineGeometry(compact: true)
        let primitives = TimelineBuilder.build(geometry: geometry, entries: entries, meds: meds)
        let timelineRect = CGRect(x: x + 2, y: cursorY + 3, width: colTimeline - 4, height: min(rowHeight - 6, geometry.height))
        drawTimeline(primitives, geometry: geometry, in: context, rect: timelineRect)
        x += colTimeline

        // 影響度列（Web版の impact===0 がfalsyでグレー表示になる挙動を再現）
        let impactMark: String
        let impactColor: UIColor
        if let impact = day?.impact, let level = ImpactLevel(rawValue: impact) {
            impactMark = level.mark
            impactColor = impact == 0 ? uiColor(hex: 0x9ca3af) : uiColor(level.color)
        } else {
            impactMark = "−"
            impactColor = uiColor(hex: 0xd1d5db)
        }
        let impactAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 11), .foregroundColor: impactColor]
        let impactSize = (impactMark as NSString).size(withAttributes: impactAttrs)
        (impactMark as NSString).draw(at: CGPoint(x: x + (colImpact - impactSize.width) / 2, y: cursorY + 4), withAttributes: impactAttrs)
        x += colImpact

        // 薬・メモ列
        let text = day.map(noteText) ?? ""
        if !text.isEmpty {
            (text as NSString).draw(
                in: CGRect(x: x + 4, y: cursorY + 3, width: colNotes - 8, height: rowHeight - 6),
                withAttributes: [.font: UIFont.systemFont(ofSize: 9), .foregroundColor: uiColor(hex: 0x374151)]
            )
        }
    }

    private static func noteText(for day: DiaryDay) -> String {
        var lines: [String] = []
        for m in day.medicationsByInsertionOrder {
            let effect = MedEffect.from(m.effect)
            let countText = formattedCount(m.count)
            let timeText = m.time.isEmpty ? "" : "(\(m.time))"
            lines.append("💊\(m.name) \(countText)錠 \(effect.shortLabel)\(timeText)")
        }
        let entryNotes = day.sortedEntries.filter { !$0.note.isEmpty }.map { "\($0.time) \($0.note)" }.joined(separator: " / ")
        if !entryNotes.isEmpty { lines.append(entryNotes) }
        if !day.memo.isEmpty { lines.append(day.memo) }
        return lines.joined(separator: "\n")
    }

    // MARK: - タイムライン（TimelineGeometry/TimelineBuilder の共通ロジックをCGContextに描画）

    private static func drawTimeline(_ primitives: [TimelinePrimitive], geometry: TimelineGeometry, in context: CGContext, rect: CGRect) {
        context.saveGState()
        let scale = rect.width / geometry.width
        context.translateBy(x: rect.minX, y: rect.minY)
        context.scaleBy(x: scale, y: scale)

        for primitive in primitives {
            switch primitive {
            case let .line(from, to, color, lineWidth, dash, opacity):
                context.saveGState()
                context.setStrokeColor(uiColor(color).cgColor)
                context.setAlpha(opacity)
                context.setLineWidth(lineWidth)
                context.setLineCap(.round)
                if !dash.isEmpty { context.setLineDash(phase: 0, lengths: dash) }
                context.move(to: from)
                context.addLine(to: to)
                context.strokePath()
                context.restoreGState()

            case let .circle(center, radius, color):
                context.setFillColor(uiColor(color).cgColor)
                context.fillEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))

            case let .rect(origin, size, cornerRadius, color):
                let path = UIBezierPath(roundedRect: CGRect(origin: origin, size: size), cornerRadius: cornerRadius)
                context.setFillColor(uiColor(color).cgColor)
                context.addPath(path.cgPath)
                context.fillPath()

            case let .text(string, at, fontSize, color, bold, anchor):
                let font = bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: uiColor(color)]
                let nsString = string as NSString
                let size = nsString.size(withAttributes: attrs)
                var point = at
                switch anchor {
                case .leading: point.y -= size.height / 2
                case .center: point.x -= size.width / 2; point.y -= size.height / 2
                }
                nsString.draw(at: point, withAttributes: attrs)
            }
        }
        context.restoreGState()
    }

    // MARK: - 凡例

    private static func drawLegend(in context: CGContext, cursorY: CGFloat) {
        let legend = """
        頭痛の程度: 卅 重度 / 廾 中程度 / 十 軽度（線の高さが程度、点線は継続中）
        影響度: 卅 何も手につかず横になる必要 / 廾 能率が半分以下 / 十 大きな支障なし
        薬の効果: ○ 効いた / △ やや効いた / × 効かなかった
        """
        (legend as NSString).draw(
            in: CGRect(x: margin, y: cursorY + 8, width: pageWidth - margin * 2, height: 60),
            withAttributes: [.font: UIFont.systemFont(ofSize: 8), .foregroundColor: uiColor(DesignConstants.gray)]
        )
    }

    // MARK: - Helpers

    private static func weekdayIndex(_ key: String) -> Int {
        guard let d = DateKey.date(from: key) else { return 0 }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        return cal.component(.weekday, from: d) - 1
    }

    private static func weekdayLabel(_ key: String) -> String {
        DesignConstants.dow[weekdayIndex(key)]
    }

    private static func weekdayColor(_ key: String) -> UIColor {
        switch weekdayIndex(key) {
        case 0: return uiColor(DesignConstants.red)
        case 6: return uiColor(hex: 0x2563eb)
        default: return uiColor(DesignConstants.gray)
        }
    }

    private static func formattedCount(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }

    private static func uiColor(_ color: Color) -> UIColor { UIColor(color) }
    private static func uiColor(hex: UInt32) -> UIColor { UIColor(Color(hex: hex)) }
}
