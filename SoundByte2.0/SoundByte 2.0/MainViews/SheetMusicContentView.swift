//
//  SecondContentView.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 6/4/25.
//

import SwiftUI

struct SheetMusicContentView: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                VisualizerView(width: width, height: height)
            }
        }
        .navigationTitle("Sheet Music")
    }
}

#Preview {
    SheetMusicContentView()
}
