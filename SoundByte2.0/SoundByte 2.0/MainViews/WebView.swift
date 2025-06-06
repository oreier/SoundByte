//
//  WebView.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 6/6/25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let htmlFile: String
    let pythonCode: String
    var onOutput: ((String) -> Void)?
    var onFinished: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator

        if let url = Bundle.main.url(forResource: htmlFile, withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }

        webView.configuration.userContentController.add(context.coordinator, name: "outputHandler")
        webView.configuration.userContentController.add(context.coordinator, name: "finishedHandler")

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Inject Python code to run after Pyodide loads
        let escapedCode = pythonCode
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let runCodeJS = #"""
        (async () => {
            if (!window.pyodide) {
                console.log("Waiting for Pyodide to load...");
                await new Promise(resolve => {
                    window.addEventListener('pyodideReady', () => {
                        resolve();
                    });
                });
            }
            try {
                // Capture print output
                await window.pyodide.runPythonAsync(`
        import builtins
        import sys
        class StdoutCatcher:
            def __init__(self):
                self.buffer = []
            def write(self, s):
                if s.strip() != "":
                    window.webkit.messageHandlers.outputHandler.postMessage(s)
            def flush(self):
                pass
        sys.stdout = sys.stderr = StdoutCatcher()
                `);
                // Run user's code
                await window.pyodide.runPythonAsync("\#(escapedCode)");
                // Notify finished
                window.webkit.messageHandlers.finishedHandler.postMessage("done");
            } catch(e) {
                window.webkit.messageHandlers.outputHandler.postMessage("Error: " + e.toString());
                window.webkit.messageHandlers.finishedHandler.postMessage("done");
            }
        })();
        """#

        uiView.evaluateJavaScript(runCodeJS)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "outputHandler", let output = message.body as? String {
                DispatchQueue.main.async {
                    self.parent.onOutput?(output)
                }
            } else if message.name == "finishedHandler" {
                DispatchQueue.main.async {
                    self.parent.onFinished?()
                }
            }
        }
    }
}
