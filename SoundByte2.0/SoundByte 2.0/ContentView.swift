//
//  ContentView.swift
//  SoundByte 2.0
//
//  Created by Jack Durfee on 5/28/24.
//

import SwiftUI
import AudioKit

struct ContentView: View {
    var body: some View {
        GeometryReader { proxy in
            let screenWidth = proxy.size.width
            let screenHeight = proxy.size.height
            
            VisualizerView(width: screenWidth, height: screenHeight)
        }
    }
}

#Preview {
    ContentView()
}
