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

        // Allow local file access if needed by Pyodide
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        let userContentController = WKUserContentController()
        // Set up message handlers to receive output and completion signals
        userContentController.add(context.coordinator, name: "outputHandler")
        userContentController.add(context.coordinator, name: "finishedHandler")
        config.userContentController = userContentController

        // Create and configure the WKWebView
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator

        // Load local HTML file that bootstraps Pyodide
        if let url = Bundle.main.url(forResource: htmlFile, withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: Bundle.main.resourceURL!)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Escape special characters in multiline Python string for JS injection
        let escapedCode = pythonCode
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\"", with: "\\\"")

        // JavaScript to inject Python code into Pyodide environment
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
                // Redirect stdout and stderr to Swift via message handler
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
                // Run the actual user-provided Python code
                await window.pyodide.runPythonAsync("\#(escapedCode)");
                // Signal execution complete
                window.webkit.messageHandlers.finishedHandler.postMessage("done");
            } catch(e) {
                // Send error messages to Swift
                window.webkit.messageHandlers.outputHandler.postMessage("Error: " + e.toString());
                window.webkit.messageHandlers.finishedHandler.postMessage("done");
            }
        })();
        """#

        // Inject and evaluate the JavaScript in the web view
        uiView.evaluateJavaScript(runCodeJS)
    }

    // Coordinator bridges Swift <-> WebKit messages
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        // Handle messages sent from JS (Python print output and finished signal)
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
