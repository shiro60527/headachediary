//
//  ManualView.swift
//  HeadacheDiary
//
//  使い方マニュアル画面。Resources/Manual/manual.html（iOS向けに文言を調整した
//  コピー）をバンドル同梱し WKWebView で表示する。
//
//  manual.html 内の「← 閉じる」リンクは headachediary-app://close というカスタム
//  スキームにしてあり、WKNavigationDelegate でこの遷移をインターセプトして
//  画面を閉じる（Web版のような index.html への遷移は行わない）。
//

import SwiftUI
@preconcurrency import WebKit

struct ManualView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ManualWebView(onClose: { dismiss() })
                .navigationTitle("使い方")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("閉じる") { dismiss() }
                    }
                }
        }
    }
}

private struct ManualWebView: UIViewRepresentable {
    let onClose: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onClose: onClose)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator

        // Xcodeのフォルダ同期グループは既定でCopy Bundle Resources時に
        // フラット化されるため、まずバンドル直下を探し、見つからなければ
        // "Manual" サブディレクトリ配下を探す（プロジェクト設定に依存しないためのフォールバック）。
        let url = Bundle.main.url(forResource: "manual", withExtension: "html")
            ?? Bundle.main.url(forResource: "manual", withExtension: "html", subdirectory: "Manual")

        if let url {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        let onClose: () -> Void

        init(onClose: @escaping () -> Void) {
            self.onClose = onClose
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.request.url?.scheme == "headachediary-app" {
                decisionHandler(.cancel)
                onClose()
                return
            }
            decisionHandler(.allow)
        }
    }
}
