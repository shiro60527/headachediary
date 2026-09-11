//
//  HeadacheTimelineChart.swift
//  HeadacheDiary
//
//  Web版タイムラインSVGのCanvas版。TimelineGeometry/TimelineBuilder の
//  描画プリミティブ列をSwiftUI Canvasで描く薄いコンシューマ。
//  「記録タブの通常表示」「履歴カードのcompact」「印刷PDF内のcompact」で共通利用する。
//
//  SwiftUI標準の TimelineView との型名衝突を避けるため命名。
//

import SwiftUI

struct HeadacheTimelineChart: View {
    let entries: [TimelineEntryInput]
    let meds: [TimelineMedInput]
    let compact: Bool

    private var geometry: TimelineGeometry { TimelineGeometry(compact: compact) }

    var body: some View {
        Canvas { context, size in
            guard size.width > 0 else { return }
            let scale = size.width / geometry.width
            context.scaleBy(x: scale, y: scale)
            for primitive in TimelineBuilder.build(geometry: geometry, entries: entries, meds: meds) {
                draw(primitive, in: &context)
            }
        }
        .aspectRatio(geometry.width / geometry.height, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .accessibilityHidden(compact)
        .accessibilityLabel(compact ? "" : "今日のタイムライン")
    }

    private func draw(_ primitive: TimelinePrimitive, in context: inout GraphicsContext) {
        switch primitive {
        case let .line(from, to, color, lineWidth, dash, opacity):
            var path = Path()
            path.move(to: from)
            path.addLine(to: to)
            let style = StrokeStyle(lineWidth: lineWidth, lineCap: .round, dash: dash)
            let previousOpacity = context.opacity
            context.opacity = opacity
            context.stroke(path, with: .color(color), style: style)
            context.opacity = previousOpacity

        case let .circle(center, radius, color):
            let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
            context.fill(Path(ellipseIn: rect), with: .color(color))

        case let .rect(origin, size, cornerRadius, color):
            let rect = CGRect(origin: origin, size: size)
            context.fill(Path(roundedRect: rect, cornerRadius: cornerRadius), with: .color(color))

        case let .text(string, at, fontSize, color, bold, anchor):
            let text = Text(string)
                .font(.system(size: fontSize, weight: bold ? .bold : .regular))
                .foregroundColor(color)
            let resolved = context.resolve(text)
            switch anchor {
            case .leading:
                context.draw(resolved, at: at, anchor: .leading)
            case .center:
                context.draw(resolved, at: at, anchor: .center)
            }
        }
    }
}

#Preview {
    HeadacheTimelineChart(
        entries: [
            TimelineEntryInput(time: "08:00", level: 2),
            TimelineEntryInput(time: "12:00", level: 3),
            TimelineEntryInput(time: "18:00", level: 1)
        ],
        meds: [TimelineMedInput(time: "12:30")],
        compact: false
    )
    .padding()
}
