//
//  HTMLViewer.swift
//  HTMLViewerTest
//
//  Created by Kieran Yanaway (Student) on 5/28/25.
//

import SwiftUI
import UIKit
import WebKit

struct HTMLViewer: UIViewRepresentable {
    var fileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Get url for music HTML
        guard let htmlurl = Bundle.main.url(forResource: fileName, withExtension: "html") else { return }
        // Load HTML url
        webView.load(URLRequest(url: htmlurl))
    }
}

#Preview {
    HTMLViewer(fileName: "rendererTest")
}
