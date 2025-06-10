//
//  SecondContentView.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 6/4/25.
//

import SwiftUI

struct SheetMusicContentView: View {
    let mode: AppMode
    let gradeMode: GradeMode

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                VisualizerView(width: width, height: height, mode: mode, gradeMode: gradeMode)
            }
        }
        .navigationTitle("Sheet Music")
    }
}

#Preview {
    SheetMusicContentView(mode: .sheetMusic, gradeMode: .playing)
}
