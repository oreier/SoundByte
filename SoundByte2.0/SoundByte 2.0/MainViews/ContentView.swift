//
//  ContentView.swift
//  SoundByte 2.0
//
//  Created by Jack Durfee on 5/28/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // geometry reader gets the screen size and sets up visualizer view with it
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            
            VisualizerView(width: width, height: height)
        }
    }
}

#Preview {
    ContentView()
}
