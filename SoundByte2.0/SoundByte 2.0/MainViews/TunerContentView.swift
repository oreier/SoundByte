//
//  ContentView.swift
//  SoundByte 2.0
//
//  Created by Jack Durfee on 5/28/24.
//

import SwiftUI

struct TunerContentView: View {
    let mode: AppMode

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                VisualizerView(width: width, height: height, mode: mode, gradeMode: .tuning)
            }
        }
        .navigationTitle("Tuner")
    }
}

#Preview {
    TunerContentView(mode: .tuner)
}
