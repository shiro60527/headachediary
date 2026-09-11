//
//  PrintView.swift
//  HeadacheDiary
//
//  Web版「印刷」タブ（index.html:375-400, 775-856）。
//

import SwiftUI
import SwiftData

struct PrintView: View {
    @Query private var days: [DiaryDay]

    @State private var fromKey: String
    @State private var toKey: String
    @State private var pdfURL: URL?

    init() {
        let today = DateKey.today()
        _fromKey = State(initialValue: DateKey.firstDayOfMonth(containing: today))
        _toKey = State(initialValue: DateKey.lastDayOfMonth(containing: today))
    }

    private var dayLookup: [String: DiaryDay] {
        Dictionary(uniqueKeysWithValues: days.map { ($0.dateKey, $0) })
    }

    private var isRangeTooLong: Bool {
        DateKey.dayCount(from: fromKey, to: toKey) > 370
    }

    private var previewDates: [String] {
        isRangeTooLong ? [] : DateKey.range(from: fromKey, to: toKey)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    controlsCard
                    ForEach(previewDates, id: \.self) { key in
                        PrintPreviewRow(dateKey: key, day: dayLookup[key])
                    }
                }
                .padding(12)
            }
            .background(DesignConstants.background)
            .navigationTitle("印刷")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var controlsCard: some View {
        SectionCard(title: "印刷 / PDF保存") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        fieldLabel("開始日")
                        DatePicker("", selection: fromBinding, displayedComponents: .date).labelsHidden()
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        fieldLabel("終了日")
                        DatePicker("", selection: toBinding, displayedComponents: .date).labelsHidden()
                    }
                }

                HStack(spacing: 8) {
                    rangeButton("今月") {
                        let today = DateKey.today()
                        fromKey = DateKey.firstDayOfMonth(containing: today)
                        toKey = DateKey.lastDayOfMonth(containing: today)
                    }
                    rangeButton("先月") {
                        let prev = DateKey.previousMonth(of: DateKey.today())
                        fromKey = DateKey.firstDayOfMonth(containing: prev)
                        toKey = DateKey.lastDayOfMonth(containing: prev)
                    }
                    rangeButton("直近2週間") {
                        toKey = DateKey.today()
                        fromKey = DateKey.addDays(toKey, -13)
                    }
                }

                if isRangeTooLong {
                    Text("印刷できるのは最大370日分です。範囲を調整してください。")
                        .font(.system(size: 12))
                        .foregroundColor(DesignConstants.red)
                }

                if let pdfURL {
                    ShareLink(item: pdfURL, preview: SharePreview("頭痛ダイアリー")) {
                        shareButtonLabel
                    }
                } else {
                    Button {
                        generatePDF()
                    } label: {
                        shareButtonLabel
                    }
                    .buttonStyle(.plain)
                    .disabled(isRangeTooLong || fromKey > toKey)
                }

                Text("iPhoneの共有シートから「プリント」でAirPrint、または「ファイルに保存」でPDFに保存できます。")
                    .font(.system(size: 12))
                    .foregroundColor(DesignConstants.gray)
            }
        }
        .onChange(of: fromKey) { pdfURL = nil }
        .onChange(of: toKey) { pdfURL = nil }
    }

    private var shareButtonLabel: some View {
        Text("🖨 印刷 / PDFに保存")
            .font(.system(size: 15, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(DesignConstants.teal)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text).font(.system(size: 12, weight: .bold)).foregroundColor(DesignConstants.gray)
    }

    private func rangeButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .foregroundColor(DesignConstants.teal)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(DesignConstants.teal, lineWidth: 1.5))
    }

    private var fromBinding: Binding<Date> {
        Binding(
            get: { DateKey.date(from: fromKey) ?? Date() },
            set: { fromKey = DateKey.key(for: $0) }
        )
    }

    private var toBinding: Binding<Date> {
        Binding(
            get: { DateKey.date(from: toKey) ?? Date() },
            set: { toKey = DateKey.key(for: $0) }
        )
    }

    private func generatePDF() {
        guard !isRangeTooLong, fromKey <= toKey else { return }
        let lookup = dayLookup
        let data = PrintPDFRenderer.generate(from: fromKey, to: toKey) { lookup[$0] }
        let filename = "headache-diary-\(fromKey)_\(toKey).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            pdfURL = url
        } catch {
            pdfURL = nil
        }
    }
}

private struct PrintPreviewRow: View {
    let dateKey: String
    let day: DiaryDay?

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack {
                Text(DateKey.paddedMonthDay(dateKey))
                    .font(.system(size: 12, weight: .bold))
                Text(weekdayText)
                    .font(.system(size: 10))
                    .foregroundColor(DesignConstants.gray)
            }
            .frame(width: 44)

            HeadacheTimelineChart(
                entries: (day?.entries ?? []).map { TimelineEntryInput(time: $0.time, level: $0.level) },
                meds: (day?.medications ?? []).map { TimelineMedInput(time: $0.time) },
                compact: true
            )
            .frame(width: 150)

            VStack(alignment: .leading, spacing: 2) {
                if !summaryText.isEmpty {
                    Text(summaryText)
                        .font(.system(size: 11))
                        .foregroundColor(DesignConstants.text)
                        .lineLimit(3)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(8)
        .background(DesignConstants.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var weekdayText: String {
        DateKey.shortLabel(dateKey).components(separatedBy: "(").last?.replacingOccurrences(of: ")", with: "") ?? ""
    }

    private var summaryText: String {
        guard let day else { return "" }
        var parts: [String] = []
        let meds = day.medicationsByInsertionOrder
        if !meds.isEmpty {
            parts.append(meds.map { "\($0.name)\(formattedCount($0.count))錠" }.joined(separator: "、"))
        }
        if !day.memo.isEmpty { parts.append(day.memo) }
        return parts.joined(separator: " / ")
    }

    private func formattedCount(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
}
