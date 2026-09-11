//
//  SettingsView.swift
//  HeadacheDiary
//
//  Web版「設定」タブ（index.html:402-427, 858-887）。
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var context

    @State private var exportURL: URL?
    @State private var showImporter = false
    @State private var showManual = false
    @State private var importAlert: SettingsAlert?
    @State private var showMergeConfirm = false
    @State private var pendingImportData: Data?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    backupCard
                    manualCard
                    aboutCard
                }
                .padding(12)
            }
            .background(DesignConstants.background)
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showManual) { ManualView() }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
                handleImportResult(result)
            }
            .confirmationDialog(
                "現在のデータに読み込んだデータを統合します。同じ日付は上書きされます。",
                isPresented: $showMergeConfirm,
                titleVisibility: .visible
            ) {
                Button("読み込む", role: .destructive) { performImport() }
                Button("キャンセル", role: .cancel) { pendingImportData = nil }
            }
            .alert(
                importAlert?.title ?? "",
                isPresented: Binding(
                    get: { importAlert != nil },
                    set: { if !$0 { importAlert = nil } }
                ),
                presenting: importAlert
            ) { _ in
                Button("OK", role: .cancel) { importAlert = nil }
            } message: { alert in
                Text(alert.message)
            }
        }
    }

    private var backupCard: some View {
        SectionCard(title: "データのバックアップ") {
            VStack(alignment: .leading, spacing: 10) {
                Text("データはこの端末に保存されています。機種変更やアプリの再インストールに備えて、定期的に書き出しておくと安心です。Web版で書き出したファイルをこのアプリで読み込むこともできます。")
                    .font(.system(size: 13))
                    .foregroundColor(DesignConstants.gray)

                HStack(spacing: 8) {
                    if let exportURL {
                        ShareLink(item: exportURL) {
                            outlineButtonLabel("書き出し")
                        }
                    } else {
                        Button {
                            prepareExport()
                        } label: {
                            outlineButtonLabel("書き出し")
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        showImporter = true
                    } label: {
                        outlineButtonLabel("読み込み")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var manualCard: some View {
        SectionCard(title: "使い方") {
            VStack(alignment: .leading, spacing: 10) {
                Text("スクリーンショット付きの使い方マニュアルがあります。")
                    .font(.system(size: 13))
                    .foregroundColor(DesignConstants.gray)
                Button {
                    showManual = true
                } label: {
                    outlineButtonLabel("📖 使い方マニュアルを開く")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var aboutCard: some View {
        SectionCard(title: "このアプリについて") {
            Text("""
            紙の頭痛ダイアリー(坂井文彦先生監修版)をもとにしたアプリです。記録した内容は印刷タブからPDF化して、受診時に医師へ見せることができます。
            程度の記号 … 卅=重度 / 廾=中程度 / 十=軽度
            薬の効き目 … ○=効いた / △=やや効いた / ×=効かなかった
            """)
            .font(.system(size: 13))
            .foregroundColor(DesignConstants.gray)
        }
    }

    private func outlineButtonLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundColor(DesignConstants.teal)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(DesignConstants.teal, lineWidth: 1.5))
    }

    private func prepareExport() {
        do {
            let data = try DiaryImportExportService.exportData(context: context)
            let filename = "headache-diary-\(DateKey.today()).json"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try data.write(to: url)
            exportURL = url
        } catch {
            importAlert = SettingsAlert(title: "書き出しに失敗しました", message: error.localizedDescription)
        }
    }

    private func handleImportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            do {
                pendingImportData = try Data(contentsOf: url)
                showMergeConfirm = true
            } catch {
                importAlert = SettingsAlert(title: "読み込みに失敗しました", message: error.localizedDescription)
            }
        case .failure(let error):
            importAlert = SettingsAlert(title: "読み込みに失敗しました", message: error.localizedDescription)
        }
    }

    private func performImport() {
        guard let data = pendingImportData else { return }
        pendingImportData = nil
        do {
            let dto = try DiaryImportExportService.decodeData(data)
            try DiaryImportExportService.importMerge(dto, into: context)
            importAlert = SettingsAlert(title: "読み込みました", message: "")
        } catch {
            importAlert = SettingsAlert(title: "読み込みに失敗しました", message: error.localizedDescription)
        }
    }
}

private struct SettingsAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
