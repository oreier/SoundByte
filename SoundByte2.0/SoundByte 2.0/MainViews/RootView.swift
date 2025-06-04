//
//  RootView.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 5/29/25.
//

import SwiftUI

enum AppMode {
    case start
    case sheetMusic
    case tuner
}

struct RootView: View {
    @State private var currentMode: AppMode = .start

    var body: some View {
        ZStack {
            switch currentMode {
            case .start:
                HomeView(
                    onRecordTap: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentMode = .sheetMusic
                        }
                    },
                    onTunerTap: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentMode = .tuner
                        }
                    }
                )
                .transition(.opacity)

            case .sheetMusic:
                SheetMusicContentView()
                    .transition(.opacity)

            case .tuner:
                TunerContentView()
                    .transition(.opacity)
            }
        }
    }
}


#Preview {
    RootView()
}
