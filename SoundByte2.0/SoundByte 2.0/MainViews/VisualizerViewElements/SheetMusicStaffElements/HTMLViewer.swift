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
    var url: URL?
    
    func makeUIView(context: Context) -> WKWebView {
        let wkWebView = WKWebView()
        let request = URLRequest(url: url!)
        wkWebView.load(request)
        return wkWebView
    }
    
    init(fileName: String) {
        self.fileName = fileName
        
        // Get url for music HTML
        self.url = Bundle.main.url(forResource: fileName, withExtension: "html")
    }
    
    // This function needs to exist for a UIViewRepresentable object
    func updateUIView(_ webView: WKWebView, context: Context) {
    }
}

#Preview {
    HTMLViewer(fileName: "index")
}
